/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_admin_penalty_decision
* Program name: ODS SCMS.SC_FIRM_ADMIN_PENALTY_DECISION
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
    , sc_firm_info_id
    , registered_address
    , decision_file_path
    , note
    , violation_acts_json
    , penalty_form
    , tax_code_business_license
    , issued_date
    , last_modified_at
    , sync_date
    , created_at
    , last_modified_by
    , signatory
    , created_by
    , data_source
    , decision_number
    , paid_amount
    , fine_amount
    , fine_payment_deadline
    , total_fine_amount
    , implementation_status
FROM {{ ref('stg_scms_sc_firm_admin_penalty_decision') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')