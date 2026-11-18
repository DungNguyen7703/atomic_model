/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_branch_personnel
* Program name: Staging SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (7 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: work_start_date, appointment_date, securities_license_date, id_issued_date, dismissal_date, resignation_date, date_of_birth.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(business_division AS string)         AS business_division
    , CAST(national_id AS string)               AS national_id
    , CAST(position_json AS string)             AS position_json
    , CAST(securities_license AS int)           AS securities_license
    , CAST(sc_firm_foreign_branch_id AS bigint) AS sc_firm_foreign_branch_id
    , CAST(disclosure_representative AS int)    AS disclosure_representative
    , CAST(address AS string)                   AS address
    , CAST(permanent_address AS string)         AS permanent_address
    , CAST(phone AS string)                     AS phone
    , CAST(email AS string)                     AS email
    , CAST(disclosure_email AS string)          AS disclosure_email
    , CAST(attachment_path AS string)           AS attachment_path
    , CAST(note AS string)                      AS note
    , CAST(gender AS string)                    AS gender
    , CAST(full_name AS string)                 AS full_name
    , CAST(work_start_date AS date)        AS work_start_date
    , CAST(appointment_date AS date)       AS appointment_date
    , CAST(securities_license_date AS date) AS securities_license_date
    , CAST(id_issued_date AS date)         AS id_issued_date
    , CAST(dismissal_date AS date)         AS dismissal_date
    , CAST(resignation_date AS date)       AS resignation_date
    , CAST(date_of_birth AS date)          AS date_of_birth
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(branch_head_user_id AS int)          AS branch_head_user_id
    , CAST(issue_place AS string)               AS issue_place
    , CAST(department AS string)                AS department
    , CAST(nationality AS string)               AS nationality
    , CAST(securities_license_number AS string) AS securities_license_number
    , CAST(record_status AS bigint)             AS record_status
    , CAST(work_status AS bigint)               AS work_status
    , CAST(verification_status AS string)       AS verification_status
    , CAST(created_by AS decimal(19,0))         AS created_by
    , CAST(last_modified_by AS decimal(19,0))   AS last_modified_by
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_foreign_branch_personnel') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1