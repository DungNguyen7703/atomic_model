/*
*--------------------------------------------------------------------*
* Program code: stg_fims_closing_price_securities
* Program name: Staging FIMS.CLOSING_PRICE_SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(seccode AS string)           AS seccode
    , CAST(tradedate AS date)           AS tradedate
    , CAST(closeprice AS decimal(20,6)) AS closeprice
    , CAST(source AS string)            AS source
    , CAST(isfake AS int)               AS isfake
    , CAST(datecreated AS timestamp)    AS datecreated
FROM {{ source('source_fims', 'raw_closing_price_securities') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreated, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1