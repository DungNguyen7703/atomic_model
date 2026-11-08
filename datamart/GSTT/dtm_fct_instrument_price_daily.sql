/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_instrument_price_daily
* Program name: Dtm Fct Instrument Price Daily
* Created by: tuan.nguyenvanb
* Created date: 2026-10-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-06		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_instrument_price_daily.csv, GSTT
*                                       Nhom 34, LLD v4.33-v4.36] Fact nen NGAY theo do min ca ma CK VA
*                                       chi so: 1 dong / Instrument Code / Trade Date. Nguon Atomic
*                                       market_price_snapshot (MDDS JAD_tvhistory1d), kem Doanh thu / LNST
*                                       cua ky BCTC gan nhat da cong bo (rule GSDC, giong
*                                       dtm_fct_stock_portfolio_snpst) - NULL voi dong chi so.
*                                       Khac dtm_fct_security_trading_daily (Nhom 48, chi ma CK).
*                                       [LUU Y] LLD ghi src_stm_code 'MDDS_JAD_TRADINGVIEWHISTORY1DAY';
*                                       atomic atm_market_price_snapshot dung dung gia tri nay cho nen ngay.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

WITH ma_pr_sn AS (
    SELECT
        symbol,
        trading_dt,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ref('atm_market_price_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- 1 cong ty / equity_ticker_symbol (nguon co ticker gan >1 pc_id): uu tien id nguon nho nhat,
-- order theo pc_code (id nguon that), KHONG order theo pc_id (surrogate hash).
pu_co_all AS (
    SELECT
        pc_id,
        equity_ticker_symbol,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint) ASC) AS rn
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

pu_co AS (
    SELECT pc_id, equity_ticker_symbol
    FROM pu_co_all
    WHERE rn = 1
),

-- ============================================================================
-- Doanh thu / LNST ky BCTC gan nhat da cong bo - rule GSDC (LLD v4.32). Cung logic voi
-- revenue_val/npat_val cua dtm_fct_stock_portfolio_snpst (BCTC DINH KY QUY, 1 bao cao/ky
-- HN>TH>ME>RI, ky gan nhat co submission_dt <= etl_date, fr_value dedupe, data_val NOT NULL).
-- ============================================================================
gsdc_fr_periodic AS (
    SELECT fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

gsdc_sub_ranked AS (
    SELECT
        prs.pc_id,
        prs.rpt_year,
        prs.rpt_quarter,
        prs.fr_code,
        ROW_NUMBER() OVER (
            PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter
            ORDER BY
                CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                prs.submission_dt DESC
        ) AS rn0
    FROM {{ ref('atm_pc_report_submission') }} prs
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        AND prs.ds_rcrd_st = 'ACTIVE'
        AND prs.approval_status_code = 'APPROVED'
        AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)
        AND prs.fr_code LIKE '%QUAR'
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        AND prs.rpt_quarter IN (1,2,3,4)
        AND prs.submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

gsdc_sub_anchor AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code
    FROM (
        SELECT
            r.*,
            ROW_NUMBER() OVER (PARTITION BY r.pc_id ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1
        FROM gsdc_sub_ranked r
        WHERE r.rn0 = 1
    ) t
    WHERE rn1 = 1
),

gsdc_fr_value AS (
    SELECT
        a.pc_id,
        a.rpt_year,
        a.rpt_quarter,
        a.fr_code,
        fv.fr_catalog_id,
        fv.row_code,
        fv.column_code,
        fv.cell_val AS data_val,
        ROW_NUMBER() OVER (
            PARTITION BY fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code
            ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC
        ) AS rn
    FROM gsdc_sub_anchor a
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = a.pc_id
        AND fv.rpt_year = a.rpt_year
        AND fv.rpt_quarter = a.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
        AND fv.cell_val IS NOT NULL
),

revenue_val AS (
    SELECT
        v.pc_id,
        SUM(v.data_val) AS revenue
    FROM gsdc_fr_value v
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = v.fr_catalog_id
        AND fc.fr_year = CAST(v.rpt_year AS string)
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = v.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = v.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    WHERE v.rn = 1
    GROUP BY v.pc_id
),

npat_val AS (
    SELECT
        v.pc_id,
        SUM(v.data_val) AS net_profit_after_tax
    FROM gsdc_fr_value v
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = v.fr_catalog_id
        AND fc.fr_year = CAST(v.rpt_year AS string)
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = v.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = v.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    WHERE v.rn = 1
    GROUP BY v.pc_id
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)        AS security_trading_snpst_dim_id,
    CAST(date_format(ma_pr_sn.trading_dt, 'yyyyMMdd') AS string)      AS trade_dt_dim_id,
    CAST(ma_pr_sn.symbol AS string)                                   AS instrument_code,
    CAST(ma_pr_sn.open_price AS decimal(23,2))                        AS open_price,
    CAST(ma_pr_sn.high_price AS decimal(23,2))                        AS high_price,
    CAST(ma_pr_sn.low_price AS decimal(23,2))                         AS low_price,
    CAST(ma_pr_sn.close_price AS decimal(23,2))                       AS close_price,
    CAST(ma_pr_sn.vol AS int)                                         AS vol,
    CAST(revenue_val.revenue AS decimal(23,2))                        AS revenue,
    CAST(npat_val.net_profit_after_tax AS decimal(23,2))              AS net_profit_after_tax
FROM ma_pr_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = ma_pr_sn.symbol
LEFT JOIN pu_co
    ON  pu_co.equity_ticker_symbol = ma_pr_sn.symbol
LEFT JOIN revenue_val
    ON  revenue_val.pc_id = pu_co.pc_id
LEFT JOIN npat_val
    ON  npat_val.pc_id = pu_co.pc_id
