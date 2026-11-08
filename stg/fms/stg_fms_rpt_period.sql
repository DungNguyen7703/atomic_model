/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_period
* Program name: Staging FMS.RPT_PERIOD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                        AS id
    , CAST(date_created AS date)                   AS date_created
    , CAST(created_by AS string)                   AS created_by
    , CAST(date_modified AS date)                  AS date_modified
    , CAST(modify_by AS string)                    AS modify_by
    , HEX(rpt_id)                                  AS rpt_id
    , CAST(period_type AS decimal(18,2))           AS period_type
    , CAST(record_status AS int)                   AS record_status
    , CAST(working_day AS int)                     AS working_day
    , CAST(send_in_day AS bigint)                  AS send_in_day
    , CAST(latest_send_date AS timestamp)          AS latest_send_date
    , CAST(latest_send_week AS bigint)             AS latest_send_week
    , CAST(description AS string)                  AS description
    , HEX(sf_pd_id)                                AS sf_pd_id
    , CAST(repeat_time AS bigint)                  AS repeat_time
    , CAST(announce_is_working_day AS int)         AS announce_is_working_day
    , CAST(announce_latest_send_date AS timestamp) AS announce_latest_send_date
    , CAST(announce_send_in_day AS bigint)         AS announce_send_in_day
    , CAST(announce_latest_send_week AS bigint)    AS announce_latest_send_week
    , CAST(deleted AS int)                         AS deleted
    , CAST(file_name AS string)                    AS file_name
FROM {{ source('source_fms', 'raw_rpt_period') }}