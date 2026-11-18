/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_complaint_petition
* Program name: Staging SCMS.SC_FIRM_COMPLAINT_PETITION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: received_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(sc_firm_info_id AS bigint)     AS sc_firm_info_id
    , CAST(processing_unit AS string)     AS processing_unit
    , CAST(petition_type AS string)       AS petition_type
    , CAST(case_code AS string)           AS case_code
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(sync_date AS timestamp)        AS sync_date
    , CAST(received_date AS date)    AS received_date
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS bigint)    AS last_modified_by
    , CAST(created_by AS bigint)          AS created_by
    , CAST(data_source AS string)         AS data_source
    , CAST(summary AS string)             AS summary
    , CAST(petition_number AS string)     AS petition_number
    , CAST(sc_firm_name AS string)        AS sc_firm_name
    , CAST(sender_info_json AS string)    AS sender_info_json
    , CAST(processing_status AS string)   AS processing_status
FROM {{ source('source_scms', 'raw_sc_firm_complaint_petition') }}