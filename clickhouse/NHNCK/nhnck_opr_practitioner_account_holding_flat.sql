-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_account_holding_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_account_holding_id,
        practitioner_code,
        account_nbr,
        account_holder_nm,
        main_held_securities_code,
        vsdc_held_securities_vol,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_account_holding') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_account_holding_id,
    practitioner_code,
    account_nbr,
    account_holder_nm,
    main_held_securities_code,
    vsdc_held_securities_vol,
    src_stm_code

FROM src
