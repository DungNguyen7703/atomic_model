/*
*--------------------------------------------------------------------*
* Program code: stg_fms_cert_fcate
* Program name: Staging FMS.CERT_FCATE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , HEX(user_id)                AS user_id
    , CAST(keys AS string)        AS keys
    , CAST(serial AS string)      AS serial
    , CAST(subject AS string)     AS subject
    , CAST(issuer AS string)      AS issuer
    , CAST(record_type AS int)    AS record_type
    , CAST(record_status AS int)  AS record_status
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_cert_fcate') }}