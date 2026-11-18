/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_market_snpst
* Program name: Fact Corporate Bond Market Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_security_trading_snapshot da duoc grep xac nhan TON TAI va CO san
*   cot maturity_dt (xem file atomic/product/atm_security_trading_snapshot.sql,
*   dong ANS maturity_dt) -> cot maturity_pressure_12_months / _previous /
*   _growth_percentage duoi day la TINH DUOC, KHONG PENDING.
* - Model duoc materialize theo strategy incremental_rebase/snapshot,
*   partition_by ds_snpst_dt, KHONG phai SCD4A nen KHONG co bang phu _hstr
*   va KHONG co cot ds_rcrd_st -> chi loc theo dung nhu quy uoc da thay o
*   models/datamart/PTTT/fct_corporate_bond_sector_snpst/dtm_fct_corporate_bond_sector_snpst.sql
*   va models/datamart/NDTNN/dtm_securities_dim.sql (KHONG dung hau to
*   "_hstr" nhu mo ta ban dau trong yeu cau, vi day khong phai bang SCD4A).
* - maturity_pressure_12_months / _previous can gia tri cua nhung ngay giao
*   dich TRUOC do (LAG theo trading_dt) nen CTE agg PHAI quet toan bo
*   atm_security_trading_snapshot (khong loc ds_snpst_dt = etl_date), sau do
*   moi loc ra dung 1 dong cua ngay etl_date o SELECT cuoi cung. Day la
*   danh doi bat buoc de tinh dung cong thuc "so voi ky truoc" trong 1
*   model dang incremental/append theo ngay.
* - par_val = 100000 hardcode theo business rule da chot (giong
*   dtm_fct_corporate_bond_sector_snpst.sql).
* - CANH BAO - DOI CHIEU LLD MOI (DTM_PTTT_fct_corporate_bond_market_snpst.csv,
*   ban cap nhat 2026-08-06): LLD MOI CHI con dinh nghia 7 cot duoi day
*   (snpst_dt_dim_id, par_val, outstanding_vol, bond_outstanding_val,
*   maturity_pressure_12_months, maturity_pressure_12_months_previous,
*   maturity_pressure_growth_percentage) -> 2 cot total_trading_val_bond va
*   ytm_average (PENDING o ban truoc, cho Atomic Corporate Bond Match Log
*   O_PTTT_7) DA BI LOAI KHOI THIET KE MOI, nen DA XOA khoi output cua model
*   nay. Da grep lai models/atomic/ (2026-09-23): van CHUA co atomic model
*   rieng cho khop lenh trai phieu kem YTM (chi co atm_security_match_log.sql
*   dung chung moi loai CK, khong loc rieng duoc trai phieu/khong co YTM; va
*   atm_corporate_bond_trading_snapshot.sql - nguon MDDS_JAD_CORPBONDINFOR -
*   co total_trading_val nhung KHONG co cot YTM), nhung khong con can thiet
*   vi LLD moi khong yeu cau 2 cot nay o bang nay nua.
* - CAP NHAT 2026-10-01 (LLD ban 2026-10-01, changelog Phan 5): THEM 2 cot
*   bond_trading_val va bond_yield_weighted_average (BA dong 305/307).
*   + bond_trading_val = SUM(securities_trade.execution_val) WHERE
*     market_id_code='BDO' (HOSE + HNX) trong ngay etl_date.
*   + bond_yield_weighted_average = SUM(yield*GTGD_ma)/SUM(GTGD_ma); yield
*     lay tu atm_security_trading_snapshot (src MDDS_JAD_STOCKINFOR,
*     floor_code='06', yield IS NOT NULL, ban ghi CUOI NGAY theo
*     trading_time DESC); INNER JOIN nhu SQL BA: ma khong co YTM hoac khong
*     co giao dich trong ngay bi loai khoi ca tu va mau. (Open issue
*     O_PTTT_29: khoa noi ma TP HNX Issue_Code, execution_val HNX.)
*   + Do model la incremental_rebase/snapshot (INSERT theo VI TRI cot) nen 2
*     cot moi PHAI nam CUOI SELECT va ALTER ... ADD COLUMN ... AFTER
*     maturity_pressure_growth_percentage.
* - CAP NHAT 2026-10-05 (LLD commit 768dd18b, BA HNX Nhom 18, O_PTTT_36): doi nguon TPDN
*   + Loc trai phieu stock_tp_code = '1' + loai TP Chinh phu/dia phuong (regex
*     ^[A-Za-z]{2}GB, ^(TD|TP|CP|QH|KB|BL), ^(HCM|HAN)) thay IN ('B','1','D').
*   + outstanding_vol = SUM(atm_listed_share_information.listed_share_quantity) (src
*     HNX_LISTED_SECURITIES_LIST, ticker_symbol = symbol, ds_snpst_dt = trading_dt) + TP rieng
*     le SUM(atm_private_corp_bond_registration.outstanding_bond_quantity) WHERE rpt_month =
*     yyyyMM(trading_dt). maturity_pressure_12_months: ca 2 nhanh, dao han trong (d, d+12 thang].
*     Nhanh rieng le: last_day(rpt_month) >= d (theo LLD). atm_private_corp_bond_registration
*     la snapshot theo ds_snpst_dt -> dedup (bond_code, rpt_month) lay ds_snpst_dt moi nhat.
*   + bond_trading_val / bond_yield_weighted_average: market_id_code = 'HCX' va CHI so lenh HNX
*     (ORDERTRADE_TRADE_BOOK_HNX) thay cho 'BDO' HOSE+HNX; YTM loc stock_tp_code = '1' thay
*     floor_code = '06'.
*   + LLD market_snpst KHONG ghi dedup ban ghi cuoi phien cho security_trading_snapshot (2 LLD
*     sector/opr thi co) -> van dedup (symbol, trading_dt) theo trading_time DESC, neu khong
*     SUM bi nhan theo so ban ghi trong ngay. Cot output KHONG doi -> khong can ALTER.
*--------------------------------------------------------------------*
* 2026-10-05b			tuan.nguyenvanb		LLD (commit 96bfadb3): cot khoi luong HNX doi tu outstanding_share_quantity
*									sang listed_share_quantity (HNX listed_shares - "tam thay outstanding_shares
*									cua BA", O_PTTT_36). Chi doi ten cot nguon, logic giu nguyen. Cot output KHONG
*									doi -> khong can ALTER.
* 2026-10-19			tuan.nguyenvanb		[LLD d5b4e8b7] Chuan hoa ten cot nguon Atomic cua atm_private_corp_bond_registration:
*									report_month -> rpt_month, maturity_date -> maturity_dt (chi doi ten cot doc nguon, KHONG doi
*									cot output/logic/vi tri cot cua mart nen khong can ALTER).
* 2026-10-20			tuan.nguyenvanb		[LLD O_PTTT_53] atomic rpt_month CHI luu so thang ('10','1'), nam nam rieng o rpt_year -> bo so sanh
*									rpt_month = yyyyMM: outstanding_vol dung CAST(rpt_year AS INT)=YEAR(trading_dt) AND CAST(rpt_month AS INT)=
*									MONTH(trading_dt); maturity_pressure dung CONCAT(rpt_year, LPAD(rpt_month,2,'0'),'01'). Dedupe pr_all them
*									rpt_year vao PARTITION BY (thang cua cac nam khac nhau khong duoc gop). Khong doi cot output.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-10-27			tuan.nguyenvanb		lsi_hnx loc ds_snpst_dt = etl_date; pr_all chi lay ky (nam-thang) gan nhat <= thang cua etl_date (chua co ky thang hien tai thi lui thang/nam);
*									agg_private bo dieu kien nam-thang = trading_dt va last_day(rpt_month) >= trading_dt (da loc ky o pr_all). Khong doi cot output.
* 2026-10-27			tuan.nguyenvanb		[TACH NIEM YET / RIENG LE] THEM 6 COT CUOI SELECT: outstanding_vol_listed/_private, bond_outstanding_val_listed/_private,
*									maturity_pressure_12_months_listed/_private (cac cot tong giu nguyen). bond_trading_val / bond_yield_weighted_average
*									van chi tinh cho niem yet (HNX HCX), khong tach. Model insert theo VI TRI -> 6 cot moi PHAI nam cuoi va ALTER ... ADD COLUMN ... AFTER
*									bond_yield_weighted_average dung thu tu cot nhu trong SELECT cuoi.
* 2026-10-27			tuan.nguyenvanb		lsi_hnx loc ds_snpst_dt BETWEEN etl_date-15 AND etl_date (truoc chi = etl_date -> LAG lay listed phien truoc = 0 -> previous = 0,
*									maturity_pressure_growth_percentage NULL). Khong doi cot output.
*									ytm_ranked: noi theo isin_code (so lenh HCX dung ISIN, truoc noi ticker_symbol -> 0/37 khop -> bond_yield_weighted_average NULL);
*									xep hang ban tin cuoi truoc roi moi loai yield NULL (nhu BA). Khong doi cot output.
*/

WITH se_tr_all AS (

    SELECT
        trading_dt
        , ticker_symbol AS symbol
        , maturity_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE stock_tp_code = '1'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )

),

