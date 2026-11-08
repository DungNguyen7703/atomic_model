/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_applications
* Program name: ODS NHNCK.APPLICATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , professional_id
    , status_id
    , certificate_id
    , certificate_record_id
    , previous_certificate_id
    , previous_certificate_record_id
    , exam_session_id
    , registration_type
    , application_type
    , application_code
    , title
    , submission_date
    , supplement_date
    , reissue_reason
    , rejection_reason
    , certificate_number
    , issue_date
    , previous_certificate_number
    , previous_issue_date
    , note
    , is_violated
    , is_data_exploitable
    , assignee_id
    , info_verify_id
    , certificate_receipt_method
    , certificate_receipt_address
    , receipt_status
    , supplement_letter_date
    , certificate_receipt_phone
    , reissue_hsm
    , created_at
    , updated_at
    , updated_by
    , created_by
    , mcdt_content_item_id
FROM {{ ref('stg_nhnck_applications') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')