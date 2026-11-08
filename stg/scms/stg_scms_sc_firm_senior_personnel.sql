/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_senior_personnel
* Program name: Staging SCMS.SC_FIRM_SENIOR_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (11 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (11 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: issue_date, date_of_birth, work_start_date, resignation_date, start_date, appointment_date, securities_license_date, end_date, dismissal_date, ownership_ratio_date, disclosure_effective_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                  AS id
    , CAST(sc_firm_info_id AS bigint)                     AS sc_firm_info_id
    , CAST(sc_firm_branch_id AS bigint)                   AS sc_firm_branch_id
    , CAST(sc_firm_transaction_office_id AS bigint)       AS sc_firm_transaction_office_id
    , CAST(sc_firm_rep_office_id AS bigint)               AS sc_firm_rep_office_id
    , CAST(department AS string)                          AS department
    , CAST(position_id AS string)                         AS position_id
    , CAST(full_name AS string)                           AS full_name
    , CAST(personnel_status AS int)                       AS personnel_status
    , CAST(id_number AS string)                           AS id_number
    , CAST(issue_date AS date)                       AS issue_date
    , CAST(issue_place AS string)                         AS issue_place
    , CAST(date_of_birth AS date)                    AS date_of_birth
    , CAST(gender AS int)                                 AS gender
    , CAST(nationality_id_legacy AS bigint)               AS nationality_id_legacy
    , CAST(place_of_birth AS string)                      AS place_of_birth
    , CAST(address AS string)                             AS address
    , CAST(phone AS string)                               AS phone
    , CAST(fax AS string)                                 AS fax
    , CAST(email AS string)                               AS email
    , CAST(disclosure_email AS string)                    AS disclosure_email
    , CAST(shareholder_type AS string)                    AS shareholder_type
    , CAST(work_start_date AS date)                  AS work_start_date
    , CAST(resignation_date AS date)                 AS resignation_date
    , CAST(note AS string)                                AS note
    , CAST(report_content AS string)                      AS report_content
    , CAST(created_by AS bigint)                          AS created_by
    , CAST(created_at AS timestamp)                       AS created_at
    , CAST(last_modified_by AS bigint)                    AS last_modified_by
    , CAST(last_modified_at AS timestamp)                 AS last_modified_at
    , CAST(record_status AS int)                          AS record_status
    , CAST(provisional AS int)                            AS provisional
    , CAST(practice_certificate AS int)                   AS practice_certificate
    , CAST(disclosure_person_id AS int)                   AS disclosure_person_id
    , CAST(attachment_path AS string)                     AS attachment_path
    , CAST(legal_representative AS int)                   AS legal_representative
    , CAST(deleted AS int)                                AS deleted
    , CAST(practitioner_legacy_id AS int)                 AS practitioner_legacy_id
    , CAST(disclosure_person_id_alt AS int)               AS disclosure_person_id_alt
    , CAST(business_division_id AS bigint)                AS business_division_id
    , CAST(national_id AS string)                         AS national_id
    , CAST(position AS string)                            AS position
    , CAST(position_ids AS string)                        AS position_ids
    , CAST(securities_license AS int)                     AS securities_license
    , CAST(statutory_representative AS int)               AS statutory_representative
    , CAST(responsible_service_id AS bigint)              AS responsible_service_id
    , CAST(entity_type AS string)                         AS entity_type
    , CAST(start_date AS date)                       AS start_date
    , CAST(appointment_date AS date)                 AS appointment_date
    , CAST(securities_license_date AS date)          AS securities_license_date
    , CAST(end_date AS date)                         AS end_date
    , CAST(dismissal_date AS date)                   AS dismissal_date
    , CAST(nationality_id AS bigint)                      AS nationality_id
    , CAST(securities_license_number AS string)           AS securities_license_number
    , CAST(contributed_capital AS decimal(22,4))          AS contributed_capital
    , CAST(ownership_ratio_date AS date)             AS ownership_ratio_date
    , CAST(disclosure_effective_date AS date)        AS disclosure_effective_date
    , CAST(disclosure_authorization_doc_number AS string) AS disclosure_authorization_doc_number
    , CAST(ownership_ratio AS decimal(10,4))              AS ownership_ratio
    , CAST(sync_source AS string)                         AS sync_source
FROM {{ source('source_scms', 'raw_sc_firm_senior_personnel') }}