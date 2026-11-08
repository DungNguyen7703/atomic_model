/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_digital_certificates
* Program name: Staging THANHTRA.DIGITAL_CERTIFICATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(subject AS string)             AS subject
    , CAST(company_name AS string)        AS company_name
    , CAST(tax_code AS string)            AS tax_code
    , CAST(email AS string)               AS email
    , CAST(issuer AS string)              AS issuer
    , CAST(serial_number AS string)       AS serial_number
    , CAST(valid_from AS date)            AS valid_from
    , CAST(valid_to AS date)              AS valid_to
    , CAST(base64_data AS string)         AS base64_data
    , CAST(thumbprint AS string)          AS thumbprint
    , CAST(full_data AS string)           AS full_data
    , CAST(status AS string)              AS status
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS decimal(19,0))      AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_digital_certificates') }}