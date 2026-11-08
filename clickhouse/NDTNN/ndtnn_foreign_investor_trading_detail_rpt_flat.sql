-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_foreign_investor_trading_detail_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Foreign Investor Trading Detail Report
    f.report_dt,
    f.account_nbr,
    f.symbol,
    f.trade_direction_code,
    f.account_holder_nm,
    f.investor_nm,
    f.execution_vol,
    f.execution_val,
    f.src_stm_code

FROM {{ ref('dtm_foreign_investor_trading_detail_rpt') }} f
WHERE f.report_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')