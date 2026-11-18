/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_conversion_requests
* Program name: Staging NHNCK.CERTIFICATE_CONVERSION_REQUESTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (8 cot); kieu date sang timestamp (3 cot); doi thu tu cot.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(certificate_record_id AS bigint) AS certificate_record_id
    , CAST(status AS bigint)                AS status
    , CAST(notes AS string)                 AS notes
    , CAST(processed_at AS timestamp)       AS processed_at
    , CAST(processed_by AS bigint)          AS processed_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS bigint)            AS created_by
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by AS bigint)            AS updated_by
    , CAST(request_payload AS string)       AS request_payload
    , CAST(assignee_id AS bigint)           AS assignee_id
    , CAST(info_verify_id AS bigint)        AS info_verify_id
FROM {{ source('source_nhnck', 'raw_certificate_conversion_requests') }}