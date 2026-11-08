/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_vn
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_VN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (4 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: business_license_date, office_license_date, decision_date, valid_dossier_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(parent_company_name AS string)     AS parent_company_name
    , CAST(address AS string)                 AS address
    , CAST(business_license_number AS string) AS business_license_number
    , CAST(business_license_date AS date) AS business_license_date
    , CAST(business_license_issuer AS string) AS business_license_issuer
    , CAST(rep_office_name AS string)         AS rep_office_name
    , CAST(office_address AS string)          AS office_address
    , CAST(office_business_license AS string) AS office_business_license
    , CAST(office_license_date AS date)  AS office_license_date
    , CAST(office_license_issuer AS string)   AS office_license_issuer
    , CAST(head_representative AS string)     AS head_representative
    , CAST(nationality_id AS bigint)          AS nationality_id
    , CAST(note AS string)                    AS note
    , CAST(created_by AS bigint)              AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by AS bigint)        AS last_modified_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(record_status AS int)              AS record_status
    , CAST(decision_date AS date)        AS decision_date
    , CAST(valid_dossier_date AS date)   AS valid_dossier_date
    , CAST(document_type AS string)           AS document_type
    , CAST(document_number AS string)         AS document_number
    , CAST(change_reason AS string)           AS change_reason
    , CAST(attachment_path AS string)         AS attachment_path
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_vn') }}