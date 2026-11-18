-- Program code: pttt_fct_securities_company_safety_snpst_flat
-- Program name: Flat table Fact Securities Company Safety Snapshot
-- Source mart model: dtm_fct_securities_company_safety_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_securities_company_dim history table, taken at the snapshot of etl_date, for company code and name
-- Grain: 1 row per securities company per report month, not per trading day
-- Filter: only rows where ds_snpst_dt equals etl_date (the mart writes the whole history of report months into each ds_snpst_dt slice)
-- Note: Renamed on 2026-10-15 to match the design name, the old name was mbr_sfty_per_mbr. Margin debt, owner equity, margin to equity ratio and capital adequacy ratio. Report month end date is the snapshot date.
-- Modified: 2026-10-15 add header comment, no logic change
-- Modified: 2026-10-23 filter by ds_snpst_dt instead of snpst_dt_dim_id (the old filter only returned rows when etl_date was a month end), join dim history at etl_date like balance flat. No column change.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.rpt_year,
    f.period_nbr,
    f.margin_debt_amt,
    f.owner_equity_amt,
    f.owner_equity_period_end_dt,
    f.total_liabilities_amt,
    f.margin_to_equity_ratio,
    f.capital_adequacy_ratio,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    sc_dim.sc_code,
    sc_dim.sc_nm
FROM {{ ref('dtm_fct_securities_company_safety_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }}_hstr sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
    AND sc_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND sc_dim.ds_rcrd_st = 'ACTIVE'
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
