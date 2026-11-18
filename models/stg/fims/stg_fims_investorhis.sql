/*
*--------------------------------------------------------------------*
* Program code: stg_fims_investorhis
* Program name: Staging FIMS.INVESTORHIS
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
    , CAST(idold AS decimal(18,2))          AS idold
    , CAST(objecttype AS decimal(18,2))     AS objecttype
    , CAST(transactioncode AS string)       AS transactioncode
    , CAST(name AS string)                  AS name
    , CAST(ename AS string)                 AS ename
    , CAST(sex AS string)                   AS sex
    , CAST(dateofbirth AS date)             AS dateofbirth
    , CAST(naid AS decimal(18,2))           AS naid
    , CAST(address AS string)               AS address
    , CAST(idno AS string)                  AS idno
    , CAST(iddate AS date)                  AS iddate
    , CAST(idadd AS string)                 AS idadd
    , CAST(telephone AS string)             AS telephone
    , CAST(fax AS string)                   AS fax
    , CAST(email AS string)                 AS email
    , CAST(website AS string)               AS website
    , CAST(businessnumber AS string)        AS businessnumber
    , CAST(director AS string)              AS director
    , CAST(investortypeid AS decimal(18,2)) AS investortypeid
    , CAST(depaccountnumber AS string)      AS depaccountnumber
    , CAST(sysobjecttype AS decimal(18,2))  AS sysobjecttype
    , CAST(seccomaddid AS decimal(18,2))    AS seccomaddid
    , CAST(bankaddid AS decimal(18,2))      AS bankaddid
    , CAST(accountinvescapital AS string)   AS accountinvescapital
    , CAST(bankaddcapid AS decimal(18,2))   AS bankaddcapid
    , CAST(companytypeid AS decimal(18,2))  AS companytypeid
    , CAST(statusid AS decimal(18,2))       AS statusid
    , CAST(description AS string)           AS description
    , CAST(filename AS string)              AS filename
    , CAST(filedata AS string)              AS filedata
    , CAST(iddbold AS string)               AS iddbold
FROM {{ source('source_fims', 'raw_investorhis') }}