/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptvaluesmanagerment
* Program name: Staging FIMS.RPTVALUESMANAGERMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))           AS id
    , CAST(deleted AS int)              AS deleted
    , CAST(datecreated AS date)         AS datecreated
    , CAST(createdby AS string)         AS createdby
    , CAST(datemodified AS date)        AS datemodified
    , CAST(modifyby AS string)          AS modifyby
    , CAST(tablename AS string)         AS tablename
    , CAST(tableyear AS string)         AS tableyear
    , CAST(tablesystemobject AS string) AS tablesystemobject
FROM {{ source('source_fims', 'raw_rptvaluesmanagerment') }}