/*
*--------------------------------------------------------------------*
* Program code: stg_fms_event_type_data_period
* Program name: Staging FMS.EVENT_TYPE_DATA_PERIOD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , HEX(event_type_id)               AS event_type_id
    , CAST(data_period_type AS string) AS data_period_type
    , CAST(latest_send_time AS string) AS latest_send_time
    , CAST(working_day AS int)         AS working_day
    , CAST(repeat_after_days AS int)   AS repeat_after_days
    , CAST(week_start_date AS date)    AS week_start_date
    , CAST(send_within_days AS int)    AS send_within_days
    , CAST(repeat_after_weeks AS int)  AS repeat_after_weeks
    , CAST(period_status AS int)       AS period_status
    , CAST(note AS string)             AS note
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , CAST(latest_send_week AS int)    AS latest_send_week
FROM {{ source('source_fms', 'raw_event_type_data_period') }}