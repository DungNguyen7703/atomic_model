/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tradingauthorizationinveshis
* Program name: Staging FIMS.TRADINGAUTHORIZATIONINVESHIS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                          AS id
    , CAST(tradingauthorizationhisid AS bigint) AS tradingauthorizationhisid
    , CAST(investorid AS bigint)                AS investorid
    , CAST(investorname AS string)              AS investorname
    , CAST(datecreated AS timestamp)            AS datecreated
    , CAST(createdby AS string)                 AS createdby
FROM {{ source('source_fims', 'raw_tradingauthorizationinveshis') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreated, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1