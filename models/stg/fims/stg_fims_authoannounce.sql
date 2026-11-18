/*
*--------------------------------------------------------------------*
* Program code: stg_fims_authoannounce
* Program name: Staging FIMS.AUTHOANNOUNCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))                    AS id
    , CAST(deleted AS int)                       AS deleted
    , CAST(datecreated AS date)                  AS datecreated
    , CAST(createdby AS string)                  AS createdby
    , CAST(datemodified AS date)                 AS datemodified
    , CAST(modifyby AS string)                   AS modifyby
    , CAST(infodiscrepresid AS decimal(18,2))    AS infodiscrepresid
    , CAST(relatedpropertiesid AS decimal(18,2)) AS relatedpropertiesid
    , CAST(relationshipid AS decimal(18,2))      AS relationshipid
    , CAST(filedata AS string)                   AS filedata
    , CAST(sdate AS timestamp)                   AS sdate
    , CAST(edate AS timestamp)                   AS edate
    , CAST(idold AS string)                      AS idold
    , CAST(investorids AS string)                AS investorids
    , CAST(systemobject AS bigint)               AS systemobject
    , CAST(fundcomid AS bigint)                  AS fundcomid
    , CAST(seccomid AS bigint)                   AS seccomid
    , CAST(bankid AS bigint)                     AS bankid
    , CAST(depcenid AS bigint)                   AS depcenid
    , CAST(stockcenid AS bigint)                 AS stockcenid
    , CAST(branchsid AS bigint)                  AS branchsid
    , CAST(istradingrep AS int)                  AS istradingrep
    , CAST(importfilename AS string)             AS importfilename
FROM {{ source('source_fims', 'raw_authoannounce') }}