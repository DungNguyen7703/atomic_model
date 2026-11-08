/*
*--------------------------------------------------------------------*
* Program code: stg_fims_sheetout
* Program name: Staging FIMS.SHEETOUT
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
    , CAST(tpoutid AS decimal(18,2)) AS tpoutid
    , CAST(code AS string)           AS code
    , CAST(name AS string)           AS name
    , CAST(sheetindex AS bigint)     AS sheetindex
    , CAST(status AS int)            AS status
    , CAST(description AS string)    AS description
    , CAST(mergecells AS string)     AS mergecells
    , CAST(cellsmeta AS string)      AS cellsmeta
    , CAST(datalabel AS string)      AS datalabel
    , CAST(colwidths AS string)      AS colwidths
    , CAST(rowheights AS string)     AS rowheights
FROM {{ source('source_fims', 'raw_sheetout') }}