/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_records
* Program name: Staging NHNCK.CERTIFICATE_RECORDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (12 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(certificate_id AS bigint)           AS certificate_id
    , CAST(professional_id AS bigint)          AS professional_id
    , CAST(issue_decision_id AS bigint)        AS issue_decision_id
    , CAST(revocation_decision_id AS bigint)   AS revocation_decision_id
    , CAST(certificate_number AS string)       AS certificate_number
    , CAST(issue_date AS date)                 AS issue_date
    , CAST(revocation_date AS date)            AS revocation_date
    , CAST(revocation_reason AS string)        AS revocation_reason
    , CAST(status AS bigint)                   AS status
    , CAST(description AS string)              AS description
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS bigint)               AS created_by
    , CAST(allow_reissue AS bigint)            AS allow_reissue
    , CAST(professional_full_name AS string)   AS professional_full_name
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(process_status AS bigint)           AS process_status
    , CAST(cer_path AS string)                 AS cer_path
    , CAST(cancellation_decision_id AS bigint) AS cancellation_decision_id
    , CAST(conversion_status AS bigint)        AS conversion_status
    , CAST(updated_by AS bigint)               AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_records') }}