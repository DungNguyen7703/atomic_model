/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_csidxinfor
* Program name: Staging MDDS.JAD_CSIDXINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/
{% set etl_date = modules.datetime.datetime.strptime(var("etl_date"), "%Y-%m-%d").strftime("%d/%m/%Y") %}

SELECT
    CAST(id AS string)            AS id
    , CAST(indexcode AS string)   AS indexcode
    , CAST(symbol AS string)      AS symbol
    , CAST(totalqtty AS string)   AS totalqtty
    , CAST(adddate AS string)     AS adddate
    , CAST(indexid AS int)        AS indexid
    , CAST(floorcode AS string)   AS floorcode
    , to_date(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , CAST(stockno AS string)     AS stockno
    , CAST(weighted AS string)    AS weighted
FROM {{ source('source_mdds', 'raw_jad_csidxinfor') }}
WHERE tradingdate = '{{ etl_date }}'