/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_branch
* Program name: Staging SCMS.SC_FIRM_FOREIGN_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (6 cot); kieu int sang decimal(20,0) (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (5 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: business_reg_cert_date, license_date, parent_company_license_date, amendment_effective_date, official_operation_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                            AS id
    , CAST(amendment_declaration AS int)            AS amendment_declaration
    , CAST(sc_firm_info_id AS bigint)               AS sc_firm_info_id
    , CAST(address AS string)                       AS address
    , CAST(parent_company_address AS string)        AS parent_company_address
    , CAST(phone AS string)                         AS phone
    , CAST(event_type_id AS bigint)                 AS event_type_id
    , CAST(synced_from_admin_proc AS int)           AS synced_from_admin_proc
    , CAST(email AS string)                         AS email
    , CAST(fax AS string)                           AS fax
    , CAST(amendment_document_file AS string)       AS amendment_document_file
    , CAST(business_reg_cert AS string)             AS business_reg_cert
    , CAST(note AS string)                          AS note
    , CAST(financial_report_type AS string)         AS financial_report_type
    , CAST(enterprise_code AS string)               AS enterprise_code
    , CAST(tax_code AS string)                      AS tax_code
    , CAST(business_reg_cert_date AS date)     AS business_reg_cert_date
    , CAST(last_modified_at AS timestamp)           AS last_modified_at
    , CAST(license_date AS date)               AS license_date
    , CAST(parent_company_license_date AS date) AS parent_company_license_date
    , CAST(amendment_effective_date AS date)   AS amendment_effective_date
    , CAST(official_operation_date AS date)    AS official_operation_date
    , CAST(fiscal_year_end_date AS string)          AS fiscal_year_end_date
    , CAST(created_at AS timestamp)                 AS created_at
    , CAST(last_modified_by AS bigint)              AS last_modified_by
    , CAST(created_by AS bigint)                    AS created_by
    , CAST(country AS string)                       AS country
    , CAST(license_number AS string)                AS license_number
    , CAST(parent_company_license_number AS string) AS parent_company_license_number
    , CAST(amendment_document_number AS string)     AS amendment_document_number
    , CAST(branch_name AS string)                   AS branch_name
    , CAST(parent_company_name AS string)           AS parent_company_name
    , CAST(name_en AS string)                       AS name_en
    , CAST(short_name AS string)                    AS short_name
    , CAST(record_status AS bigint)                 AS record_status
    , CAST(allocated_capital AS decimal(20,0))      AS allocated_capital
    , CAST(attachment_path AS string)               AS attachment_path
    , CAST(form_data_json AS string)                AS form_data_json
    , CAST(deleted AS int)                          AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_foreign_branch') }}