/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tradingauthorization
* Program name: Staging FIMS.TRADINGAUTHORIZATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(systemobject AS bigint)            AS systemobject
    , CAST(fundcomid AS bigint)               AS fundcomid
    , CAST(seccomid AS bigint)                AS seccomid
    , CAST(investorid AS bigint)              AS investorid
    , CAST(authorizationtypeid AS bigint)     AS authorizationtypeid
    , CAST(status AS bigint)                  AS status
    , CAST(filedata AS string)                AS filedata
    , CAST(filename AS string)                AS filename
    , CAST(sdate AS date)                     AS sdate
    , CAST(edate AS date)                     AS edate
    , CAST(note AS string)                    AS note
    , CAST(investorids AS string)             AS investorids
    , CAST(idold AS string)                   AS idold
    , CAST(deleted AS int)                    AS deleted
    , CAST(datecreated AS timestamp)          AS datecreated
    , CAST(datemodified AS timestamp)         AS datemodified
    , CAST(createdby AS string)               AS createdby
    , CAST(modifyby AS string)                AS modifyby
    , CAST(tradingrepresentativeid AS bigint) AS tradingrepresentativeid
FROM {{ source('source_fims', 'raw_tradingauthorization') }}