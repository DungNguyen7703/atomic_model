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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(userbyrolenameindexid AS int) AS userbyrolenameindexid
    , CAST(documentid AS bigint)         AS documentid
FROM {{ source('source_tthc', 'raw_userbyrolenameindex_document') }}