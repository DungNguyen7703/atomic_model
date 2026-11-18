/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_gov_bond_additional_listing
* Program name: ODS HNX.GOV_BOND_ADDITIONAL_LISTING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bond_code AS string)              AS bond_code
    , CAST(bond_type AS string)             AS bond_type
    , CAST(status AS string)                AS status
    , CAST(volume AS bigint)                AS volume
    , CAST(par_value AS decimal(18,2))      AS par_value
    , CAST(listing_change_date AS date)     AS listing_change_date
    , CAST(report_month AS string)          AS report_month
    , CAST(ds_snpst_dt AS date)             AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_gov_bond_additional_listing') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
