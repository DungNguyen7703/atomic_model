/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_userbyrolenameindex_document
* Program name: Staging TTHC.USERBYROLENAMEINDEX_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(userbyrolenameindexid AS int) AS userbyrolenameindexid
    , CAST(documentid AS int)            AS documentid
FROM {{ source('source_tthc', 'raw_userbyrolenameindex_document') }}