/*
*--------------------------------------------------------------------*
* Program code: stg_fims_calendarmanagerment
* Program name: Staging FIMS.CALENDARMANAGERMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))    AS id
    , CAST(deleted AS int)       AS deleted
    , CAST(datecreated AS date)  AS datecreated
    , CAST(createdby AS string)  AS createdby
    , CAST(datemodified AS date) AS datemodified
    , CAST(modifyby AS string)   AS modifyby
    , CAST(startdate AS date)    AS startdate
    , CAST(enddate AS date)      AS enddate
    , CAST(flagrun AS int)       AS flagrun
FROM {{ source('source_fims', 'raw_calendarmanagerment') }}