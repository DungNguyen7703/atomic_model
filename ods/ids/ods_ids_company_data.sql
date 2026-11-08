/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_data
* Program name: ODS IDS.COMPANY_DATA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-04		tuan.nguyenvanb		Bo 11 cot khong ton tai thuc te tren STG/nguon Oracle
*                                       that (alert_audit, system_cd, close_date,
*                                       securities_offering_id, disclosure_type,
*                                       legal_entity_id, company_tender_offer_id,
*                                       company_treasury_share_id, approver_user_id,
*                                       approver_user_name, flattened_flg) - da doi chieu
*                                       lai voi stg_ids_company_data.sql that tren UAT,
*                                       xac nhan STG chua bao gio co 11 cot nay.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , company_profile_id
    , doc_title
    , form_id
    , news_status_cd
    , report_year
    , report_quarter
    , report_month
    , parent_id
    , doc_no
    , doc_date
    , doc_summary
    , doc_sign_date
    , submission_date
    , approval_date
    , rejection_date
    , submission_deadline_date
    , overdue_days
    , ref_id
    , digital_signature_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , news_type_cd
    , reject_reason
    , review_date
    , send_back_date
    , link_id
    , language_cd
FROM {{ ref('stg_ids_company_data') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')