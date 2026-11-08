/*
*--------------------------------------------------------------------*
* Program code: atm_sc_alert_violation
* Program name: Atomic Securities Company Alert Violation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_al_vi AS (
    SELECT
        id
        , created_at
        , sc_firm_info_id
        , alert_indicator_id
        , alert_condition_id
        , alert_run_id
        , violation_severity
        , severity_level
        , entity_type
        , entity_id
        , condition
        , compare_value
        , actual_value
        , threshold
        , deducted_score
        , alert_year
        , report_year
        , report_period
        , report_period_value
        , period
        , resolved
        , resolution_note
        , violation_description
        , note
        , processing_date
        , processor_id
    FROM {{ ref('ods_scms_sc_firm_alert_violation') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_ALERT_VIOLATION', "sc_fi_al_vi.id") }}                     AS sc_alert_violation_id
    , CAST(sc_fi_al_vi.id AS string)                                                                          AS sc_alert_violation_code
    , CAST('SCMS_SC_FIRM_ALERT_VIOLATION' AS string)                                                          AS src_stm_code
    , CAST(sc_fi_al_vi.created_at AS date)                                                                    AS data_dt
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_al_vi.sc_firm_info_id") }}                 AS sc_id
    , CAST(sc_fi_al_vi.sc_firm_info_id AS string)                                                             AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_ALERT_INDICATOR', "sc_fi_al_vi.alert_indicator_id") }}           AS sc_alert_indicator_id
    , CAST(sc_fi_al_vi.alert_indicator_id AS string)                                                          AS sc_alert_indicator_code
    , {{ generate_surrogate_key_bigint('SCMS_ALERT_INDICATOR_CONDITION', "sc_fi_al_vi.alert_condition_id") }} AS sc_alert_indicator_condition_id
    , CAST(sc_fi_al_vi.alert_condition_id AS string)                                                          AS sc_alert_indicator_condition_code
    , {{ generate_surrogate_key_bigint('SCMS_ALERT_RUN', "sc_fi_al_vi.alert_run_id") }}                       AS sc_alert_run_id
    , CAST(sc_fi_al_vi.alert_run_id AS string)                                                                AS sc_alert_run_code
    , CAST(sc_fi_al_vi.violation_severity AS string)                                                          AS violation_severity_code
    , CAST(sc_fi_al_vi.severity_level AS string)                                                              AS severity_level
    , CAST(sc_fi_al_vi.entity_type AS string)                                                                 AS alert_entity_tp_code
    , CAST(sc_fi_al_vi.entity_id AS string)                                                                   AS alert_entity_code
    , CAST(sc_fi_al_vi.condition AS string)                                                                   AS condition_expression
    , CAST(sc_fi_al_vi.compare_value AS int)                                                                AS comparison_val
    , CAST(sc_fi_al_vi.actual_value AS decimal(23,2))                                                      AS actual_val
    , CAST(sc_fi_al_vi.threshold AS decimal(23,2))                                                            AS threshold_val
    , CAST(sc_fi_al_vi.deducted_score AS decimal(23,2))                                                       AS deducted_score
    , CAST(sc_fi_al_vi.alert_year AS string)                                                                  AS alert_year
    , CAST(sc_fi_al_vi.report_year AS int)                                                                    AS rpt_year
    , CAST(sc_fi_al_vi.report_period AS string)                                                               AS rpt_period_code
    , CAST(sc_fi_al_vi.report_period_value AS int)                                                            AS rpt_period_val
    , CAST(sc_fi_al_vi.period AS string)                                                                      AS period
    , CAST(sc_fi_al_vi.resolved AS boolean)                                                                   AS resolved_indicator
    , CAST(sc_fi_al_vi.resolution_note AS string)                                                             AS resolution_note
    , CAST(sc_fi_al_vi.violation_description AS string)                                                       AS violation_description
    , CAST(sc_fi_al_vi.note AS string)                                                                        AS note
    , CAST(sc_fi_al_vi.processing_date AS timestamp)                                                          AS processing_dt
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_ALERT_VIOLATION', "sc_fi_al_vi.processor_id") }}         AS processor_iam_user_id
    , CAST(sc_fi_al_vi.processor_id AS string)                                                                AS processor_iam_user_code
FROM sc_fi_al_vi