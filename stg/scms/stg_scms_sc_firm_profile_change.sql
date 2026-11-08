/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_profile_change
* Program name: Staging SCMS.SC_FIRM_PROFILE_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang decimal(19,0) (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: effective_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                   AS id
    , CAST(sc_firm_info_id AS decimal(19,0))      AS sc_firm_info_id
    , CAST(entity_type AS string)                 AS entity_type
    , CAST(entity_id AS decimal(19,0))            AS entity_id
    , CAST(subject_display_name AS string)        AS subject_display_name
    , CAST(execution_time AS timestamp)           AS execution_time
    , CAST(event_type_id AS decimal(19,0))        AS event_type_id
    , CAST(event_type_name AS string)             AS event_type_name
    , CAST(before_info AS string)                 AS before_info
    , CAST(after_info AS string)                  AS after_info
    , CAST(license_decision_doc_number AS string) AS license_decision_doc_number
    , CAST(effective_date AS date)           AS effective_date
    , CAST(has_approval_doc AS int)               AS has_approval_doc
    , CAST(performed_by AS decimal(19,0))         AS performed_by
    , CAST(performer_name AS string)              AS performer_name
    , CAST(after_data_json AS string)             AS after_data_json
    , CAST(admin_procedure_profile_id AS string)  AS admin_procedure_profile_id
FROM {{ source('source_scms', 'raw_sc_firm_profile_change') }}