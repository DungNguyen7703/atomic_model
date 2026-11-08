-- [FIRST-TIME] ft_dtm_fct_corporate_bond_maturity_wall: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_corporate_bond_maturity_wall (config ft_target='fct_corporate_bond_maturity_wall', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_maturity_wall
* Program name: Fact Corporate Bond Maturity Wall (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_corporate_bond_maturity_wall, GIONG daily chay tung ngay giao dich D:
*									- moi ngay giao dich D (co ban tin trai phieu stock_tp_code = '1') sinh 1 lat data_dt = D (partition data_dt nhu daily);
*									  ngay chot quy cua lat do = phien cuoi quy TINH DEN D (= D khi D la phien giao dich) -> snpst_dt_dim_id = D.
*									- LISTED: ban tin cuoi ngay (ma, D); KLNY HNX = snapshot listed_share_information moi nhat trong quy cua D va <= D (as-of theo D).
*									- PRIVATE: dot chao ban dung snapshot ds_snpst_dt = D (atomic KHONG co ft -> chi co du lieu cho cac ngay atomic da chay), ky = thang cuoi quy cua D.
*									- dim cong ty / xep hang / chung khoan: doc _hstr dung ds_snpst_dt = D va ACTIVE (daily doc dung _hstr ngay etl_date; securities_dim doc MAIN).
*									- cot cuoi SELECT: data_dt = D (string yyyy-MM-dd), khop partition_by cua daily.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo data_dt cua tung dong

WITH se_tr_all AS (

    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , trading_time
        , sequence
        , maturity_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE stock_tp_code = '1'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )
    -- [BACKFILL-UAT-ORIG]     AND YEAR(trading_dt) = YEAR(etl_date) AND QUARTER(trading_dt) = QUARTER(etl_date) AND trading_dt <= etl_date

),

-- [BACKFILL-UAT-NEW] se_tr_q_end: moi ngay D la ngay chot quy cua chinh no (phien cuoi quy tinh den D = D) -> ban tin cuoi ngay moi ma tai D
se_tr_q_end AS (

    SELECT symbol, trading_dt AS d, maturity_dt
    FROM se_tr_all
    WHERE rn = 1

),

days AS (

    SELECT DISTINCT d FROM se_tr_q_end

),

lsi_dates AS (

    SELECT DISTINCT ds_snpst_dt
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'

),

-- [BACKFILL-UAT-NEW] daily: ds_snpst_dt = MAX(ds_snpst_dt) trong quy cua etl_date va <= etl_date -> moi ngay D chon 1 ngay snapshot listed
d_lsi AS (

    SELECT
        days.d
        , MAX(lsi_dates.ds_snpst_dt) AS lsi_dt
    FROM days
    INNER JOIN lsi_dates
        ON YEAR(lsi_dates.ds_snpst_dt) = YEAR(days.d)
        AND QUARTER(lsi_dates.ds_snpst_dt) = QUARTER(days.d)
        AND lsi_dates.ds_snpst_dt <= days.d
    GROUP BY days.d

),

lsi_q AS (

    SELECT
        d_lsi.d
        , lsi.ticker_symbol
        , lsi.listed_share_quantity
    FROM d_lsi
    INNER JOIN {{ ft_ref('ft_atm_listed_share_information') }} lsi   -- [BACKFILL-UAT-NEW] ft_ref
        ON lsi.ds_snpst_dt = d_lsi.lsi_dt
        AND lsi.src_stm_code = 'HNX_LISTED_SECURITIES_LIST'

),

listed AS (

    SELECT
        'LISTED'                                  AS bond_flow_code
        , se_tr_q_end.symbol                      AS bond_code
        , se_tr_q_end.symbol                      AS symbol
        , CAST(NULL AS string)                    AS issuer_name
        , se_tr_q_end.d                           AS snpst_dt
        , se_tr_q_end.d                           AS d
        , CAST(100000 AS decimal(23,2))           AS par_val
        , CAST(lsi_q.listed_share_quantity AS decimal(23,2)) AS outstanding_vol
        , se_tr_q_end.maturity_dt                 AS maturity_dt
    FROM se_tr_q_end
    LEFT JOIN lsi_q
        ON lsi_q.d = se_tr_q_end.d
        AND lsi_q.ticker_symbol = se_tr_q_end.symbol

),

pr_of_ranked AS (

    SELECT
        ds_snpst_dt AS d
        , bond_code
        , issuer_nm
        , rpt_year
        , rpt_month
        , par_val
        , offering_bond_quantity
        , maturity_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ds_snpst_dt, bond_code
            ORDER BY posting_dt DESC
        ) AS rn
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND CAST(rpt_year AS INT) = YEAR(ds_snpst_dt)
        AND CAST(rpt_month AS INT) = QUARTER(ds_snpst_dt) * 3
    -- [BACKFILL-UAT-ORIG]     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd') ... (daily: ds_snpst_dt = etl_date; nam/quy so voi etl_date)

),

