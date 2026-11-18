/*
*--------------------------------------------------------------------*
* Program code: stg_fims_bankmoni
* Program name: Staging FIMS.BANKMONI
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
    , CAST(idno AS string)            AS idno
    , CAST(iddate AS date)            AS iddate
    , CAST(idadd AS string)           AS idadd
    , CAST(regno AS string)           AS regno
    , CAST(regdate AS date)           AS regdate
    , CAST(regadd AS string)          AS regadd
    , CAST(director AS string)        AS director
    , CAST(capital AS decimal(36,2))  AS capital
    , CAST(statusid AS decimal(18,2)) AS statusid
    , CAST(depcert AS string)         AS depcert
    , CAST(description AS string)     AS description
    , CAST(filename AS string)        AS filename
    , CAST(filedata AS string)        AS filedata
    , CAST(idold AS string)           AS idold
    , CAST(isdatamigration AS int)    AS isdatamigration
    , CAST(issynced AS int)           AS issynced
FROM {{ source('source_fims', 'raw_bankmoni') }}