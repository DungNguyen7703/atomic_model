/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_inspection_schedule
* Program name: Staging SCMS.SC_FIRM_INSPECTION_SCHEDULE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot); kieu int sang decimal(38,0) (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (8 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: start_date, end_date, decision_date, conclusion_doc_date, to_date, from_date, period_to_date, period_from_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(sc_firm_info_id AS bigint)          AS sc_firm_info_id
    , CAST(record_type AS string)              AS record_type
    , CAST(amount AS decimal(38,0))            AS amount
    , CAST(start_date AS date)            AS start_date
    , CAST(end_date AS date)              AS end_date
    , CAST(decision_content AS string)         AS decision_content
    , CAST(decision_date AS date)         AS decision_date
    , CAST(inspector_name AS string)           AS inspector_name
    , CAST(created_by AS bigint)               AS created_by
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(last_modified_by AS bigint)         AS last_modified_by
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(record_status AS int)               AS record_status
    , CAST(attachment_path AS string)          AS attachment_path
    , CAST(implementing_unit AS string)        AS implementing_unit
    , CAST(decision_file_path AS string)       AS decision_file_path
    , CAST(conclusion_doc_file_path AS string) AS conclusion_doc_file_path
    , CAST(form_type AS string)                AS form_type
    , CAST(conclusion_summary AS string)       AS conclusion_summary
    , CAST(recommendations AS string)          AS recommendations
    , CAST(inspection_type AS string)          AS inspection_type
    , CAST(conclusion_doc_date AS date)   AS conclusion_doc_date
    , CAST(decision_number AS string)          AS decision_number
    , CAST(conclusion_doc_number AS string)    AS conclusion_doc_number
    , CAST(inspection_team_json AS string)     AS inspection_team_json
    , CAST(to_date AS date)               AS to_date
    , CAST(from_date AS date)             AS from_date
    , CAST(period_to_date AS date)        AS period_to_date
    , CAST(period_from_date AS date)      AS period_from_date
    , CAST(team_leader AS string)              AS team_leader
    , CAST(content AS string)                  AS content
    , CAST(deleted AS int)                     AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_inspection_schedule') }}