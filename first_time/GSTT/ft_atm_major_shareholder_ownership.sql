-- [FIRST-TIME] ft_atm_major_shareholder_ownership: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_major_shareholder_ownership (config ft_target='major_shareholder_ownership', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_major_shareholder_ownership
* Program name: Atomic Major Shareholder Ownership
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH mj_sh AS (
    SELECT
        ticker_symbol
        , isin_code
        , shareholder_name
        , id_number
        , issue_date
        , contact_address
        , voting_shares
        , begin_period_date
        , begin_period_shares
        , begin_period_ratio
        , end_period_date
        , end_period_shares
        , end_period_ratio
        , notes
        , ds_snpst_dt
    FROM {{ ft_ref('ft_ods_vsdc_major_shareholder') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_MAJOR_SHAREHOLDER', "concat_ws('-', mj_sh.ticker_symbol, mj_sh.id_number)") }} AS major_shareholder_ownership_id
    , CAST('VSDC_MAJOR_SHAREHOLDER' AS string)         AS src_stm_code
    , CAST(mj_sh.ticker_symbol AS string)              AS ticker_symbol
    , CAST(mj_sh.isin_code AS string)                  AS isin_code
    , CAST(mj_sh.shareholder_name AS string)           AS major_shareholder_nm
    , CAST(mj_sh.id_number AS string)                  AS identification_nbr
    , CAST(mj_sh.issue_date AS date)                   AS issue_dt
    , CAST(mj_sh.contact_address AS string)            AS address
    , CAST(mj_sh.voting_shares AS bigint)               AS voting_share_quantity
    , CAST(mj_sh.begin_period_date AS date)            AS opening_balance_date
    , CAST(mj_sh.begin_period_shares AS bigint)         AS opening_share_quantity
    , CAST(mj_sh.begin_period_ratio AS decimal(7,4))   AS opening_ratio
    , CAST(mj_sh.end_period_date AS date)              AS closing_balance_date
    , CAST(mj_sh.end_period_shares AS bigint)           AS closing_share_quantity
    , CAST(mj_sh.end_period_ratio AS decimal(7,4))     AS closing_ratio
    , CAST(mj_sh.notes AS string)                      AS note
    , CAST(mj_sh.ds_snpst_dt AS date) AS ds_snpst_dt  -- [BACKFILL-UAT-NEW] cot ds_snpst_dt (first-time)
FROM mj_sh
