/*
*--------------------------------------------------------------------*
* Program code: stg_fims_jobtype
* Program name: Staging FIMS.JOBTYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))     AS id
    , CAST(deleted AS int)        AS deleted
    , CAST(datecreated AS date)   AS datecreated
    , CAST(createdby AS string)   AS createdby
    , CAST(datemodified AS date)  AS datemodified
    , CAST(modifyby AS string)    AS modifyby
    , CAST(name AS string)        AS name
    , CAST(sname AS string)       AS sname
    , CAST(description AS string) AS description
    , CAST(status AS int)         AS status
    , CAST(idold AS string)       AS idold
FROM {{ source('source_fims', 'raw_jobtype') }}