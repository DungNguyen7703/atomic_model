/*
*--------------------------------------------------------------------*
* Program code: stg_fims_parawarn
* Program name: Staging FIMS.PARAWARN
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
    , CAST(name AS string)                AS name
    , CAST(note AS string)                AS note
    , CAST(legalcode AS string)           AS legalcode
    , CAST(formulainfo AS string)         AS formulainfo
    , CAST(formulainfoinvestor AS string) AS formulainfoinvestor
    , CAST(status AS int)                 AS status
    , CAST(systemobject AS bigint)        AS systemobject
FROM {{ source('source_fims', 'raw_parawarn') }}