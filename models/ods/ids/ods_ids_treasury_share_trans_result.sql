/*
*--------------------------------------------------------------------*
* Program code: ods_ids_treasury_share_trans_result
* Program name: ODS IDS.TREASURY_SHARE_TRANS_RESULT
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
    , company_treasury_share_id
    , registered_trans_qty
    , executed_trans_qty
    , total_treasury_share_before
    , total_treasury_share_after
    , treasury_trans_purpose
    , average_trans_price
    , trans_start_date
    , trans_end_date
    , transaction_method
    , securities_agent_name_vi
    , securities_agent_name_en
    , unexecuted_qty_reason
    , certificate_no
    , certificate_date
    , official_letter_no
    , official_letter_date
    , approval_status_cd
    , approver_user_id
    , approver_user_name
    , processor_user_id
    , processor_user_name
    , revision_reason
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , approver_comment
    , result_report_date
    , extension_date
    , funding_source
FROM {{ ref('stg_ids_treasury_share_trans_result') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')