/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_archives
* Program name: Staging NHNCK.CERTIFICATE_ARCHIVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (8 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                           AS id
    , CAST(certificate_id AS bigint)             AS certificate_id
    , CAST(professional_id AS bigint)            AS professional_id
    , CAST(certificate_record_id AS bigint)      AS certificate_record_id
    , CAST(nationality_id AS bigint)             AS nationality_id
    , CAST(archive_number AS string)             AS archive_number
    , CAST(certificate_number AS string)         AS certificate_number
    , CAST(archive_date AS date)                 AS archive_date
    , CAST(received_date AS date)                AS received_date
    , CAST(recipient AS string)                  AS recipient
    , CAST(identity_number AS string)            AS identity_number
    , CAST(introduction_letter_number AS string) AS introduction_letter_number
    , CAST(introduction_letter AS string)        AS introduction_letter
    , CAST(note AS string)                       AS note
    , CAST(payment_status AS bigint)             AS payment_status
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(created_by AS bigint)                 AS created_by
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(updated_by AS bigint)                 AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_archives') }}