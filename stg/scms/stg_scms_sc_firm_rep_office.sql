/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_rep_office
* Program name: Staging SCMS.SC_FIRM_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (11 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (7 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: decision_date_alt, valid_dossier_date, decision_date, official_operation_date, document_date, validity_start_date, validity_end_date; int sang bigint: event_type_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(sc_firm_info_id AS bigint)       AS sc_firm_info_id
    , CAST(sc_firm_branch_id AS bigint)     AS sc_firm_branch_id
    , CAST(full_name AS string)             AS full_name
    , CAST(address AS string)               AS address
    , CAST(province_id AS bigint)           AS province_id
    , CAST(district_name AS string)         AS district_name
    , CAST(ward_name AS string)             AS ward_name
    , CAST(phone AS string)                 AS phone
    , CAST(fax AS string)                   AS fax
    , CAST(decision_number_alt AS string)   AS decision_number_alt
    , CAST(decision_date_alt AS date)  AS decision_date_alt
    , CAST(valid_dossier_date AS date) AS valid_dossier_date
    , CAST(representative_name AS string)   AS representative_name
    , CAST(rep_office_status AS bigint)     AS rep_office_status
    , CAST(note AS string)                  AS note
    , CAST(created_by AS bigint)            AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS bigint)      AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(record_status AS int)            AS record_status
    , CAST(provisional AS int)              AS provisional
    , CAST(sc_firm_rep_office_id AS bigint) AS sc_firm_rep_office_id
    , CAST(district_id AS bigint)           AS district_id
    , CAST(ward_id AS bigint)               AS ward_id
    , CAST(representative_id AS bigint)     AS representative_id
    , CAST(decision_date AS date)      AS decision_date
    , CAST(decision_number AS string)       AS decision_number
    , CAST(office_name AS string)           AS office_name
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(official_operation_date AS date) AS official_operation_date
    , CAST(scope_of_operation AS string)    AS scope_of_operation
    , CAST(event_type_id AS bigint)            AS event_type_id
    , CAST(document_declaration AS int)     AS document_declaration
    , CAST(document_number AS string)       AS document_number
    , CAST(document_date AS date)      AS document_date
    , CAST(validity_start_date AS date) AS validity_start_date
    , CAST(validity_end_date AS date)  AS validity_end_date
    , CAST(document_file_path AS string)    AS document_file_path
    , CAST(form_data_json AS string)        AS form_data_json
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_rep_office') }}