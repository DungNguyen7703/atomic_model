/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_maturity_wall
* Program name: Fact Corporate Bond Maturity Wall
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01			Claude				Ap dung LLD ban 2026-10-01 (changelog Phan 6): mo rong 2 luong LISTED/PRIVATE
*
*--------------------------------------------------------------------*
* Ghi chu (LLD 2026-10-01 - DTM_PTTT_fct_corporate_bond_maturity_wall.csv):
* - Grain: 1 dong / (bond_flow_code, bond_code) / ngay chot quy.
*   + LISTED : trai phieu niem yet, nguon atm_security_trading_snapshot
*              (MDDS_JAD_STOCKINFOR, stock_tp_code IN ('B','1','D')).
*              Ngay chot quy = MAX(trading_dt) cua quy chua etl_date (chung
*              cho ca thi truong, dung nhu LLD).
*   + PRIVATE: trai phieu rieng le, nguon atm_private_corp_bond_offering
*              (HNX_PRIVATE_CORP_BOND_OFFERING). Ngay chot quy = cuoi thang
*              cua rpt_month = thang cuoi quy (BA dong 322).
*              Moi bond_code lay 1 ban ghi (posting_date moi nhat) - GIA DINH
*              khu trung vi khoa atomic gom ca market_type/posting_date.
* - securities_dim_id: CHI luong LISTED; PRIVATE = NULL (khong co trong
*   securities_dim) -> phan biet qua bond_flow_code/bond_code.
* - ranking_code: LISTED noi public_company theo SUBSTR(symbol,1,3) =
*   equity_ticker_symbol (O_PTTT_30; moi ma CP lay 1 pc_id nho nhat de khong
*   nhan dong); PRIVATE noi theo pc_nm = issuer_name. Ky xep hang =
*   nam/thang cua ngay chot quy.
* - Cot maturity_value_high_risk BI BO khoi LLD moi (K_PTTT_178 tinh o BI:
*   SUM(bond_outstanding_val) WHERE ranking_code IN (...) AND maturity_dt
*   trong ky xet) -> da xoa; doi ten bond_outstanding_value ->
*   bond_outstanding_val; them bond_flow_code, bond_code, maturity_dt.
* - Model incremental_rebase/append: INSERT theo VI TRI cot -> thu tu SELECT
*   phai khop DDL (ALTER ... AFTER: bond_flow_code/bond_code sau ranking_code, maturity_dt sau bond_outstanding_val).
* - atm_security_trading_snapshot/atm_private_corp_bond_offering la
*   incremental_rebase/snapshot (KHONG _hstr); atm_public_company va
*   atm_pc_bond_evaluation la scd4a -> dung _hstr.
*--------------------------------------------------------------------*
* 2026-10-05			tuan.nguyenvanb		Ap dung LLD cap nhat (commit 768dd18b, BA HNX Nhom 19, O_PTTT_36), CHI luong
*									LISTED (PRIVATE giu nguyen): (1) loc stock_tp_code = '1' + loai TP Chinh phu/
*									dia phuong (regex ^[A-Za-z]{2}GB, ^(TD|TP|CP|QH|KB|BL), ^(HCM|HAN)) thay IN
*									('B','1','D'); (2) outstanding_vol lay tu atm_listed_share_information (src
*									HNX_LISTED_SECURITIES_LIST, listed_share_quantity, ticker_symbol = symbol)
*									tai ds_snpst_dt = MAX(ds_snpst_dt) trong quy cua etl_date, thay cho
*									total_listing_vol. LLD khong ghi dedup ban ghi cuoi phien cho dong LISTED -> van
*									dedup (symbol) tai ngay chot quy theo trading_time DESC de tranh trung PK.
*									LEFT JOIN lsi: ma TP khong co dong HNX van giu dong (outstanding_vol = NULL).
*									Cot output KHONG doi -> khong can ALTER.
* 2026-10-05b			tuan.nguyenvanb		LLD (commit 96bfadb3): cot khoi luong HNX doi tu outstanding_share_quantity
*									sang listed_share_quantity (HNX listed_shares - "tam thay outstanding_shares
*									cua BA", O_PTTT_36). Chi doi ten cot nguon, logic giu nguyen. Cot output KHONG
*									doi -> khong can ALTER.
* 2026-10-19			tuan.nguyenvanb		[LLD d5b4e8b7] Chuan hoa ten cot nguon Atomic cua atm_private_corp_bond_offering (luong PRIVATE):
*									issuer_name -> issuer_nm, report_month -> rpt_month, par_value -> par_val, maturity_date -> maturity_dt
*									(chi doi ten cot doc nguon; alias issuer_name noi bo CTE giu nguyen; cot output khong doi nen khong can ALTER).
* 2026-10-19			tuan.nguyenvanb		Doi theo atomic offering moi (LLD atomic): ORDER BY posting_date -> posting_dt trong CTE pr_of_ranked.
* 2026-10-20			tuan.nguyenvanb		[LLD O_PTTT_53] atomic rpt_month chi luu so thang, nam o rpt_year: bo loc ky dung CAST(rpt_year AS INT)=nam AND
*									CAST(rpt_month AS INT)=quy*3; ngay chot quy = LAST_DAY(TO_DATE(CONCAT(rpt_year, LPAD(rpt_month,2,'0'),'01'))).
*									Khong doi cot output nen khong can ALTER.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-10-27			tuan.nguyenvanb		se_tr them trading_dt <= etl_date; lsi_q them ds_snpst_dt <= etl_date: ngay chot quy = phien cuoi quy TINH DEN etl_date
*									(truoc khong chan -> khi atomic di truoc etl_date, q_end = ngay tuong lai, nhieu etl_date cung ghi 1 snpst_dt_dim_id). Khong doi cot output.
*/

WITH se_tr AS (

    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , trading_time
        , sequence
        , maturity_dt
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE stock_tp_code = '1'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )
        AND YEAR(trading_dt) = YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
        AND QUARTER(trading_dt) = QUARTER(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
        AND trading_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

q_end AS (

    SELECT MAX(trading_dt) AS quarter_end_dt
    FROM se_tr

),

se_tr_q_end AS (

    SELECT symbol, trading_dt, maturity_dt
    FROM (
        SELECT
            se_tr.*
            , ROW_NUMBER() OVER (
                PARTITION BY se_tr.symbol
                ORDER BY se_tr.trading_time DESC, se_tr.sequence DESC
            ) AS rn
        FROM se_tr
        INNER JOIN q_end
            ON q_end.quarter_end_dt = se_tr.trading_dt
    ) ranked
    WHERE rn = 1

),

lsi_q AS (

    SELECT
        ticker_symbol
        , listed_share_quantity
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
        AND ds_snpst_dt = (
            SELECT MAX(l2.ds_snpst_dt)
            FROM {{ ref('atm_listed_share_information') }} l2
            WHERE l2.src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
                AND YEAR(l2.ds_snpst_dt) = YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                AND QUARTER(l2.ds_snpst_dt) = QUARTER(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                AND l2.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        )

),

listed AS (

    SELECT
        'LISTED'                                  AS bond_flow_code
        , se_tr_q_end.symbol                      AS bond_code
        , se_tr_q_end.symbol                      AS symbol
        , CAST(NULL AS string)                    AS issuer_name
        , se_tr_q_end.trading_dt                  AS snpst_dt
        , CAST(100000 AS decimal(23,2))           AS par_val
        , CAST(lsi_q.listed_share_quantity AS decimal(23,2)) AS outstanding_vol
        , se_tr_q_end.maturity_dt                 AS maturity_dt
    FROM se_tr_q_end
    LEFT JOIN lsi_q
        ON lsi_q.ticker_symbol = se_tr_q_end.symbol

),

pr_of_ranked AS (

    SELECT
        bond_code
        , issuer_nm
        , rpt_year
        , rpt_month
        , par_val
        , offering_bond_quantity
        , maturity_dt
        , ROW_NUMBER() OVER (
            PARTITION BY bond_code
            ORDER BY posting_dt DESC
        ) AS rn
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND CAST(rpt_year AS INT) = YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
        AND CAST(rpt_month AS INT) = QUARTER(to_date('{{ var("etl_date") }}','yyyy-MM-dd')) * 3

),

private AS (

    SELECT
        'PRIVATE'                                 AS bond_flow_code
        , pr_of_ranked.bond_code                  AS bond_code
        , CAST(NULL AS string)                    AS symbol
        , pr_of_ranked.issuer_nm                  AS issuer_name
        , last_day(to_date(CONCAT(pr_of_ranked.rpt_year, LPAD(pr_of_ranked.rpt_month, 2, '0'), '01'),'yyyyMMdd')) AS snpst_dt
        , CAST(pr_of_ranked.par_val AS decimal(23,2)) AS par_val
        , CAST(pr_of_ranked.offering_bond_quantity AS decimal(23,2)) AS outstanding_vol
        , pr_of_ranked.maturity_dt                AS maturity_dt
    FROM pr_of_ranked
    WHERE pr_of_ranked.rn = 1

),

all_bond AS (

    SELECT * FROM listed
    UNION ALL
    SELECT * FROM private

),

pu_co AS (

    SELECT
        pc_id
        , pc_nm
        , equity_ticker_symbol
        , ROW_NUMBER() OVER (PARTITION BY equity_ticker_symbol ORDER BY pc_id) AS rn_ticker
        , ROW_NUMBER() OVER (PARTITION BY pc_nm ORDER BY pc_id) AS rn_nm
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'

),

bond_eval AS (

    SELECT
        pc_id
        , ranking_code
        , evaluation_year
        , evaluation_month
    FROM {{ ref('atm_pc_bond_evaluation') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_CBONDS'

),

joined AS (

    SELECT
        all_bond.*
        , COALESCE(pc_tk.pc_id, pc_nm.pc_id) AS pc_id
    FROM all_bond
    LEFT JOIN pu_co pc_tk
        ON all_bond.bond_flow_code = 'LISTED'
        AND pc_tk.rn_ticker = 1
        AND pc_tk.equity_ticker_symbol = SUBSTR(all_bond.symbol, 1, 3)
    LEFT JOIN pu_co pc_nm
        ON all_bond.bond_flow_code = 'PRIVATE'
        AND pc_nm.rn_nm = 1
        AND pc_nm.pc_nm = all_bond.issuer_name

)

SELECT
    CAST(date_format(joined.snpst_dt, 'yyyyMMdd') AS string)                              AS snpst_dt_dim_id,
    CAST(se_dim.securities_dim_id AS string)                                              AS securities_dim_id,
    CAST(bond_eval.ranking_code AS string)                                                AS ranking_code,
    CAST(joined.bond_flow_code AS string)                                                 AS bond_flow_code,
    CAST(joined.bond_code AS string)                                                      AS bond_code,
    CAST(joined.par_val AS decimal(23,2))                                                 AS par_val,
    CAST(joined.outstanding_vol AS decimal(23,2))                                         AS outstanding_vol,
    CAST(joined.par_val * joined.outstanding_vol AS decimal(23,2))                        AS bond_outstanding_val,
    CAST(joined.maturity_dt AS date)                                                      AS maturity_dt,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd')              AS data_dt
FROM joined
LEFT JOIN {{ ref('dtm_securities_dim') }} se_dim
    ON joined.bond_flow_code = 'LISTED'
    AND se_dim.symbol = joined.symbol
LEFT JOIN bond_eval
    ON bond_eval.pc_id = joined.pc_id
    AND bond_eval.evaluation_year = YEAR(joined.snpst_dt)
    AND bond_eval.evaluation_month = MONTH(joined.snpst_dt)
