/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_bond_portfolio
* Program name: Atomic Foreign Bond Portfolio
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fr_bo AS (
    SELECT
        trading_code
        , investor_name
        , investor_category
        , nationality
        , address
        , trading_representative_name
        , institutional_investor_type
        , bond_code
        , owned_volume
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_vsdc_foreign_investor_bond_portfolio') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_FOREIGN_INVESTOR_BOND_PORTFOLIO', "concat_ws('-', fr_bo.trading_code, fr_bo.bond_code)") }} AS foreign_bond_portfolio_id
    , CAST(fr_bo.trading_code AS string)                              AS foreign_investor_code
    , CAST('VSDC_FOREIGN_INVESTOR_BOND_PORTFOLIO' AS string)          AS src_stm_code
    , CAST(fr_bo.investor_name AS string)                             AS foreign_investor_name
    , CAST(fr_bo.investor_category AS string)                         AS foreign_investor_tp_code
    , CAST(fr_bo.nationality AS string)                               AS nationality_code
    , CAST(fr_bo.address AS string)                                   AS address
    , CAST(fr_bo.trading_representative_name AS string)               AS trading_representative_nm
    , CAST(fr_bo.institutional_investor_type AS string)               AS institutional_investor_tp
    , CAST(fr_bo.bond_code AS string)                                 AS bond_code
    , CAST(fr_bo.owned_volume AS bigint)                              AS owned_bond_quantity
    , CAST(fr_bo.report_month AS string)                              AS report_month
FROM fr_bo
