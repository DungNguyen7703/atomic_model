-- Program code: pttt_fct_securities_company_balance_snpst_flat
-- Program name: Flat table Fact Securities Company Balance Snapshot
-- Source mart model: dtm_fct_securities_company_balance_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date, and dtm_securities_company_dim history table, taken at the snapshot of etl_date, for company code and name
-- Grain: 1 row per securities company per report quarter
-- Filter: only rows where ds_snpst_dt equals etl_date
-- Note: Filter uses ds_snpst_dt equal to etl_date, not snpst_dt_dim_id.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.rpt_year,
    f.rpt_quarter,
    f.total_liabilities_amt,
    f.owner_equity_amt,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    sc.sc_code,
    sc.sc_nm
FROM {{ ref('dtm_fct_securities_company_balance_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }}_hstr sc
    ON sc.securities_company_dim_id = f.securities_company_dim_id
    AND sc.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
