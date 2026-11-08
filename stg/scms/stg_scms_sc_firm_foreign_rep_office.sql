/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (5 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: license_date, amendment_effective_date, official_operation_date, parent_license_date, expiry_date; int sang bigint: sc_firm_info_id, rep_office_status_id, event_type_id, created_by, last_modified_by.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(amendment_declaration AS int)        AS amendment_declaration
    , CAST(address AS string)                   AS address
    , CAST(amendment_document_file AS string)   AS amendment_document_file
    , CAST(enterprise_code AS string)           AS enterprise_code
    , CAST(tax_code AS string)                  AS tax_code
    , CAST(license_date AS date)           AS license_date
    , CAST(amendment_effective_date AS date) AS amendment_effective_date
    , CAST(official_operation_date AS date) AS official_operation_date
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(country AS string)                   AS country
    , CAST(license_number AS string)            AS license_number
    , CAST(amendment_document_number AS string) AS amendment_document_number
    , CAST(parent_company_name AS string)       AS parent_company_name
    , CAST(rep_office_name AS string)           AS rep_office_name
    , CAST(record_status AS int)                AS record_status
    , CAST(sc_firm_info_id AS bigint)              AS sc_firm_info_id
    , CAST(parent_company_license AS string)    AS parent_company_license
    , CAST(parent_license_date AS date)    AS parent_license_date
    , CAST(parent_hq_address AS string)         AS parent_hq_address
    , CAST(phone AS string)                     AS phone
    , CAST(fax AS string)                       AS fax
    , CAST(email AS string)                     AS email
    , CAST(operation_term_years AS int)         AS operation_term_years
    , CAST(expiry_date AS date)            AS expiry_date
    , CAST(scope_json AS string)                AS scope_json
    , CAST(attachment_path AS string)           AS attachment_path
    , CAST(note AS string)                      AS note
    , CAST(rep_office_status_id AS bigint)         AS rep_office_status_id
    , CAST(event_type_id AS bigint)                AS event_type_id
    , CAST(reporting_enabled AS int)            AS reporting_enabled
    , CAST(admin_proc_data AS int)              AS admin_proc_data
    , CAST(created_by AS bigint)                   AS created_by
    , CAST(last_modified_by AS bigint)             AS last_modified_by
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(form_data_json AS string)            AS form_data_json
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office') }}