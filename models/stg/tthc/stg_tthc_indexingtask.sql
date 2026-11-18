/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_indexingtask
* Program name: Staging TTHC.INDEXINGTASK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(contentitemid AS string) AS contentitemid
    , CAST(createdutc AS string)    AS createdutc
    , CAST(type AS int)             AS type
FROM {{ source('source_tthc', 'raw_indexingtask') }}