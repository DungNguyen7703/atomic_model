/*
*--------------------------------------------------------------------*
* Program code: stg_fms_stf_rep_office_history
* Program name: Staging FMS.STF_REP_OFFICE_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                        AS id
    , HEX(stf_fg_brch_id)          AS stf_fg_brch_id
    , HEX(for_brch_id)             AS for_brch_id
    , HEX(event_type_id)           AS event_type_id
    , CAST(date_change AS date)    AS date_change
    , CAST(action AS string)       AS action
    , CAST(prev_value AS string)   AS prev_value
    , CAST(value_change AS string) AS value_change
    , CAST(reason AS string)       AS reason
    , CAST(file_data AS string)    AS file_data
    , CAST(date_created AS date)   AS date_created
    , CAST(created_by AS string)   AS created_by
FROM {{ source('source_fms', 'raw_stf_rep_office_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')