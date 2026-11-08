/*
*--------------------------------------------------------------------*
* Program code: stg_ids_bond_collateral
* Program name: Staging IDS.BOND_COLLATERAL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(bond_ticker AS string)               AS bond_ticker
    , CAST(company_name AS string)              AS company_name
    , CAST(business_reg_no AS string)           AS business_reg_no
    , CAST(issuance_qty AS decimal(19,0))       AS issuance_qty
    , CAST(collateral AS string)                AS collateral
    , CAST(collateral_type AS string)           AS collateral_type
    , CAST(advisory_organization AS string)     AS advisory_organization
    , CAST(depository_agent AS string)          AS depository_agent
    , CAST(issuance_agent AS string)            AS issuance_agent
    , CAST(bondholder_representative AS string) AS bondholder_representative
    , CAST(underwriter AS string)               AS underwriter
    , CAST(collateral_value AS decimal(19,0))   AS collateral_value
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
FROM {{ source('source_ids', 'raw_bond_collateral') }}