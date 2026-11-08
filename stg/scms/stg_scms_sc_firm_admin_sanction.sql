/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_admin_sanction
* Program name: Staging SCMS.SC_FIRM_ADMIN_SANCTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot); kieu int sang decimal(38,0) (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: additional_penalty_date, decision_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(sc_firm_info_id AS bigint)       AS sc_firm_info_id
    , CAST(form_type AS string)             AS form_type
    , CAST(content AS string)               AS content
    , CAST(amount AS decimal(38,0))         AS amount
    , CAST(additional_penalty AS string)    AS additional_penalty
    , CAST(additional_penalty_date AS date) AS additional_penalty_date
    , CAST(decision_content AS string)      AS decision_content
    , CAST(decision_date AS date)      AS decision_date
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS bigint)      AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(record_status AS int)            AS record_status
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(processing_unit AS string)       AS processing_unit
    , CAST(remedial_measure AS string)      AS remedial_measure
FROM {{ source('source_scms', 'raw_sc_firm_admin_sanction') }}