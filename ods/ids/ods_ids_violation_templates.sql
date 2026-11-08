/*
*--------------------------------------------------------------------*
* Program code: ods_ids_violation_templates
* Program name: ODS IDS.VIOLATION_TEMPLATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , form_id
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
    , active_flg
    , delete_flg
    , offset_days_condition
    , created_date
    , created_by
    , updated_date
    , updated_by
FROM {{ ref('stg_ids_violation_templates') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')