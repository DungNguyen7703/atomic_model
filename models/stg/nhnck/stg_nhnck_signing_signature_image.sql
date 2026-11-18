/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_signature_image
* Program name: Staging NHNCK.SIGNING_SIGNATURE_IMAGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(owner_user_ref AS string) AS owner_user_ref
    , CAST(name AS string)          AS name
    , CAST(file_path AS string)     AS file_path
    , CAST(file_name AS string)     AS file_name
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
FROM {{ source('source_nhnck', 'raw_signing_signature_image') }}
