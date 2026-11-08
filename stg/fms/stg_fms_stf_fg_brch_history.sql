/*
*--------------------------------------------------------------------*
* Program code: stg_fms_stf_fg_brch_history
* Program name: Staging FMS.STF_FG_BRCH_HISTORY
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
    , HEX(stf_fg_brch_id)              AS stf_fg_brch_id
    , HEX(for_brch_id)                 AS for_brch_id
    , CAST(changed_field AS string)    AS changed_field
    , CAST(old_value AS string)        AS old_value
    , CAST(new_value AS string)        AS new_value
    , CAST(reason AS string)           AS reason
    , CAST(date_change AS date)        AS date_change
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , HEX(event_type_id)               AS event_type_id
    , CAST(action AS string)           AS action
    , CAST(staff_name AS string)       AS staff_name
    , CAST(staff_id_code AS string)    AS staff_id_code
    , CAST(file_data AS string)        AS file_data
FROM {{ source('source_fms', 'raw_stf_fg_brch_history') }}