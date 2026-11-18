/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_verification_code
* Program name: Staging IAM.USER_VERIFICATION_CODE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(username AS string)         AS username
    , CAST(email AS string)            AS email
    , CAST(code_hash AS string)        AS code_hash
    , CAST(expired_at AS timestamp)    AS expired_at
    , CAST(verified_at AS timestamp)   AS verified_at
    , CAST(used_at AS timestamp)       AS used_at
    , CAST(resend_count AS int)        AS resend_count
    , CAST(first_sent_at AS timestamp) AS first_sent_at
    , CAST(locked_until AS timestamp)  AS locked_until
    , CAST(attempt_count AS int)       AS attempt_count
    , CAST(created_ip AS string)       AS created_ip
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_iam', 'raw_user_verification_code') }}