/*
*--------------------------------------------------------------------*
* Program code: stg_fims_certfcate
* Program name: Staging FIMS.CERTFCATE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))       AS id
    , CAST(userid AS decimal(18,2)) AS userid
    , CAST(keys AS string)          AS keys
    , CAST(serial AS string)        AS serial
    , CAST(subject AS string)       AS subject
    , CAST(issuer AS string)        AS issuer
    , CAST(type AS int)             AS type
    , CAST(status AS int)           AS status
    , CAST(isdatamigration AS int)  AS isdatamigration
    , CAST(idold AS string)         AS idold
FROM {{ source('source_fims', 'raw_certfcate') }}