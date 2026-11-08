/*
*--------------------------------------------------------------------*
* Program code: stg_fims_securitiestype
* Program name: Staging FIMS.SECURITIESTYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))         AS id
    , CAST(deleted AS int)            AS deleted
    , CAST(datecreated AS date)       AS datecreated
    , CAST(createdby AS string)       AS createdby
    , CAST(datemodified AS date)      AS datemodified
    , CAST(modifyby AS string)        AS modifyby
    , CAST(parentid AS decimal(18,2)) AS parentid
    , CAST(sname AS string)           AS sname
    , CAST(name AS string)            AS name
    , CAST(status AS int)             AS status
    , CAST(isdatamigration AS int)    AS isdatamigration
    , CAST(description AS string)     AS description
    , CAST(idold AS string)           AS idold
    , CAST(ecatalog_id AS string)     AS ecatalog_id
FROM {{ source('source_fims', 'raw_securitiestype') }}