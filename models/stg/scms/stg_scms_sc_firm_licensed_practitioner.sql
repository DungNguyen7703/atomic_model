/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_licensed_practitioner
* Program name: Staging SCMS.SC_FIRM_LICENSED_PRACTITIONER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (15 cot); kieu string sang int (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (13 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: securities_license_date, date_of_birth, id_card_issued_date, start_date, end_date, work_start_date, appointment_date, issue_date, work_end_date, dismissal_date, date_of_birth_alt; int sang bigint: report_id, nhn_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                             AS id
    , CAST(sc_firm_info_id AS bigint)                AS sc_firm_info_id
    , CAST(sc_firm_personnel_id AS bigint)           AS sc_firm_personnel_id
    , CAST(securities_license_number AS string)      AS securities_license_number
    , CAST(securities_license_date AS date)     AS securities_license_date
    , CAST(synced AS int)                            AS synced
    , CAST(sync_at AS timestamp)                     AS sync_at
    , CAST(note AS string)                           AS note
    , CAST(created_by AS bigint)                     AS created_by
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(record_status AS int)                     AS record_status
    , CAST(sc_firm_service_id AS bigint)             AS sc_firm_service_id
    , CAST(full_name_legacy AS string)               AS full_name_legacy
    , CAST(date_of_birth AS date)               AS date_of_birth
    , CAST(national_id_legacy AS string)             AS national_id_legacy
    , CAST(id_card_issued_date AS date)         AS id_card_issued_date
    , CAST(issue_place_legacy AS string)             AS issue_place_legacy
    , CAST(nationality_legacy AS string)             AS nationality_legacy
    , CAST(permanent_address_legacy AS string)       AS permanent_address_legacy
    , CAST(permanent_residence AS string)            AS permanent_residence
    , CAST(birth_place AS string)                    AS birth_place
    , CAST(phone_legacy AS string)                   AS phone_legacy
    , CAST(mobile AS string)                         AS mobile
    , CAST(email AS string)                          AS email
    , CAST(company_name AS string)                   AS company_name
    , CAST(english_name AS string)                   AS english_name
    , CAST(short_name AS string)                     AS short_name
    , CAST(license_number AS string)                 AS license_number
    , CAST(department_legacy AS string)              AS department_legacy
    , CAST(position_legacy AS string)                AS position_legacy
    , CAST(start_date AS date)                  AS start_date
    , CAST(end_date AS date)                    AS end_date
    , CAST(record_status_alt AS string)              AS record_status_alt
    , CAST(errtext AS string)                        AS errtext
    , CAST(report_id AS bigint)                         AS report_id
    , CAST(datecreated AS timestamp)                 AS datecreated
    , CAST(createdby AS string)                      AS createdby
    , CAST(datemodify AS timestamp)                  AS datemodify
    , CAST(modifyby AS string)                       AS modifyby
    , CAST(batchid AS string)                        AS batchid
    , CAST(content AS string)                        AS content
    , CAST(nhn_id AS bigint)                            AS nhn_id
    , CAST(deleted AS int)                           AS deleted
    , CAST(gender_legacy AS string)                  AS gender_legacy
    , CAST(sc_firm_branch_id AS bigint)              AS sc_firm_branch_id
    , CAST(sc_firm_transaction_office_id AS bigint)  AS sc_firm_transaction_office_id
    , CAST(sc_firm_rep_office_id AS bigint)          AS sc_firm_rep_office_id
    , CAST(business_line_id AS string)               AS business_line_id
    , CAST(labor_contract_termination_report AS int) AS labor_contract_termination_report
    , CAST(business_division_id AS bigint)           AS business_division_id
    , CAST(national_id AS string)                    AS national_id
    , CAST(position_ids AS string)                   AS position_ids
    , CAST(permanent_address AS string)              AS permanent_address
    , CAST(responsible_service_id AS bigint)         AS responsible_service_id
    , CAST(phone AS string)                          AS phone
    , CAST(entity_type AS string)                    AS entity_type
    , CAST(attachment_path AS string)                AS attachment_path
    , CAST(gender AS bigint)                         AS gender
    , CAST(full_name AS string)                      AS full_name
    , CAST(insider AS bigint)                        AS insider
    , CAST(work_start_date AS date)             AS work_start_date
    , CAST(appointment_date AS date)            AS appointment_date
    , CAST(issue_date AS date)                  AS issue_date
    , CAST(last_modified_at AS timestamp)            AS last_modified_at
    , CAST(work_end_date AS date)               AS work_end_date
    , CAST(dismissal_date AS date)              AS dismissal_date
    , CAST(date_of_birth_alt AS date)           AS date_of_birth_alt
    , CAST(last_modified_by AS bigint)               AS last_modified_by
    , CAST(issue_place AS string)                    AS issue_place
    , CAST(department AS string)                     AS department
    , CAST(nationality_id AS bigint)                 AS nationality_id
    , CAST(securities_license_number_alt AS string)  AS securities_license_number_alt
    , CAST(latest_verification_at AS timestamp)      AS latest_verification_at
    , CAST(work_status AS string)                    AS work_status
    , CAST(verification_status AS bigint)            AS verification_status
    , CAST(mismatch_reason AS string)                AS mismatch_reason
FROM {{ source('source_scms', 'raw_sc_firm_licensed_practitioner') }}