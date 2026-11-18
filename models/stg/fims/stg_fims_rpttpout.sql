/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpttpout
* Program name: Staging FIMS.RPTTPOUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))         AS id
    , CAST(deleted AS int)            AS deleted
    , CAST(datecreated AS date)       AS datecreated
    , CAST(createdby AS string)       AS createdby
    , CAST(datemodified AS date)      AS datemodified
    , CAST(modifyby AS string)        AS modifyby
    , CAST(shtotid AS decimal(18,2))  AS shtotid
    , CAST(name AS string)            AS name
    , CAST(legalbasis AS string)      AS legalbasis
    , CAST(code AS string)            AS code
    , CAST(status AS bigint)          AS status
    , CAST(description AS string)     AS description
    , CAST(reportgroup AS bigint)     AS reportgroup
    , CAST(systemobject AS bigint)    AS systemobject
    , CAST(systemobjectlst AS string) AS systemobjectlst
FROM {{ source('source_fims', 'raw_rpttpout') }}