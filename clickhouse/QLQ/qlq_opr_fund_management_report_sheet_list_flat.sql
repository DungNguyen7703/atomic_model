-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_report_sheet_list_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Report Sheet List
    fmr_sheet_code,
    fmr_code,
    fmr_nm,
    fmr_tp_code,
    rpt_short_code,
    fmr_sheet_nm,
    sheet_short_code,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_report_sheet_list') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'