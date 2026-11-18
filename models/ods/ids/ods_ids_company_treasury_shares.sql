/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_treasury_shares
* Program name: ODS IDS.COMPANY_TREASURY_SHARES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD IDS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , company_profile_id
    , transaction_type_cd
    , consulting_org
    , audit_org
    , other_org
    , official_letter_no
    , official_letter_date
    , approval_status_cd
    , administrative_status_cd
    , approver_user_id
    , approver_user_name
    , processor_user_id
    , processor_user_name
    , revision_reason
    , total_treasury_share_before
    , latest_treasury_trans_qty
    , latest_treasury_trans_date
    , latest_offering_end_date
    , total_registered_trans_qty
    , par_value
    , treasury_trans_purpose
    , planned_trans_start_date
    , planned_trans_end_date
    , transaction_method
    , pricing_method
    , daily_trans_qty
    , min_trans_price
    , max_trans_price
    , securities_agent_name_vi
    , securities_agent_name_en
    , securities_agent_addr
    , securities_agent_phone
    , certificate_no
    , certificate_date
    , administrative_proc_cd
    , application_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , submission_date
    , approver_comment
    , legal_entity_id
    , funding_source
FROM {{ ref('stg_ids_company_treasury_shares') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')