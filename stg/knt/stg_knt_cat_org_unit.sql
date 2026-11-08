/*
*--------------------------------------------------------------------*
* Program code: stg_knt_cat_org_unit
* Program name: Staging KNT.CAT_ORG_UNIT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(org_unit_code AS string)         AS org_unit_code
    , CAST(org_unit_name AS string)         AS org_unit_name
    , CAST(hierarchy_code AS string)        AS hierarchy_code
    , CAST(parent_hierarchy_code AS string) AS parent_hierarchy_code
    , CAST(tax_code AS string)              AS tax_code
    , CAST(address AS string)               AS address
    , CAST(phone AS string)                 AS phone
    , CAST(email AS string)                 AS email
    , CAST(fax AS string)                   AS fax
    , CAST(website AS string)               AS website
    , CAST(org_unit_type AS int)            AS org_unit_type
    , CAST(description AS string)           AS description
    , CAST(last_modified_at AS date)        AS last_modified_at
    , CAST(cat_level AS int)                AS cat_level
FROM {{ source('source_knt', 'raw_cat_org_unit') }}