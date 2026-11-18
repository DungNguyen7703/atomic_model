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
    FROM {{ ref('ods_vsdc_major_shareholder') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
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
FROM mj_sh
