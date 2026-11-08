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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(documentid AS int)              AS documentid
    , CAST(contentitemid AS string)        AS contentitemid
    , CAST(contentitemversionid AS string) AS contentitemversionid
    , CAST(latest AS decimal(38,0))        AS latest
    , CAST(published AS decimal(38,0))     AS published
    , CAST(contenttype AS string)          AS contenttype
    , CAST(modifiedutc AS string)          AS modifiedutc
    , CAST(publishedutc AS string)         AS publishedutc
    , CAST(createdutc AS string)           AS createdutc
    , CAST(owner AS string)                AS owner
    , CAST(author AS string)               AS author
    , CAST(displaytext AS string)          AS displaytext
    , CAST(sitecontentitemid AS string)    AS sitecontentitemid
FROM {{ source('source_tthc', 'raw_contentitemindex') }}