/*
*--------------------------------------------------------------------*
* Program code: stg_knt_catalog
* Program name: Staging KNT.CATALOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(code AS string)          AS code
    , CAST(name AS string)          AS name
    , CAST(catalog_group_id AS int) AS catalog_group_id
    , CAST(company_type AS int)     AS company_type
FROM {{ source('source_knt', 'raw_catalog') }}