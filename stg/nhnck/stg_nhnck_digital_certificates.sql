/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_digital_certificates
* Program name: Staging NHNCK.DIGITAL_CERTIFICATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); kieu date sang timestamp (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(subject AS string)       AS subject
    , CAST(company_name AS string)  AS company_name
    , CAST(tax_code AS string)      AS tax_code
    , CAST(email AS string)         AS email
    , CAST(issuer AS string)        AS issuer
    , CAST(serial_number AS string) AS serial_number
    , CAST(valid_from AS timestamp) AS valid_from
    , CAST(valid_to AS timestamp)   AS valid_to
    , CAST(base64_data AS string)   AS base64_data
    , CAST(thumbprint AS string)    AS thumbprint
    , CAST(full_data AS string)     AS full_data
    , CAST(status AS bigint)        AS status
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_by AS bigint)    AS updated_by
FROM {{ source('source_nhnck', 'raw_digital_certificates') }}