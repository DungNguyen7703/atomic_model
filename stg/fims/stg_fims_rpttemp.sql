/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpttemp
* Program name: Staging FIMS.RPTTEMP
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
    , CAST(legalbasis AS string)          AS legalbasis
    , CAST(code AS string)                AS code
    , CAST(reporttypeid AS decimal(18,2)) AS reporttypeid
    , CAST(reportgroup AS bigint)         AS reportgroup
    , CAST(isneedimport AS int)           AS isneedimport
    , CAST(isneedpublic AS int)           AS isneedpublic
    , CAST(systemobjects AS bigint)       AS systemobjects
    , CAST(description AS string)         AS description
    , CAST(filedata AS string)            AS filedata
    , CAST(status AS int)                 AS status
    , CAST(version AS decimal(18,2))      AS version
    , CAST(dateused AS timestamp)         AS dateused
    , CAST(iseform AS int)                AS iseform
    , CAST(eformschemajson AS string)     AS eformschemajson
    , CAST(excelconfigjson AS string)     AS excelconfigjson
    , CAST(sheetsdesignerjson AS string)  AS sheetsdesignerjson
FROM {{ source('source_fims', 'raw_rpttemp') }}