/*
*--------------------------------------------------------------------*
* Program code: stg_fims_tradingrepresentative
* Program name: Staging FIMS.TRADINGREPRESENTATIVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(fullname AS string)        AS fullname
    , CAST(sex AS string)             AS sex
    , CAST(dateofbirth AS date)       AS dateofbirth
    , CAST(idno AS string)            AS idno
    , CAST(naid AS bigint)            AS naid
    , CAST(address AS string)         AS address
    , CAST(telephone AS string)       AS telephone
    , CAST(email AS string)           AS email
    , CAST(fax AS string)             AS fax
    , CAST(statusid AS bigint)        AS statusid
    , CAST(description AS string)     AS description
    , CAST(createdby AS string)       AS createdby
    , CAST(datecreated AS timestamp)  AS datecreated
    , CAST(modifyby AS string)        AS modifyby
    , CAST(datemodified AS timestamp) AS datemodified
    , CAST(deleted AS int)            AS deleted
    , CAST(provinceid AS bigint)      AS provinceid
    , CAST(wardid AS bigint)          AS wardid
FROM {{ source('source_fims', 'raw_tradingrepresentative') }}