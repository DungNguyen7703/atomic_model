/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_session
* Program name: Staging NHNCK.SIGNING_SESSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(document_path AS string)        AS document_path
    , CAST(prepared_path AS string)        AS prepared_path
    , CAST(target_path AS string)          AS target_path
    , CAST(profile_key AS string)          AS profile_key
    , CAST(signer_user_ref AS string)      AS signer_user_ref
    , CAST(signer_name AS string)          AS signer_name
    , CAST(signature_mode AS string)       AS signature_mode
    , CAST(hash_base64 AS string)          AS hash_base64
    , CAST(document_hash_base64 AS string) AS document_hash_base64
    , CAST(hash_algorithm AS string)       AS hash_algorithm
    , CAST(signer_cert_base64 AS string)   AS signer_cert_base64
    , CAST(status AS string)               AS status
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(expires_at AS timestamp)        AS expires_at
    , CAST(error_message AS string)        AS error_message
FROM {{ source('source_nhnck', 'raw_signing_session') }}
