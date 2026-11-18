/*
*--------------------------------------------------------------------*
* Program code: ods_fms_offering
* Program name: ODS FMS.OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		tuan.nguyenvanb		[LLD atomic lld_FMS_OFFERING.yaml approved] Dung lai ODS cho FMS.OFFERING (nguon STG stg_fms_offering) phuc vu atomic fmc_securities_offering.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sec_id
    , deleted
    , tthc_name
    , offering_type
    , securities_type
    , securities_name
    , par_value
    , quantity_offered
    , offering_price
    , total_registered_value
    , purpose
    , capital_usage_plan
    , expected_start_date
    , expected_end_date
    , guarantor_org
    , advisory_org
    , offering_method
    , target_audience
    , capital_purpose
    , offering_start_date
    , offering_end_date
    , extended
    , actual_target
    , quantity_sold
    , actual_price
    , actual_total_value
    , employee_count
    , foreign_investor_count
    , issuance_value
    , date_created
    , created_by
    , date_modified
    , modify_by
    , approval_document_no
    , approval_document_date
    , data_source
    , affair_code
    , stock_class
    , tthc_external_id
    , approval_document_file_name
    , report_result_date
    , extended_to_date
    , assessment
    , result_attachment_file
    , note_text
    , bond_type
    , bond_term_years
    , interest_payment_period
    , bondholder_representative
    , collateral_secured
FROM {{ ref('stg_fms_offering') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
