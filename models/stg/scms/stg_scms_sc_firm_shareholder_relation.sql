/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder_relation
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER_RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (6 cot); kieu int sang decimal(38,0) (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: issue_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_info_id AS bigint)        AS sc_firm_info_id
    , CAST(sc_firm_shareholder_id AS bigint) AS sc_firm_shareholder_id
    , CAST(full_name AS string)              AS full_name
    , CAST(relationship AS string)           AS relationship
    , CAST(id_number AS string)              AS id_number
    , CAST(issue_date AS date)          AS issue_date
    , CAST(issue_place AS string)            AS issue_place
    , CAST(workplace AS string)              AS workplace
    , CAST(job_title AS string)              AS job_title
    , CAST(sc_firm_with_shares_id AS bigint) AS sc_firm_with_shares_id
    , CAST(shares_count AS decimal(38,0))    AS shares_count
    , CAST(ownership_ratio AS decimal(10,4)) AS ownership_ratio
    , CAST(attachment_path AS string)        AS attachment_path
    , CAST(note AS string)                   AS note
    , CAST(created_by AS bigint)             AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS bigint)       AS last_modified_by
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder_relation') }}