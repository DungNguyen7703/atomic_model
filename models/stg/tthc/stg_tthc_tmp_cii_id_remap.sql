/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_tmp_cii_id_remap
* Program name: Staging TTHC.TMP_CII_ID_REMAP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(old_id AS int)             AS old_id
    , CAST(new_id AS int)             AS new_id
    , CAST(document_id AS int)        AS document_id
    , CAST(content_item_id AS string) AS content_item_id
FROM {{ source('source_tthc', 'raw_tmp_cii_id_remap') }}