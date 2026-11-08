/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_personnel
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (4 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: id_issued_date, appointment_date, dismissal_date, date_of_birth; int sang bigint: created_by, last_modified_by.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(sc_firm_foreign_rep_office_id AS bigint) AS sc_firm_foreign_rep_office_id
    , CAST(full_name AS string)                  AS full_name
    , CAST(national_id AS string)                AS national_id
    , CAST(id_issued_date AS date)             AS id_issued_date
    , CAST(issue_place AS string)                AS issue_place
    , CAST(permanent_address AS string)          AS permanent_address
    , CAST(nationality AS string)                AS nationality
    , CAST(email AS string)                      AS email
    , CAST(phone AS string)                      AS phone
    , CAST(position_json AS string)              AS position_json
    , CAST(rep_office_representative AS int)     AS rep_office_representative
    , CAST(appointment_date AS date)           AS appointment_date
    , CAST(dismissal_date AS date)             AS dismissal_date
    , CAST(record_status AS int)                 AS record_status
    , CAST(attachment_path AS string)            AS attachment_path
    , CAST(note AS string)                       AS note
    , CAST(created_by AS bigint)                    AS created_by
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(last_modified_by AS bigint)              AS last_modified_by
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(date_of_birth AS date)              AS date_of_birth
    , CAST(deleted AS int)                       AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_personnel') }}