/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_profile_change
* Program name: ODS SCMS.SC_FIRM_PROFILE_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Doi ten cot theo stg moi (SCMS_UAT_schema).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , entity_type
    , entity_id
    , subject_display_name
    , execution_time
    , event_type_id
    , event_type_name
    , before_info
    , after_info
    , license_decision_doc_number
    , effective_date
    , has_approval_doc
    , performed_by
    , performer_name
    , after_data_json
    , admin_procedure_profile_id
FROM {{ ref('stg_scms_sc_firm_profile_change') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')