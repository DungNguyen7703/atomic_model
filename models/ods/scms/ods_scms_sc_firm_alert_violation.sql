/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_alert_violation
* Program name: ODS SCMS.SC_FIRM_ALERT_VIOLATION
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
    , sc_firm_info_id
    , severity_level
    , condition
    , compare_value
    , actual_value
    , note
    , created_at
    , alert_indicator_id
    , alert_year
    , report_period
    , report_period_value
    , resolved
    , deducted_score
    , resolution_note
    , period
    , violation_description
    , violation_severity
    , report_year
    , processing_date
    , created_by
    , processor_id
    , threshold
    , alert_condition_id
    , entity_type
    , entity_id
    , alert_run_id
    , period_type
    , period_value
    , alert_date
    , severity_level_alt
    , string_result_value
FROM {{ ref('stg_scms_sc_firm_alert_violation') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1