private AS (

    SELECT
        'PRIVATE'                                 AS bond_flow_code
        , pr_of_ranked.bond_code                  AS bond_code
        , CAST(NULL AS string)                    AS symbol
        , pr_of_ranked.issuer_nm                  AS issuer_name
        , last_day(to_date(CONCAT(pr_of_ranked.rpt_year, LPAD(pr_of_ranked.rpt_month, 2, '0'), '01'),'yyyyMMdd')) AS snpst_dt
        , pr_of_ranked.d                          AS d
        , CAST(pr_of_ranked.par_val AS decimal(23,2)) AS par_val
        , CAST(pr_of_ranked.offering_bond_quantity AS decimal(23,2)) AS outstanding_vol
        , pr_of_ranked.maturity_dt                AS maturity_dt
    FROM pr_of_ranked
    WHERE pr_of_ranked.rn = 1

),

all_bond AS (

    SELECT bond_flow_code, bond_code, symbol, issuer_name, snpst_dt, d, par_val, outstanding_vol, maturity_dt FROM listed
    UNION ALL
    SELECT bond_flow_code, bond_code, symbol, issuer_name, snpst_dt, d, par_val, outstanding_vol, maturity_dt FROM private

),

pu_co AS (

    SELECT
        ds_snpst_dt AS d
        , pc_id
        , pc_nm
        , equity_ticker_symbol
        , ROW_NUMBER() OVER (PARTITION BY ds_snpst_dt, equity_ticker_symbol ORDER BY pc_id) AS rn_ticker
        , ROW_NUMBER() OVER (PARTITION BY ds_snpst_dt, pc_nm ORDER BY pc_id) AS rn_nm
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
    -- [BACKFILL-UAT-ORIG]     AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

bond_eval AS (

    SELECT
        ds_snpst_dt AS d
        , pc_id
        , ranking_code
        , evaluation_year
        , evaluation_month
    FROM {{ ref('atm_pc_bond_evaluation') }}_hstr
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_CBONDS'
    -- [BACKFILL-UAT-ORIG]     AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

joined AS (

    SELECT
        all_bond.*
        , COALESCE(pc_tk.pc_id, pc_nm.pc_id) AS pc_id
    FROM all_bond
    LEFT JOIN pu_co pc_tk
        ON all_bond.bond_flow_code = 'LISTED'
        AND pc_tk.d = all_bond.d
        AND pc_tk.rn_ticker = 1
        AND pc_tk.equity_ticker_symbol = SUBSTR(all_bond.symbol, 1, 3)
    LEFT JOIN pu_co pc_nm
        ON all_bond.bond_flow_code = 'PRIVATE'
        AND pc_nm.d = all_bond.d
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
    date_format(joined.d, 'yyyy-MM-dd')                                                   AS data_dt   -- [BACKFILL-UAT-NEW] = ngay chay daily D (partition_by data_dt)
FROM joined
LEFT JOIN {{ ft_ref('ft_dtm_securities_dim') }}_hstr se_dim   -- [BACKFILL-UAT-NEW] doc _hstr theo NGAY D (daily doc MAIN tai etl_date)
    ON joined.bond_flow_code = 'LISTED'
    AND se_dim.ds_snpst_dt = joined.d
    AND se_dim.ds_rcrd_st = 'ACTIVE'
    AND se_dim.symbol = joined.symbol
LEFT JOIN bond_eval
    ON bond_eval.d = joined.d
    AND bond_eval.pc_id = joined.pc_id
    AND bond_eval.evaluation_year = YEAR(joined.snpst_dt)
    AND bond_eval.evaluation_month = MONTH(joined.snpst_dt)
