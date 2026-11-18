/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpthtory
* Program name: Staging FIMS.RPTHTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))        AS id
    , CAST(deleted AS int)           AS deleted
    , CAST(datecreated AS date)      AS datecreated
    , CAST(createdby AS string)      AS createdby
    , CAST(datemodified AS date)     AS datemodified
    , CAST(modifyby AS string)       AS modifyby
    , CAST(rptid AS decimal(18,2))   AS rptid
    , CAST(code AS string)           AS code
    , CAST(action AS string)         AS action
    , CAST(version AS decimal(18,2)) AS version
    , CAST(isdownload AS int)        AS isdownload
FROM {{ source('source_fims', 'raw_rpthtory') }}