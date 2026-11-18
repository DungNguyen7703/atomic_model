/*
*--------------------------------------------------------------------*
* Program code: stg_fms_nhnck_practice_confirm_req
* Program name: Staging FMS.NHNCK_PRACTICE_CONFIRM_REQ
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(request_id AS string)                    AS request_id
    , CAST(conversion_request_id AS decimal(19,0))  AS conversion_request_id
    , CAST(organization_ref AS string)              AS organization_ref
    , CAST(license_number AS string)                AS license_number
    , CAST(organization_tax_code AS string)         AS organization_tax_code
    , CAST(organization_name AS string)             AS organization_name
    , CAST(full_name AS string)                     AS full_name
    , CAST(identity_number AS string)               AS identity_number
    , CAST(declared_work_history_json AS string)    AS declared_work_history_json
    , CAST(content_text AS string)                  AS content_text
    , CAST(attachment_urls_json AS string)          AS attachment_urls_json
    , CAST(requested_by AS string)                  AS requested_by
    , CAST(requested_at AS timestamp)               AS requested_at
    , CAST(record_status AS string)                 AS record_status
    , CAST(result_code AS string)                   AS result_code
    , CAST(corrected_work_history_json AS string)   AS corrected_work_history_json
    , CAST(reason_text AS string)                   AS reason_text
    , CAST(responded_by AS string)                  AS responded_by
    , CAST(responded_at AS timestamp)               AS responded_at
    , CAST(received_at AS timestamp)                AS received_at
    , CAST(date_created AS timestamp)               AS date_created
    , CAST(created_by AS string)                    AS created_by
    , CAST(date_modified AS timestamp)              AS date_modified
    , CAST(modify_by AS string)                     AS modify_by
    , HEX(id)                                       AS id
    , HEX(sec_id)                                   AS sec_id
    , CAST(confirm_parties AS string)               AS confirm_parties
    , CAST(organization_report_id AS decimal(19,0)) AS organization_report_id
    , CAST(report_kind AS string)                   AS report_kind
    , CAST(hire_date AS timestamp)                  AS hire_date
    , CAST(termination_date AS timestamp)           AS termination_date
    , CAST(org_confirm_status AS string)            AS org_confirm_status
    , CAST(org_result_code AS string)               AS org_result_code
    , CAST(org_reason_text AS string)               AS org_reason_text
    , CAST(org_responded_by AS string)              AS org_responded_by
    , CAST(org_responded_at AS timestamp)           AS org_responded_at
    , CAST(committee_confirm_status AS string)      AS committee_confirm_status
    , CAST(committee_result_code AS string)         AS committee_result_code
    , CAST(committee_reason_text AS string)         AS committee_reason_text
    , CAST(committee_responded_by AS string)        AS committee_responded_by
    , CAST(committee_responded_at AS timestamp)     AS committee_responded_at
FROM {{ source('source_fms', 'raw_nhnck_practice_confirm_req') }}