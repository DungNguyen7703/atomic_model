/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_layermetadataindex
* Program name: Staging TTHC.LAYERMETADATAINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)         AS id
    , CAST(documentid AS int) AS documentid
    , CAST(zone AS string)    AS zone
FROM {{ source('source_tthc', 'raw_layermetadataindex') }}