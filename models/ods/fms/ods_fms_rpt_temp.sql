/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rpt_temp
* Program name: ODS FMS.RPT_TEMP
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo — nguồn cho Atomic FMS (sync LLD Atomic FMS UAT 20261006)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , legal_basis
    , report_type
    , require_disclosure
    , require_import
    , description
    , file_data
    , record_status
    , self_member_setting
    , deleted
    , financial_report
    , version
    , ftype_id
    , report_group
    , system_objects
    , code
    , audit_report
    , check_price_setting
    , date_used
    , eform_enabled
    , eform_schema_json
FROM {{ ref('stg_fms_rpt_temp') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1