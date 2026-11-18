-- Program code: pttt_opr_corporate_bond_issuer_credit_monitor_flat
-- Program name: Flat table Operational Corporate Bond Issuer Credit Monitor
-- Source mart model: dtm_opr_corporate_bond_issuer_credit_monitor
-- Joined dimension: none
-- Grain: 1 row per bond issuer per snapshot date
-- Filter: only rows where snpst_dt equals etl_date
-- Note: No calendar join and no dimension join. The grain is a real date column named snpst_dt, not snpst_dt_dim_id. Same pattern as the GSTT public company shareholding flat.
-- Modified: 2026-10-15 add header comment, no logic change
-- Modified: 2026-11-06 tuan.nguyenvanb: them cot financial_period_end_dt sau roe_pct (flat ghi theo VI TRI cot -> ALTER ADD COLUMN AFTER roe_pct).

SELECT
    f.issuer_symbol_code,
    f.snpst_dt,
    f.bond_outstanding_val,
    f.par_val,
    f.outstanding_vol,
    f.audit_opinion_text,
    f.ranking_code,
    f.risk_rating_text,
    f.total_liabilities_amt,
    f.owner_equity_ending_amt,
    f.owner_equity_beginning_amt,
    f.owner_equity_average_amt,
    f.net_profit_after_tax_amt,
    f.debt_to_equity_ratio,
    f.roe_pct,
    f.financial_period_end_dt
FROM {{ ref('dtm_opr_corporate_bond_issuer_credit_monitor') }} f
WHERE f.snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
