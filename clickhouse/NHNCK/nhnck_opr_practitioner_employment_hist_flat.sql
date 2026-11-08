-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_employment_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        organization_employment_rpt_code,
        securities_organization_reference_code,
        securities_organization_reference_nm,
        organization_tp_code,
        organization_tp_nm,
        practitioner_workplace_at_rpt,
        practitioner_position_at_rpt,
        practitioner_department_at_rpt,
        hire_dt,
        termination_dt,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_employment_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    organization_employment_rpt_code,
    securities_organization_reference_code,
    securities_organization_reference_nm,
    organization_tp_code,
    organization_tp_nm,
    practitioner_workplace_at_rpt,
    practitioner_position_at_rpt,
    practitioner_department_at_rpt,
    hire_dt,
    termination_dt,
    src_stm_code

FROM src 