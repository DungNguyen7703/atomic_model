/*
*--------------------------------------------------------------------*
* Program code: stg_fims_branchs
* Program name: Staging FIMS.BRANCHS
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
    , CAST(ename AS string)             AS ename
    , CAST(shortname AS string)         AS shortname
    , CAST(naid AS decimal(18,2))       AS naid
    , CAST(address AS string)           AS address
    , CAST(telephone AS string)         AS telephone
    , CAST(fax AS string)               AS fax
    , CAST(email AS string)             AS email
    , CAST(website AS string)           AS website
    , CAST(statusid AS decimal(18,2))   AS statusid
    , CAST(idno AS string)              AS idno
    , CAST(iddate AS date)              AS iddate
    , CAST(idadd AS string)             AS idadd
    , CAST(regno AS string)             AS regno
    , CAST(regdate AS date)             AS regdate
    , CAST(regadd AS string)            AS regadd
    , CAST(codetax AS string)           AS codetax
    , CAST(capital AS decimal(36,2))    AS capital
    , CAST(startdate AS date)           AS startdate
    , CAST(enddate AS date)             AS enddate
    , CAST(companynameparent AS string) AS companynameparent
    , CAST(certnoparent AS string)      AS certnoparent
    , CAST(addparent AS string)         AS addparent
    , CAST(idnoparent AS decimal(18,2)) AS idnoparent
    , CAST(description AS string)       AS description
    , CAST(filename AS string)          AS filename
    , CAST(filedata AS string)          AS filedata
    , CAST(idold AS string)             AS idold
    , CAST(isdatamigration AS int)      AS isdatamigration
    , CAST(issynced AS int)             AS issynced
    , CAST(contractcontent AS string)   AS contractcontent
    , CAST(operatingterm AS string)     AS operatingterm
    , CAST(term AS string)              AS term
FROM {{ source('source_fims', 'raw_branchs') }}