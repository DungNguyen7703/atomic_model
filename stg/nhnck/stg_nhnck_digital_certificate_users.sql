/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_digital_certificate_users
* Program name: Staging NHNCK.DIGITAL_CERTIFICATE_USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(digital_certificate_id AS bigint) AS digital_certificate_id
    , CAST(user_id AS bigint)                AS user_id
    , CAST(role AS string)                   AS role
    , CAST(status AS bigint)                 AS status
    , CAST(notes AS string)                  AS notes
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(created_by AS bigint)             AS created_by
    , CAST(updated_by AS bigint)             AS updated_by
FROM {{ source('source_nhnck', 'raw_digital_certificate_users') }}