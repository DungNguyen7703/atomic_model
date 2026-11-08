/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_tender_offer_result
* Program name: ODS IDS.COMPANY_TENDER_OFFER_RESULT
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
    , company_tender_offer_id
    , registered_sale_share_qty
    , registered_sale_investor_qty
    , actual_purchased_share_qty
    , actual_purchased_ownership_ratio
    , actual_purchased_investor_qty
    , total_funding_am
    , post_offer_share_qty
    , post_offer_ownership_ratio
    , actual_offer_end_date
    , securities_agent_name_vi
    , securities_agent_name_en
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
    , offering_phase_name
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , approver_comment
    , result_report_date
    , extension_date
FROM {{ ref('stg_ids_company_tender_offer_result') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')