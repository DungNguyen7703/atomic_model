/*
*--------------------------------------------------------------------*
* Program code: ods_scms_alert_indicator
* Program name: ODS SCMS.ALERT_INDICATOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , alert_code
    , alert_name
    , legal_reference_id
    , legal_reference
    , severity_level
    , note
    , default_value
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , sum_formula
    , formula_text
    , formula
    , alert_indicator_type
    , unit
    , indicator_type_id
    , indicator_code
    , description
    , severity
    , lower_threshold
    , upper_threshold
    , indicator_name
    , sort_order
    , weight
    , legal_basis
    , cb_alert_group_id
    , result_data_type
    , derivative_business_id
    , derivative_business_scope
    , result_unit_scale
FROM {{ ref('stg_scms_alert_indicator') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')