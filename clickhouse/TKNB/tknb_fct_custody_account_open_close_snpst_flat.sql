-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_custody_account_open_close_snpst
-- Type  : FACT
-- Dim   : dtm_depository_member_dim (TKNB)
-- Ghi chu: Fact nap lai moi thang <= etl_date (period_val), nen khong loc snpst_dt_dim_id = etl_date;
--          moi lan chay ghi toan bo lich su vao partition ds_snpst_dt = etl_date.
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        depository_member_dim_id,
        row_nbr,
        opening_domestic_individual_account_quantity,
        opening_domestic_institution_account_quantity,
        opening_foreign_individual_account_quantity,
        opening_foreign_institution_account_quantity,
        opened_domestic_individual_account_quantity,
        opened_domestic_institution_account_quantity,
        opened_foreign_individual_account_quantity,
        opened_foreign_institution_account_quantity,
        closed_domestic_individual_account_quantity,
        closed_domestic_institution_account_quantity,
        closed_foreign_individual_account_quantity,
        closed_foreign_institution_account_quantity,
        closing_domestic_individual_account_quantity,
        closing_domestic_institution_account_quantity,
        closing_foreign_individual_account_quantity,
        closing_foreign_institution_account_quantity,
        total_account_quantity,
        src_stm_code
    FROM {{ ref('dtm_fct_custody_account_open_close_snpst') }}
),

dim_member AS (
    SELECT
        depository_member_dim_id,
        depository_member_nm
    FROM {{ ref('dtm_depository_member_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ISS_INTERNAL_STATISTICAL_REPORT'
)

SELECT
    f.snpst_dt_dim_id,
    f.depository_member_dim_id,
    f.row_nbr,
    f.opening_domestic_individual_account_quantity,
    f.opening_domestic_institution_account_quantity,
    f.opening_foreign_individual_account_quantity,
    f.opening_foreign_institution_account_quantity,
    f.opened_domestic_individual_account_quantity,
    f.opened_domestic_institution_account_quantity,
    f.opened_foreign_individual_account_quantity,
    f.opened_foreign_institution_account_quantity,
    f.closed_domestic_individual_account_quantity,
    f.closed_domestic_institution_account_quantity,
    f.closed_foreign_individual_account_quantity,
    f.closed_foreign_institution_account_quantity,
    f.closing_domestic_individual_account_quantity,
    f.closing_domestic_institution_account_quantity,
    f.closing_foreign_individual_account_quantity,
    f.closing_foreign_institution_account_quantity,
    f.total_account_quantity,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    dim.depository_member_nm
FROM fact f
LEFT JOIN dim_member dim
    ON f.depository_member_dim_id = dim.depository_member_dim_id
