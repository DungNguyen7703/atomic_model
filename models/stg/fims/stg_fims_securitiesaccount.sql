/*
*--------------------------------------------------------------------*
* Program code: stg_fims_securitiesaccount
* Program name: Staging FIMS.SECURITIESACCOUNT
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
    , CAST(invesid AS bigint)         AS invesid
    , CAST(secid AS bigint)           AS secid
    , CAST(account AS string)         AS account
    , CAST(openplace AS string)       AS openplace
    , CAST(deleted AS int)            AS deleted
    , CAST(datecreated AS timestamp)  AS datecreated
    , CAST(datemodified AS timestamp) AS datemodified
    , CAST(createdby AS string)       AS createdby
    , CAST(modifyby AS string)        AS modifyby
FROM {{ source('source_fims', 'raw_securitiesaccount') }}