/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_digital_certificate_users
* Program name: Staging THANHTRA.DIGITAL_CERTIFICATE_USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(digital_certificate_id AS string) AS digital_certificate_id
    , CAST(user_id AS string)                AS user_id
    , CAST(role AS string)                   AS role
    , CAST(status AS string)                 AS status
    , CAST(notes AS string)                  AS notes
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(created_by AS string)             AS created_by
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(last_modified_by AS string)       AS last_modified_by
    , CAST(version AS decimal(19,0))         AS version
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_thanhtra', 'raw_digital_certificate_users') }}