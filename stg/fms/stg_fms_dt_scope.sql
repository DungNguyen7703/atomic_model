/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_scope
* Program name: Staging FMS.DT_SCOPE
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
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(user_id)                       AS user_id
    , CAST(record_type AS decimal(38,0)) AS record_type
FROM {{ source('source_fms', 'raw_dt_scope') }}