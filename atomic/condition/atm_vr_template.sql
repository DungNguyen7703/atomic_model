/*
*--------------------------------------------------------------------*
* Program code: atm_vr_template
* Program name: Atomic Vr Template
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        form_id
        , violation_cd
        , violation_name_vi
        , violation_name_en
        , violation_type_cd
        , violation_subtype_cd
        , report_type_cd
        , report_scope_cd
        , period_type_cd
        , violation_trigger_point_cd
        , offset_days
        , violation_trigger_point_cd_ex
        , offset_days_ex
        , day_type_cd
        , effective_start_date
        , effective_end_date
        , offset_days_condition
    FROM {{ ref('ods_ids_violation_templates') }}
),

fo AS (
    SELECT
        id
        , form_cd
    FROM {{ ref('ods_ids_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_VIOLATION_TEMPLATES', "src.violation_cd") }}   AS vr_template_id
    , CAST(src.violation_cd AS string)                                                   AS vr_template_code
    , CAST('IDS_VIOLATION_TEMPLATES' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "fo.form_cd") }}                     AS fr_template_id
    , CAST(fo.form_cd AS string)                                                         AS fr_template_code
    , CAST(src.violation_name_vi AS string)                                              AS vr_nm
    , CAST(src.violation_name_en AS string)                                              AS vr_english_nm
    , CAST(src.violation_type_cd AS string)                                              AS vr_tp_code
    , CAST(src.violation_subtype_cd AS string)                                           AS vr_sub_tp_code
    , CAST(src.report_type_cd AS string)                                                 AS news_tp_code
    , CAST(src.report_scope_cd AS string)                                                AS fr_scope_tp_code
    , CAST(src.period_type_cd AS string)                                                 AS period_tp_code
    , CAST(src.violation_trigger_point_cd AS string)                                     AS violation_trigger_point_code
    , CAST(src.offset_days AS int)                                                       AS offset_day_count
    , CAST(src.violation_trigger_point_cd_ex AS string)                                  AS violation_trigger_point_extended_code
    , CAST(src.offset_days_ex AS int)                                                    AS offset_day_count_extended
    , CAST(src.day_type_cd AS string)                                                    AS day_tp_code
    , CAST(src.effective_start_date AS date)                                             AS effective_start_dt
    , CAST(src.effective_end_date AS date)                                               AS effective_end_dt
    , CAST(src.offset_days_condition AS int)                                             AS offset_day_count_condition
FROM src
    LEFT JOIN fo ON src.form_id = fo.id
