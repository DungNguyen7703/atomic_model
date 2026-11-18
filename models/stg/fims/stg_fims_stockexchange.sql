/*
*--------------------------------------------------------------------*
* Program code: stg_fims_stockexchange
* Program name: Staging FIMS.STOCKEXCHANGE
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
    , CAST(name AS string)            AS name
    , CAST(ename AS string)           AS ename
    , CAST(shortname AS string)       AS shortname
    , CAST(naid AS decimal(18,2))     AS naid
    , CAST(address AS string)         AS address
    , CAST(telephone AS string)       AS telephone
    , CAST(fax AS string)             AS fax
    , CAST(email AS string)           AS email
    , CAST(website AS string)         AS website
    , CAST(hotline AS string)         AS hotline
    , CAST(statusid AS decimal(18,2)) AS statusid
    , CAST(description AS string)     AS description
    , CAST(filename AS string)        AS filename
    , CAST(filedata AS string)        AS filedata
    , CAST(idold AS string)           AS idold
    , CAST(isdatamigration AS int)    AS isdatamigration
    , CAST(issynced AS int)           AS issynced
    , CAST(taxcode AS string)         AS taxcode
FROM {{ source('source_fims', 'raw_stockexchange') }}