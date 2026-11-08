/*
*--------------------------------------------------------------------*
* Program code: stg_audit_violation_templates
* Program name: Staging AUDIT.VIOLATION_TEMPLATES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,0))                     AS id
    , CAST(form_id AS decimal(38,0))                AS form_id
    , CAST(violation_cd AS string)                  AS violation_cd
    , CAST(violation_name_vi AS string)             AS violation_name_vi
    , CAST(violation_name_en AS string)             AS violation_name_en
    , CAST(violation_type_cd AS string)             AS violation_type_cd
    , CAST(violation_subtype_cd AS string)          AS violation_subtype_cd
    , CAST(report_type_cd AS string)                AS report_type_cd
    , CAST(report_scope_cd AS string)               AS report_scope_cd
    , CAST(period_type_cd AS string)                AS period_type_cd
    , CAST(violation_trigger_point_cd AS string)    AS violation_trigger_point_cd
    , CAST(offset_days AS int)                      AS offset_days
    , CAST(violation_trigger_point_cd_ex AS string) AS violation_trigger_point_cd_ex
    , CAST(offset_days_ex AS int)                   AS offset_days_ex
    , CAST(day_type_cd AS string)                   AS day_type_cd
    , CAST(effective_start_date AS date)            AS effective_start_date
    , CAST(effective_end_date AS date)              AS effective_end_date
    , CAST(active_flg AS int)                       AS active_flg
    , CAST(delete_flg AS int)                       AS delete_flg
    , CAST(offset_days_condition AS int)            AS offset_days_condition
    , CAST(created_date AS timestamp)               AS created_date
    , CAST(created_by AS string)                    AS created_by
    , CAST(updated_date AS timestamp)               AS updated_date
    , CAST(updated_by AS string)                    AS updated_by
    , CAST(condition_field_cd AS string)            AS condition_field_cd
FROM {{ source('source_audit', 'raw_violation_templates') }}