/*
*--------------------------------------------------------------------*
* Program code: ods_ids_securities_offering_result
* Program name: ODS IDS.SECURITIES_OFFERING_RESULT
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
    , securities_offering_id
    , offering_phase_name
    , result_report_date
    , offering_end_date
    , offering_method_cd
    , security_type_cd
    , total_successful_qty
    , actual_offering_price
    , total_collected_am
    , successful_ratio
    , issuer_successful_qty
    , shareholder_successful_qty
    , issuer_collected_am
    , shareholder_collected_am
    , capital_source
    , employee_qty
    , domestic_successful_qty
    , domestic_collected_am
    , foreign_successful_qty
    , foreign_collected_am
    , post_issuance_total_qty
    , total_treasury_share
    , total_outstanding_share
    , domestic_offering_price
    , domestic_offering_qty
    , domestic_registered_qty
    , domestic_distributed_qty
    , domestic_reg_investor_qty
    , domestic_dist_investor_qty
    , domestic_undist_investor_qty
    , domestic_remaining_qty
    , domestic_distributed_pct
    , foreign_offering_price
    , foreign_offering_qty
    , foreign_registered_qty
    , foreign_distributed_qty
    , foreign_reg_investor_qty
    , foreign_dist_investor_qty
    , foreign_undist_investor_qty
    , foreign_remaining_qty
    , foreign_distributed_pct
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
    , total_expense
    , underwriting_fee
    , distribution_fee
    , audit_fee
    , other_expense
    , net_offering_proceeds
    , is_sync
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , extension_date
    , bond_ticker
    , result_single_obj
    , approver_comment
FROM {{ ref('stg_ids_securities_offering_result') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')