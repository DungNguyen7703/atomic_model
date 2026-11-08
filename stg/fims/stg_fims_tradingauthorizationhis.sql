/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tradingauthorizationhis
* Program name: Staging FIMS.TRADINGAUTHORIZATIONHIS
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
    , CAST(tradingauthorizationid AS bigint)    AS tradingauthorizationid
    , CAST(actionname AS string)                AS actionname
    , CAST(note AS string)                      AS note
    , CAST(datecreated AS timestamp)            AS datecreated
    , CAST(createdby AS string)                 AS createdby
    , CAST(version AS bigint)                   AS version
    , CAST(tradingrepresentativeid AS bigint)   AS tradingrepresentativeid
    , CAST(tradingrepresentativename AS string) AS tradingrepresentativename
    , CAST(sdate AS date)                       AS sdate
    , CAST(edate AS date)                       AS edate
    , CAST(filedata AS string)                  AS filedata
    , CAST(filename AS string)                  AS filename
    , CAST(investorids AS string)               AS investorids
    , CAST(investornames AS string)             AS investornames
    , CAST(oldrecordjson AS string)             AS oldrecordjson
FROM {{ source('source_fims', 'raw_tradingauthorizationhis') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreated, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1