se_tr AS (

    SELECT trading_dt, symbol, maturity_dt
    FROM se_tr_all
    WHERE rn = 1

),

lsi_hnx AS (

    SELECT
        ticker_symbol
        , ds_snpst_dt
        , listed_share_quantity
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
        AND ds_snpst_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 15) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

agg_listed AS (

    SELECT
        se_tr.trading_dt
        , SUM(lsi_hnx.listed_share_quantity) AS outstanding_vol
        , SUM(
            CASE
                WHEN se_tr.maturity_dt > se_tr.trading_dt
                    AND se_tr.maturity_dt <= add_months(se_tr.trading_dt, 12)
                    THEN lsi_hnx.listed_share_quantity * 100000
                ELSE 0
            END
        ) AS maturity_pressure_12_months
    FROM se_tr
    INNER JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = se_tr.symbol
        AND lsi_hnx.ds_snpst_dt = se_tr.trading_dt
    GROUP BY se_tr.trading_dt

),

pr_latest AS (

    SELECT
        bond_code
        , rpt_year
        , rpt_month
        , maturity_dt
        , outstanding_bond_quantity
    FROM {{ ref('atm_private_corp_bond_registration') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
        AND CONCAT(rpt_year, LPAD(rpt_month, 2, '0')) = (
            SELECT MAX(CONCAT(rpt_year, LPAD(rpt_month, 2, '0')))
            FROM {{ ref('atm_private_corp_bond_registration') }}
            WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
                AND CONCAT(rpt_year, LPAD(rpt_month, 2, '0')) <= date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMM')
        )

),

trading_dates AS (

    SELECT DISTINCT trading_dt FROM se_tr

),

agg_private AS (

    SELECT
        trading_dates.trading_dt
        , SUM(pr_latest.outstanding_bond_quantity) AS outstanding_vol
        , SUM(
            CASE
                WHEN pr_latest.maturity_dt > trading_dates.trading_dt
                    AND pr_latest.maturity_dt <= add_months(trading_dates.trading_dt, 12)
                    THEN pr_latest.outstanding_bond_quantity * 100000
                ELSE 0
            END
        ) AS maturity_pressure_12_months
    FROM trading_dates
    CROSS JOIN pr_latest
    GROUP BY trading_dates.trading_dt

),

agg AS (

    SELECT
        trading_dates.trading_dt
        , COALESCE(agg_listed.outstanding_vol, 0) + COALESCE(agg_private.outstanding_vol, 0) AS outstanding_vol
        , COALESCE(agg_listed.maturity_pressure_12_months, 0) + COALESCE(agg_private.maturity_pressure_12_months, 0) AS maturity_pressure_12_months
        , COALESCE(agg_listed.outstanding_vol, 0) AS outstanding_vol_listed
        , COALESCE(agg_private.outstanding_vol, 0) AS outstanding_vol_private
        , COALESCE(agg_listed.maturity_pressure_12_months, 0) AS maturity_pressure_12_months_listed
        , COALESCE(agg_private.maturity_pressure_12_months, 0) AS maturity_pressure_12_months_private
    FROM trading_dates
    LEFT JOIN agg_listed
        ON agg_listed.trading_dt = trading_dates.trading_dt
    LEFT JOIN agg_private
        ON agg_private.trading_dt = trading_dates.trading_dt

),

with_lag AS (

    SELECT
        agg.trading_dt
        , agg.outstanding_vol
        , agg.maturity_pressure_12_months
        , agg.outstanding_vol_listed
        , agg.outstanding_vol_private
        , agg.maturity_pressure_12_months_listed
        , agg.maturity_pressure_12_months_private
        , LAG(agg.maturity_pressure_12_months) OVER (ORDER BY agg.trading_dt) AS maturity_pressure_12_months_previous
    FROM agg

),

bond_trade AS (

    SELECT
        trade_dt
        , security_symbol_code
        , SUM(execution_val) AS gtgd_ma_tp
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code = 'HCX'
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
        AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY
        trade_dt
        , security_symbol_code

),

bond_trade_total AS (

    SELECT
        trade_dt
        , SUM(gtgd_ma_tp) AS bond_trading_val
    FROM bond_trade
    GROUP BY trade_dt

),

ytm_ranked AS (

    SELECT
        isin_code AS symbol
        , trading_dt
        , yield
        , ROW_NUMBER() OVER (
            PARTITION BY isin_code, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code = '1'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

ytm_weighted AS (

    SELECT
        bond_trade.trade_dt
        , SUM(ytm_ranked.yield * bond_trade.gtgd_ma_tp) / NULLIF(SUM(bond_trade.gtgd_ma_tp), 0) AS bond_yield_weighted_average
    FROM bond_trade
    INNER JOIN ytm_ranked
        ON ytm_ranked.symbol = bond_trade.security_symbol_code
        AND ytm_ranked.trading_dt = bond_trade.trade_dt
        AND ytm_ranked.rn = 1
        AND ytm_ranked.yield IS NOT NULL
    GROUP BY bond_trade.trade_dt

)

SELECT
    CAST(date_format(with_lag.trading_dt, 'yyyyMMdd') AS string)                AS snpst_dt_dim_id,
    CAST(100000 AS decimal(23,2))                                               AS par_val,
    CAST(with_lag.outstanding_vol AS decimal(23,2))                             AS outstanding_vol,
    CAST(100000 * with_lag.outstanding_vol AS decimal(23,2))                    AS bond_outstanding_val,
    CAST(with_lag.maturity_pressure_12_months AS decimal(23,2))                 AS maturity_pressure_12_months,
    CAST(with_lag.maturity_pressure_12_months_previous AS decimal(23,2))        AS maturity_pressure_12_months_previous,
    CAST(
        (with_lag.maturity_pressure_12_months - with_lag.maturity_pressure_12_months_previous)
        / NULLIF(with_lag.maturity_pressure_12_months_previous, 0) * 100
    AS decimal(5,2))                                                            AS maturity_pressure_growth_percentage,
    CAST(bond_trade_total.bond_trading_val AS decimal(23,2))                    AS bond_trading_val,
    CAST(ytm_weighted.bond_yield_weighted_average AS decimal(9,4))              AS bond_yield_weighted_average,
    CAST(with_lag.outstanding_vol_listed AS decimal(23,2))                      AS outstanding_vol_listed,
    CAST(with_lag.outstanding_vol_private AS decimal(23,2))                     AS outstanding_vol_private,
    CAST(100000 * with_lag.outstanding_vol_listed AS decimal(23,2))             AS bond_outstanding_val_listed,
    CAST(100000 * with_lag.outstanding_vol_private AS decimal(23,2))            AS bond_outstanding_val_private,
    CAST(with_lag.maturity_pressure_12_months_listed AS decimal(23,2))          AS maturity_pressure_12_months_listed,
    CAST(with_lag.maturity_pressure_12_months_private AS decimal(23,2))         AS maturity_pressure_12_months_private
FROM with_lag
LEFT JOIN bond_trade_total
    ON bond_trade_total.trade_dt = with_lag.trading_dt
LEFT JOIN ytm_weighted
    ON ytm_weighted.trade_dt = with_lag.trading_dt
WHERE with_lag.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
