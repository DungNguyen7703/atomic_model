/*
*--------------------------------------------------------------------*
* Program code: stg_fims_reporttype
* Program name: Staging FIMS.REPORTTYPE
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
    , CAST(sname AS string)        AS sname
    , CAST(name AS string)         AS name
    , CAST(isperiodic AS int)      AS isperiodic
    , CAST(status AS int)          AS status
    , CAST(description AS string)  AS description
    , CAST(isdatamigration AS int) AS isdatamigration
    , CAST(ecatalog_id AS string)  AS ecatalog_id
FROM {{ source('source_fims', 'raw_reporttype') }}