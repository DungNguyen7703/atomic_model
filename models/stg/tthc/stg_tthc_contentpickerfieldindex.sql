/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_contentpickerfieldindex
* Program name: Staging TTHC.CONTENTPICKERFIELDINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang int (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(documentid AS int)               AS documentid
    , CAST(contentitemid AS string)         AS contentitemid
    , CAST(contentitemversionid AS string)  AS contentitemversionid
    , CAST(contenttype AS string)           AS contenttype
    , CAST(contentpart AS string)           AS contentpart
    , CAST(contentfield AS string)          AS contentfield
    , CAST(published AS int)                AS published
    , CAST(latest AS int)                   AS latest
    , CAST(selectedcontentitemid AS string) AS selectedcontentitemid
FROM {{ source('source_tthc', 'raw_contentpickerfieldindex') }}