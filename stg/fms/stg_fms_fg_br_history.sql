/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fg_br_history
* Program name: Staging FMS.FG_BR_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(fg_br_id)                      AS fg_br_id
    , CAST(date_change AS date)          AS date_change
    , CAST(action AS string)             AS action
    , CAST(adjustment_license AS string) AS adjustment_license
    , CAST(license_date AS date)         AS license_date
    , CAST(value_change AS string)       AS value_change
    , CAST(reason AS string)             AS reason
    , CAST(file_data AS string)          AS file_data
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(prev_value AS string)         AS prev_value
    , HEX(event_type_id)                 AS event_type_id
FROM {{ source('source_fms', 'raw_fg_br_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')