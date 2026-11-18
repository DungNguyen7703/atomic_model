-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_foreign_investor_trading_statistics_rpt_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Foreign Investor Trading Statistics Report
    f.report_dt,
    f.security_tp_group,
    f.buy_val,
    f.sell_val,
    f.total_market_val,
    f.src_stm_code

FROM {{ ref('dtm_foreign_investor_trading_statistics_rpt') }} f
WHERE f.report_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')