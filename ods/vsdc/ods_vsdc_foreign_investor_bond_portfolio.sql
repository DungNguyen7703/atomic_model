/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_foreign_investor_bond_portfolio
* Program name: ODS VSDC.FOREIGN_INVESTOR_BOND_PORTFOLIO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(trading_code AS string)                 AS trading_code
    , CAST(investor_name AS string)              AS investor_name
    , CAST(investor_category AS string)          AS investor_category
    , CAST(nationality AS string)                AS nationality
    , CAST(address AS string)                    AS address
    , CAST(trading_representative_name AS string) AS trading_representative_name
    , CAST(institutional_investor_type AS string) AS institutional_investor_type
    , CAST(bond_code AS string)                  AS bond_code
    , CAST(owned_volume AS bigint)                AS owned_volume
    , CAST(report_month AS string)                AS report_month
    , CAST(ds_snpst_dt AS date)                   AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_foreign_investor_bond_portfolio') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
