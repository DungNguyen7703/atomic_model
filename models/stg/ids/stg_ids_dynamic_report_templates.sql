/*
*--------------------------------------------------------------------*
* Program code: stg_ids_dynamic_report_templates
* Program name: Staging IDS.DYNAMIC_REPORT_TEMPLATES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,0))       AS id
    , CAST(title AS string)           AS title
    , CAST(news_type_cd AS string)    AS news_type_cd
    , CAST(form_id AS decimal(38,0))  AS form_id
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS timestamp) AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS timestamp) AS updated_date
FROM {{ source('source_ids', 'raw_dynamic_report_templates') }}