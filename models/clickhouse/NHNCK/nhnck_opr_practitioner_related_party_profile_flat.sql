-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_related_party_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        related_party_code,
        related_individual_full_nm,
        rltnp_tp_code,
        rltnp_tp_nm,
        related_individual_occupation,
        related_individual_workplace,
        related_individual_identity_nbr,
        country_code,
        country_nm,
        related_individual_adr,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_related_party_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    related_party_code,
    related_individual_full_nm,
    rltnp_tp_code,
    rltnp_tp_nm,
    related_individual_occupation,
    related_individual_workplace,
    related_individual_identity_nbr,
    country_code,
    country_nm,
    related_individual_adr,
    src_stm_code

FROM src 