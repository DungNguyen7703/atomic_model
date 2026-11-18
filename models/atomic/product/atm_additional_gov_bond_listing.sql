/*
*--------------------------------------------------------------------*
* Program code: atm_additional_gov_bond_listing
* Program name: Atomic Additional Gov Bond Listing
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH go_al AS (
    SELECT
        bond_code
        , bond_type
        , volume
        , par_value
        , status
        , listing_change_date
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_gov_bond_additional_listing') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_GOV_BOND_ADDITIONAL_LISTING', "concat_ws('-', go_al.bond_code, go_al.status, go_al.listing_change_date)") }} AS additional_gov_bond_listing_id
    , CAST(go_al.bond_code AS string)                    AS bond_code
    , CAST('HNX_GOV_BOND_ADDITIONAL_LISTING' AS string)  AS src_stm_code
    , CAST(go_al.bond_type AS string)                    AS bond_tp
    , CAST(go_al.volume AS bigint)                       AS additional_bond_quantity
    , CAST(go_al.par_value AS bigint)                    AS par_value
    , CAST(go_al.status AS string)                       AS listing_status
    , CAST(go_al.listing_change_date AS date)            AS listing_change_date
    , CAST(go_al.report_month AS string)                 AS report_month
FROM go_al
