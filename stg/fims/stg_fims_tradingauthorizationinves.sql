/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tradingauthorizationinves
* Program name: Staging FIMS.TRADINGAUTHORIZATIONINVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(tradingauthorizationid AS bigint) AS tradingauthorizationid
    , CAST(investorid AS bigint)             AS investorid
    , CAST(deleted AS int)                   AS deleted
    , CAST(datecreated AS timestamp)         AS datecreated
    , CAST(createdby AS string)              AS createdby
FROM {{ source('source_fims', 'raw_tradingauthorizationinves') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreated, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1