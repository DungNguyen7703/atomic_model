/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_autoroutepartindex
* Program name: Staging TTHC.AUTOROUTEPARTINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(documentid AS int)                AS documentid
    , CAST(contentitemid AS string)          AS contentitemid
    , CAST(containedcontentitemid AS string) AS containedcontentitemid
    , CAST(jsonpath AS string)               AS jsonpath
    , CAST(path AS string)                   AS path
    , CAST(published AS decimal(38,0))       AS published
    , CAST(latest AS decimal(38,0))          AS latest
FROM {{ source('source_tthc', 'raw_autoroutepartindex') }}