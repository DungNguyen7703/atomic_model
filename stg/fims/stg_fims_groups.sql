/*
*--------------------------------------------------------------------*
* Program code: stg_fims_groups
* Program name: Staging FIMS.GROUPS
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
    , CAST(orgid AS int)           AS orgid
    , CAST(groupname AS string)    AS groupname
    , CAST(status AS int)          AS status
    , CAST(description AS string)  AS description
    , CAST(datecreated AS date)    AS datecreated
    , CAST(createdby AS string)    AS createdby
    , CAST(datemodified AS date)   AS datemodified
    , CAST(modifyby AS string)     AS modifyby
    , CAST(isdatamigration AS int) AS isdatamigration
    , CAST(deleted AS int)         AS deleted
FROM {{ source('source_fims', 'raw_groups') }}