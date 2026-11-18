/*
*--------------------------------------------------------------------*
* Program code: stg_ids_manual_document
* Program name: Staging IDS.MANUAL_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))       AS id
    , CAST(doc_cd AS string)          AS doc_cd
    , CAST(title AS string)           AS title
    , CAST(category_cd AS string)     AS category_cd
    , CAST(description AS string)     AS description
    , CAST(active_flg AS int)         AS active_flg
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS timestamp) AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS timestamp) AS updated_date
FROM {{ source('source_ids', 'raw_manual_document') }}