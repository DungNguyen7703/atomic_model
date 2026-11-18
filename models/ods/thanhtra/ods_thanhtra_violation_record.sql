/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_record
* Program name: ODS THANHTRA.VIOLATION_RECORD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_VIOLATION_RECORD.yaml] them cot email_sent_at, sms_sent_at (cuoi danh sach)
* 2026-11-03		nghia.le			[DDL moi THANHTRA.VIOLATION_RECORD] them cot no_longer_violation, no_longer_violation_note, no_longer_violation_at, no_longer_violation_by, violation_time_from, violation_time_to (cuoi danh sach)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , record_number
    , record_date
    , record_type
    , inspection_team_id
    , examination_team_id
    , violation_time
    , location
    , source_info
    , recorder_name
    , recorder_title
    , recorder_unit
    , subject_type
    , subject_name
    , subject_id_number
    , subject_dob
    , subject_address
    , subject_legal_rep
    , subject_legal_rep_title
    , subject_email
    , subject_phone
    , status
    , signed_by
    , signed_at
    , numbered_at
    , sent_at
    , sent_to_inspector
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , forwarded_to_inspection
    , forwarded_at
    , forwarded_by
    , violator_signed_file_url
    , violator_confirmed_receipt_at
    , violator_confirmed_by
    , recorder_unit_id
    , signature_type
    , first_signed_by
    , first_signed_at
    , signed_document_url
    , receipt_status
    , viewed_at
    , downloaded_at
    , uploaded_signed_at
    , assigned_signer_name
    , assigned_signer_id
    , assigned_leader_signer_id
    , assigned_leader_signer_name
    , created_by_ban_role
    , signing_flow
    , email_sent_at
    , sms_sent_at
    , no_longer_violation
    , no_longer_violation_note
    , no_longer_violation_at
    , no_longer_violation_by
    , violation_time_from
    , violation_time_to
FROM {{ ref('stg_thanhtra_violation_record') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0