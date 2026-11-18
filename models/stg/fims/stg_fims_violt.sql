/*
*--------------------------------------------------------------------*
* Program code: stg_fims_violt
* Program name: Staging FIMS.VIOLT
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
    , CAST(userid AS decimal(18,2))       AS userid
    , CAST(prwid AS decimal(18,2))        AS prwid
    , CAST(cdtwid AS decimal(18,2))       AS cdtwid
    , CAST(systemobject AS decimal(18,2)) AS systemobject
    , CAST(investorname AS string)        AS investorname
    , CAST(yearvalue AS decimal(18,2))    AS yearvalue
    , CAST(periodtype AS decimal(18,2))   AS periodtype
    , CAST(periodvalue AS string)         AS periodvalue
    , CAST(status AS int)                 AS status
    , CAST(value AS decimal(18,2))        AS value
    , CAST(datecreatedviolt AS date)      AS datecreatedviolt
    , CAST(fundcomid AS decimal(18,2))    AS fundcomid
    , CAST(seccomid AS decimal(18,2))     AS seccomid
    , CAST(bankid AS decimal(18,2))       AS bankid
    , CAST(depcenid AS decimal(18,2))     AS depcenid
    , CAST(stockcenid AS decimal(18,2))   AS stockcenid
    , CAST(indirepcenid AS decimal(18,2)) AS indirepcenid
    , CAST(branchsid AS decimal(18,2))    AS branchsid
    , CAST(periodtypeother AS bigint)     AS periodtypeother
    , CAST(periodvalueother AS string)    AS periodvalueother
    , CAST(valueother AS decimal(18,2))   AS valueother
    , CAST(paraname AS string)            AS paraname
    , CAST(resolvedby AS string)          AS resolvedby
    , CAST(resolveddate AS timestamp)     AS resolveddate
    , CAST(investorcode AS string)        AS investorcode
FROM {{ source('source_fims', 'raw_violt') }}
WHERE date_format(datecreatedviolt, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreatedviolt, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1