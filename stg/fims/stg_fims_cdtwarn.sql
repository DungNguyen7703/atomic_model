/*
*--------------------------------------------------------------------*
* Program code: stg_fims_cdtwarn
* Program name: Staging FIMS.CDTWARN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))                  AS id
    , CAST(deleted AS int)                     AS deleted
    , CAST(datecreated AS date)                AS datecreated
    , CAST(createdby AS string)                AS createdby
    , CAST(datemodified AS date)               AS datemodified
    , CAST(modifyby AS string)                 AS modifyby
    , CAST(prwid AS decimal(18,2))             AS prwid
    , CAST(name AS string)                     AS name
    , CAST(comparetype AS int)                 AS comparetype
    , CAST(otherwid AS decimal(18,2))          AS otherwid
    , CAST(otherwidcondition AS decimal(18,2)) AS otherwidcondition
    , CAST(fromvalue AS decimal(38,5))         AS fromvalue
    , CAST(fromvaluecondition AS bigint)       AS fromvaluecondition
    , CAST(tovalue AS decimal(38,5))           AS tovalue
    , CAST(tovaluecondition AS bigint)         AS tovaluecondition
    , CAST(status AS int)                      AS status
    , CAST(prwperiodtype AS bigint)            AS prwperiodtype
    , CAST(prwperiodvalue AS string)           AS prwperiodvalue
    , CAST(otherwperiodtype AS bigint)         AS otherwperiodtype
    , CAST(otherwperiodvalue AS string)        AS otherwperiodvalue
    , CAST(numberdayrun AS decimal(38,0))      AS numberdayrun
FROM {{ source('source_fims', 'raw_cdtwarn') }}