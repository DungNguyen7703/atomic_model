/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_contentitemindex
* Program name: Staging TTHC.CONTENTITEMINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu int sang bigint (1 cot); kieu decimal(38,0) sang int (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(documentid AS bigint)           AS documentid
    , CAST(contentitemid AS string)        AS contentitemid
    , CAST(contentitemversionid AS string) AS contentitemversionid
    , CAST(latest AS int)                  AS latest
    , CAST(published AS int)               AS published
    , CAST(contenttype AS string)          AS contenttype
    , CAST(modifiedutc AS string)          AS modifiedutc
    , CAST(publishedutc AS string)         AS publishedutc
    , CAST(createdutc AS string)           AS createdutc
    , CAST(owner AS string)                AS owner
    , CAST(author AS string)               AS author
    , CAST(displaytext AS string)          AS displaytext
    , CAST(sitecontentitemid AS string)    AS sitecontentitemid
FROM {{ source('source_tthc', 'raw_contentitemindex') }}