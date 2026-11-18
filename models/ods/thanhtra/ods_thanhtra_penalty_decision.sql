/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_decision
* Program name: ODS THANHTRA.PENALTY_DECISION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_PENALTY_DECISION.yaml] Them cot enforcement_status, confiscated_asset_sale_amount, other_penalty_revenue_amount, report_classification (cuoi danh sach, sau approver_name)
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , decision_number
    , issued_date
    , signer_id
    , signer_name
    , violation_case_id
    , decision_category
    , assigned_officer_id
    , assigned_officer_name
    , anti_money_laundering
    , total_fine_amount
    , payment_deadline
    , status
    , complaint_exists
    , complaint_content
    , complaint_received_date
    , complaint_status
    , complaint_result
    , lawsuit_exists
    , lawsuit_content
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , submitted_by_id
    , approver_id
    , submitted_at
    , signed_document_url
    , summary
    , reviewer_id
    , reviewer_name
    , reviewed_at
    , source_document_url
    , reviewed_by_id
    , approver_name
    , enforcement_status
    , confiscated_asset_sale_amount
    , other_penalty_revenue_amount
    , report_classification
FROM {{ ref('stg_thanhtra_penalty_decision') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0