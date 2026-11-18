/*
*--------------------------------------------------------------------*
* Program code: stg_fms_nhnck_paper_cert_notice
* Program name: Staging FMS.NHNCK_PAPER_CERT_NOTICE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(conversion_request_id AS decimal(19,0))  AS conversion_request_id
    , CAST(identity_number AS string)               AS identity_number
    , CAST(full_name AS string)                     AS full_name
    , CAST(certificate_numbers_json AS string)      AS certificate_numbers_json
    , CAST(organization_ref AS string)              AS organization_ref
    , CAST(license_number AS string)                AS license_number
    , CAST(organization_tax_code AS string)         AS organization_tax_code
    , CAST(organization_name AS string)             AS organization_name
    , CAST(submitted_at AS timestamp)               AS submitted_at
    , CAST(message_text AS string)                  AS message_text
    , CAST(received_at AS timestamp)                AS received_at
    , CAST(date_created AS timestamp)               AS date_created
    , CAST(created_by AS string)                    AS created_by
    , CAST(date_modified AS timestamp)              AS date_modified
    , CAST(modify_by AS string)                     AS modify_by
    , HEX(id)                                       AS id
    , HEX(sec_id)                                   AS sec_id
    , CAST(request_id AS string)                    AS request_id
    , CAST(organization_report_id AS decimal(19,0)) AS organization_report_id
    , CAST(report_kind AS string)                   AS report_kind
FROM {{ source('source_fms', 'raw_nhnck_paper_cert_notice') }}