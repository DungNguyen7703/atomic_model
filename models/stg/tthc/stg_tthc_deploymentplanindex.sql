/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_deploymentplanindex
* Program name: Staging TTHC.DEPLOYMENTPLANINDEX
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
    , CAST(name AS string)    AS name
FROM {{ source('source_tthc', 'raw_deploymentplanindex') }}