/*
*--------------------------------------------------------------------*
* Program code: stg_knt_catalog_group
* Program name: Staging KNT.CATALOG_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)      AS id
    , CAST(code AS string) AS code
    , CAST(name AS string) AS name
    , CAST(status AS int)  AS status
    , CAST(type AS int)    AS type
FROM {{ source('source_knt', 'raw_catalog_group') }}