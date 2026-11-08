/*
*--------------------------------------------------------------------*
* Program code: stg_ids_form_field_history
* Program name: Staging IDS.FORM_FIELD_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(field_id AS decimal(19,0)) AS field_id
    , CAST(form_id AS decimal(19,0))  AS form_id
    , CAST(field_name_vi AS string)   AS field_name_vi
    , CAST(form_name_vi AS string)    AS form_name_vi
    , CAST(action AS int)             AS action
    , CAST(changed_by AS string)      AS changed_by
    , CAST(changed_date AS date)      AS changed_date
    , CAST(system_cd AS string)       AS system_cd
FROM {{ source('source_ids', 'raw_form_field_history') }}