/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_containedpartindex
* Program name: Staging TTHC.CONTAINEDPARTINDEX
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
    , CAST(documentid AS int)           AS documentid
    , CAST(contentitemid AS string)     AS contentitemid
    , CAST(listcontentitemid AS string) AS listcontentitemid
    , CAST(displaytext AS string)       AS displaytext
    , CAST(order AS int)                AS order
    , CAST(listcontenttype AS string)   AS listcontenttype
    , CAST(published AS decimal(38,0))  AS published
    , CAST(latest AS decimal(38,0))     AS latest
FROM {{ source('source_tthc', 'raw_containedpartindex') }}