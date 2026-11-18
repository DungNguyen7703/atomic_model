/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_branch
* Program name: Staging SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (11 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (7 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: decision_date, valid_dossier_date, license_date, operation_date, director_date_of_birth, director_id_issue_date, director_license_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                              AS id
    , CAST(sc_firm_info_id AS bigint)                 AS sc_firm_info_id
    , CAST(full_name AS string)                       AS full_name
    , CAST(address AS string)                         AS address
    , CAST(province_id AS bigint)                     AS province_id
    , CAST(district_name AS string)                   AS district_name
    , CAST(ward_name AS string)                       AS ward_name
    , CAST(phone AS string)                           AS phone
    , CAST(fax AS string)                             AS fax
    , CAST(decision_number AS string)                 AS decision_number
    , CAST(decision_date AS date)                AS decision_date
    , CAST(valid_dossier_date AS date)           AS valid_dossier_date
    , CAST(director_name AS string)                   AS director_name
    , CAST(business_lines AS string)                  AS business_lines
    , CAST(branch_status AS bigint)                   AS branch_status
    , CAST(note AS string)                            AS note
    , CAST(created_by AS bigint)                      AS created_by
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(last_modified_by AS bigint)                AS last_modified_by
    , CAST(last_modified_at AS timestamp)             AS last_modified_at
    , CAST(record_status AS int)                      AS record_status
    , CAST(provisional AS int)                        AS provisional
    , CAST(sc_firm_branch_id AS bigint)               AS sc_firm_branch_id
    , CAST(district_id AS bigint)                     AS district_id
    , CAST(ward_id AS bigint)                         AS ward_id
    , CAST(director_personnel_id AS bigint)           AS director_personnel_id
    , CAST(representative_title AS string)            AS representative_title
    , CAST(issuing_authority AS string)               AS issuing_authority
    , CAST(email AS string)                           AS email
    , CAST(branch_code AS string)                     AS branch_code
    , CAST(license_date AS date)                 AS license_date
    , CAST(operation_date AS date)               AS operation_date
    , CAST(last_modified_at_legacy AS timestamp)      AS last_modified_at_legacy
    , CAST(representative_name AS string)             AS representative_name
    , CAST(last_modified_by_legacy AS bigint)         AS last_modified_by_legacy
    , CAST(phone_number AS string)                    AS phone_number
    , CAST(license_number AS string)                  AS license_number
    , CAST(branch_name AS string)                     AS branch_name
    , CAST(name_en AS string)                         AS name_en
    , CAST(website AS string)                         AS website
    , CAST(attachment_path AS string)                 AS attachment_path
    , CAST(official_operation_date AS timestamp)      AS official_operation_date
    , CAST(branch_allocated_capital AS decimal(22,4)) AS branch_allocated_capital
    , CAST(matter_id AS decimal(19,0))                AS matter_id
    , CAST(form_data_json AS string)                  AS form_data_json
    , CAST(deleted AS int)                            AS deleted
    , CAST(director_nationality_id AS decimal(19,0))  AS director_nationality_id
    , CAST(director_date_of_birth AS date)       AS director_date_of_birth
    , CAST(director_id_number AS string)              AS director_id_number
    , CAST(director_id_issue_date AS date)       AS director_id_issue_date
    , CAST(director_id_issue_place AS string)         AS director_id_issue_place
    , CAST(director_license_number AS string)         AS director_license_number
    , CAST(director_license_date AS date)        AS director_license_date
FROM {{ source('source_scms', 'raw_sc_firm_branch') }}