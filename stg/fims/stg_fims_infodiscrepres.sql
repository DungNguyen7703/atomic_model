/*
*--------------------------------------------------------------------*
* Program code: stg_fims_infodiscrepres
* Program name: Staging FIMS.INFODISCREPRES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))                     AS id
    , CAST(deleted AS int)                        AS deleted
    , CAST(datecreated AS date)                   AS datecreated
    , CAST(createdby AS string)                   AS createdby
    , CAST(datemodified AS date)                  AS datemodified
    , CAST(modifyby AS string)                    AS modifyby
    , CAST(objecttype AS decimal(18,2))           AS objecttype
    , CAST(name AS string)                        AS name
    , CAST(ename AS string)                       AS ename
    , CAST(shortname AS string)                   AS shortname
    , CAST(statusid AS decimal(18,2))             AS statusid
    , CAST(sex AS string)                         AS sex
    , CAST(dateofbirth AS date)                   AS dateofbirth
    , CAST(naid AS decimal(18,2))                 AS naid
    , CAST(address AS string)                     AS address
    , CAST(idno AS string)                        AS idno
    , CAST(iddate AS date)                        AS iddate
    , CAST(idadd AS string)                       AS idadd
    , CAST(certno AS string)                      AS certno
    , CAST(telephone AS string)                   AS telephone
    , CAST(fax AS string)                         AS fax
    , CAST(email AS string)                       AS email
    , CAST(website AS string)                     AS website
    , CAST(description AS string)                 AS description
    , CAST(filename AS string)                    AS filename
    , CAST(filedata AS string)                    AS filedata
    , CAST(idold AS string)                       AS idold
    , CAST(isdatamigration AS int)                AS isdatamigration
    , CAST(profilekind AS int)                    AS profilekind
    , CAST(representedinfodiscrepresid AS bigint) AS representedinfodiscrepresid
    , CAST(naiddmdc AS string)                    AS naiddmdc
FROM {{ source('source_fims', 'raw_infodiscrepres') }}