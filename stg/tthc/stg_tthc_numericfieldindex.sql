/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_numericfieldindex
* Program name: Staging TTHC.NUMERICFIELDINDEX
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
    , CAST(contenttype AS string)          AS contenttype
    , CAST(contentpart AS string)          AS contentpart
    , CAST(contentfield AS string)         AS contentfield
    , CAST(published AS decimal(38,0))     AS published
    , CAST(latest AS decimal(38,0))        AS latest
    , CAST(numeric AS decimal(38,10))      AS numeric
FROM {{ source('source_tthc', 'raw_numericfieldindex') }}