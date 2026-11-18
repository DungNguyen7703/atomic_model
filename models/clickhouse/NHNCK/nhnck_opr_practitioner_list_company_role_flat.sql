-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_list_company_role_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        sc_shareholder_code,
        securities_company_code,
        securities_company_short_nm,
        representative_position,
        practice_status_code,
        practice_status_nm,
        shares_held,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_list_company_role') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    sc_shareholder_code,
    securities_company_code,
    securities_company_short_nm,
    representative_position,
    practice_status_code,
    practice_status_nm,
    shares_held,
    src_stm_code

FROM src
