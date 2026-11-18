/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inspection_target
* Program name: Staging FMS.INSPECTION_TARGET
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
    , CAST(deleted AS int)               AS deleted
    , HEX(inspection_round_id)           AS inspection_round_id
    , CAST(object_type AS decimal(38,0)) AS object_type
    , HEX(target_id)                     AS target_id
    , CAST(target_name AS string)        AS target_name
    , CAST(date_created AS timestamp)    AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS timestamp)   AS date_modified
    , CAST(modify_by AS string)          AS modify_by
FROM {{ source('source_fms', 'raw_inspection_target') }}