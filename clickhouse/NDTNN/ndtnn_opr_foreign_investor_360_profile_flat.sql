-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_opr_foreign_investor_360_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────
WITH src AS (
    SELECT
        investor_code,
        investor_nm,
        nationality_code,
        nationality_nm,
        investor_tp_code,
        investor_tp_nm,
        director_nm,
        custodian_bank_nm,
        src_stm_code,
        investor_status_code,
        investor_status_nm,
        identification_nbr
    FROM {{ ref('dtm_opr_foreign_investor_360_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    investor_code,
    investor_nm,
    nationality_code,
    nationality_nm,
    investor_tp_code,
    investor_tp_nm,
    director_nm,
    custodian_bank_nm,
    src_stm_code,
    investor_status_code,
    investor_status_nm,
    identification_nbr

FROM src