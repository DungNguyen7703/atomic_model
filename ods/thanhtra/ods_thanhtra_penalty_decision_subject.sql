/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_decision_subject
* Program name: ODS THANHTRA.PENALTY_DECISION_SUBJECT
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
    , penalty_decision_id
    , subject_type
    , subject_name
    , subject_id_number
    , subject_dob
    , subject_address
    , subject_legal_rep
    , subject_legal_rep_title
    , total_fine_amount
    , paid_amount
    , coerced_amount
    , payment_received_date
    , compliance_status
    , enforcement_progress
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , payment_proof_url
    , payment_proof_uploaded_at
    , subject_tax_code
    , subject_email
    , subject_phone
    , email_sent_at
    , sms_sent_at
    , violation_record_id
    , receipt_status
    , viewed_at
    , downloaded_at
    , confirmed_at
    , received_at
FROM {{ ref('stg_thanhtra_penalty_decision_subject') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0