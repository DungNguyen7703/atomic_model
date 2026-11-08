/*
*--------------------------------------------------------------------*
* Program code: stg_fms_calendar
* Program name: Staging FMS.CALENDAR
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
    , CAST(date_created AS date)   AS date_created
    , CAST(created_by AS string)   AS created_by
    , CAST(date_modified AS date)  AS date_modified
    , CAST(modify_by AS string)    AS modify_by
    , CAST(working_date AS date)   AS working_date
    , CAST(is_working_date AS int) AS is_working_date
    , CAST(note AS string)         AS note
    , CAST(data_migration AS int)  AS data_migration
FROM {{ source('source_fms', 'raw_calendar') }}