/*
*--------------------------------------------------------------------*
* Program code: ods_scms_lnk_event_type_form
* Program name: ODS SCMS.LNK_EVENT_TYPE_FORM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD SCMS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , event_type_id
    , form_report_id
    , applicable_from
    , applicable_to
    , required
    , sort_order
    , record_status
FROM {{ ref('stg_scms_lnk_event_type_form') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')