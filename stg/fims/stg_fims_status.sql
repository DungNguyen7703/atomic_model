/*
*--------------------------------------------------------------------*
* Program code: stg_fims_status
* Program name: Staging FIMS.STATUS
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
    , CAST(name AS string)              AS name
    , CAST(typeobject AS decimal(18,2)) AS typeobject
    , CAST(isactive AS int)             AS isactive
    , CAST(issubmitreport AS int)       AS issubmitreport
    , CAST(description AS string)       AS description
    , CAST(icon AS string)              AS icon
    , CAST(color AS string)             AS color
    , CAST(idold AS string)             AS idold
    , CAST(ecatalog_id AS string)       AS ecatalog_id
    , CAST(code AS string)              AS code
FROM {{ source('source_fims', 'raw_status') }}