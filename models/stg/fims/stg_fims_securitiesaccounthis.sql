/*
*--------------------------------------------------------------------*
* Program code: stg_fims_securitiesaccounthis
* Program name: Staging FIMS.SECURITIESACCOUNTHIS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))        AS id
    , CAST(secid AS decimal(18,2))   AS secid
    , CAST(invesid AS decimal(18,2)) AS invesid
    , CAST(account AS string)        AS account
FROM {{ source('source_fims', 'raw_securitiesaccounthis') }}