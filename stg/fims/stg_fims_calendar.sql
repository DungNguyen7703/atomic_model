/*
*--------------------------------------------------------------------*
* Program code: stg_fims_calendar
* Program name: Staging FIMS.CALENDAR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))      AS id
    , CAST(deleted AS int)         AS deleted
    , CAST(datecreated AS date)    AS datecreated
    , CAST(createdby AS string)    AS createdby
    , CAST(datemodified AS date)   AS datemodified
    , CAST(modifyby AS string)     AS modifyby
    , CAST(workingdate AS date)    AS workingdate
    , CAST(isworkingdate AS int)   AS isworkingdate
    , CAST(note AS string)         AS note
    , CAST(isdatamigration AS int) AS isdatamigration
FROM {{ source('source_fims', 'raw_calendar') }}