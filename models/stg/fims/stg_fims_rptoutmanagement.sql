/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptoutmanagement
* Program name: Staging FIMS.RPTOUTMANAGEMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))             AS id
    , CAST(deleted AS int)                AS deleted
    , CAST(datecreated AS date)           AS datecreated
    , CAST(createdby AS string)           AS createdby
    , CAST(datemodified AS date)          AS datemodified
    , CAST(modifyby AS string)            AS modifyby
    , CAST(systemobject AS decimal(18,2)) AS systemobject
    , CAST(rptoutid AS decimal(18,2))     AS rptoutid
    , CAST(ismutiperiod AS int)           AS ismutiperiod
    , CAST(periodvaluefrom AS string)     AS periodvaluefrom
    , CAST(periodvalueto AS string)       AS periodvalueto
    , CAST(status AS int)                 AS status
    , CAST(periodtype AS bigint)          AS periodtype
    , CAST(datestart AS string)           AS datestart
    , CAST(dateend AS string)             AS dateend
    , CAST(name AS string)                AS name
    , CAST(investorids AS string)         AS investorids
    , CAST(investortypeids AS string)     AS investortypeids
    , CAST(memberids AS string)           AS memberids
    , CAST(memberstrids AS string)        AS memberstrids
    , CAST(nationid AS decimal(18,2))     AS nationid
    , CAST(securitiesids AS string)       AS securitiesids
    , CAST(unit AS string)                AS unit
    , CAST(datecompletion AS date)        AS datecompletion
    , CAST(isrunnow AS decimal(18,2))     AS isrunnow
    , CAST(issum AS int)                  AS issum
FROM {{ source('source_fims', 'raw_rptoutmanagement') }}