/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tlprofiles
* Program name: Staging FIMS.TLPROFILES
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
    , CAST(fundcomid AS decimal(18,2))    AS fundcomid
    , CAST(seccomid AS decimal(18,2))     AS seccomid
    , CAST(bankid AS decimal(18,2))       AS bankid
    , CAST(depcenid AS decimal(18,2))     AS depcenid
    , CAST(stockcenid AS decimal(18,2))   AS stockcenid
    , CAST(indirepcenid AS decimal(18,2)) AS indirepcenid
    , CAST(name AS string)                AS name
    , CAST(naid AS decimal(18,2))         AS naid
    , CAST(address AS string)             AS address
    , CAST(placeofbirth AS string)        AS placeofbirth
    , CAST(idno AS string)                AS idno
    , CAST(iddate AS date)                AS iddate
    , CAST(idadd AS string)               AS idadd
    , CAST(dateofbirth AS date)           AS dateofbirth
    , CAST(sex AS string)                 AS sex
    , CAST(telephone AS string)           AS telephone
    , CAST(email AS string)               AS email
    , CAST(isrepresentative AS int)       AS isrepresentative
    , CAST(emailrepresentative AS string) AS emailrepresentative
    , CAST(sworkdte AS date)              AS sworkdte
    , CAST(fworkdte AS date)              AS fworkdte
    , CAST(certno AS string)              AS certno
    , CAST(certdate AS date)              AS certdate
    , CAST(certadd AS string)             AS certadd
    , CAST(degreeid AS decimal(18,2))     AS degreeid
    , CAST(statusid AS decimal(18,2))     AS statusid
    , CAST(description AS string)         AS description
    , CAST(filename AS string)            AS filename
    , CAST(systemobject AS decimal(18,2)) AS systemobject
    , CAST(filedata AS string)            AS filedata
FROM {{ source('source_fims', 'raw_tlprofiles') }}