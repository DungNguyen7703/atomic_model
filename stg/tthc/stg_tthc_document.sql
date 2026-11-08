/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_document
* Program name: Staging TTHC.DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(type AS string)              AS type
    , CAST(content AS string)           AS content
    , CAST(version AS int)              AS version
    , CAST(sitecontentitemid AS string) AS sitecontentitemid
    , CAST(createdat AS timestamp)      AS createdat
    , CAST(updatedat AS timestamp)      AS updatedat
    , CAST(hasautoroutepart AS string)  AS hasautoroutepart
    , CAST(hasaliaspart AS string)      AS hasaliaspart
    , CAST(hascontainedpart AS string)  AS hascontainedpart
    , CAST(friendlyurl AS string)       AS friendlyurl
    , CAST(criticverdictjson AS string) AS criticverdictjson
FROM {{ source('source_tthc', 'raw_document') }}