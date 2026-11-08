/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptoutfilesave
* Program name: Staging FIMS.RPTOUTFILESAVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))               AS id
    , CAST(deleted AS int)                  AS deleted
    , CAST(datecreated AS date)             AS datecreated
    , CAST(createdby AS string)             AS createdby
    , CAST(datemodified AS date)            AS datemodified
    , CAST(modifyby AS string)              AS modifyby
    , CAST(systemobject AS decimal(18,2))   AS systemobject
    , CAST(rptoutid AS decimal(18,2))       AS rptoutid
    , CAST(fileexport AS string)            AS fileexport
    , CAST(datafileexport AS string)        AS datafileexport
    , CAST(periodtype AS bigint)            AS periodtype
    , CAST(periodvalue AS string)           AS periodvalue
    , CAST(reportyear AS bigint)            AS reportyear
    , CAST(rptoutmanageid AS decimal(18,2)) AS rptoutmanageid
FROM {{ source('source_fims', 'raw_rptoutfilesave') }}