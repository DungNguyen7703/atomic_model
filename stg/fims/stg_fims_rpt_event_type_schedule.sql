/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_event_type_schedule
* Program name: Staging FIMS.RPT_EVENT_TYPE_SCHEDULE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(rpt_event_type_id AS bigint)      AS rpt_event_type_id
    , CAST(sort_order AS bigint)             AS sort_order
    , CAST(period_type AS int)               AS period_type
    , CAST(day_value AS date)                AS day_value
    , CAST(numeric_value AS bigint)          AS numeric_value
    , CAST(latest_submission_hour AS string) AS latest_submission_hour
    , CAST(repeat_after AS bigint)           AS repeat_after
    , CAST(unit AS int)                      AS unit
    , CAST(active AS int)                    AS active
    , CAST(row_note AS string)               AS row_note
    , CAST(submit_within AS bigint)          AS submit_within
FROM {{ source('source_fims', 'raw_rpt_event_type_schedule') }}