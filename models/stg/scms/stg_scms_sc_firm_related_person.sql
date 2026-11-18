/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_related_person
* Program name: Staging SCMS.SC_FIRM_RELATED_PERSON
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang decimal(19,0) (3 cot); kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (6 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: appointment_date, issue_date, ownership_ratio_date, date_of_birth, relation_start_date, relation_end_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))              AS id
    , CAST(sc_firm_info_id AS decimal(19,0)) AS sc_firm_info_id
    , CAST(entity_type AS string)            AS entity_type
    , CAST(full_name AS string)              AS full_name
    , CAST(identification_number AS string)  AS identification_number
    , CAST(relationship AS string)           AS relationship
    , CAST(ownership_ratio AS decimal(12,4)) AS ownership_ratio
    , CAST(record_status AS int)             AS record_status
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(representative_title AS string)   AS representative_title
    , CAST(position_id AS string)            AS position_id
    , CAST(founding_shareholder AS bigint)   AS founding_shareholder
    , CAST(permanent_address AS string)      AS permanent_address
    , CAST(phone AS string)                  AS phone
    , CAST(workplace AS string)              AS workplace
    , CAST(email AS string)                  AS email
    , CAST(note AS string)                   AS note
    , CAST(gender AS bigint)                 AS gender
    , CAST(appointment_date AS date)    AS appointment_date
    , CAST(issue_date AS date)          AS issue_date
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(ownership_ratio_date AS date) AS ownership_ratio_date
    , CAST(date_of_birth AS date)       AS date_of_birth
    , CAST(legal_representative AS string)   AS legal_representative
    , CAST(created_by AS bigint)             AS created_by
    , CAST(issue_place AS string)            AS issue_place
    , CAST(country_id AS bigint)             AS country_id
    , CAST(shares_count AS decimal(19,0))    AS shares_count
    , CAST(org_name_en AS string)            AS org_name_en
    , CAST(org_short_name AS string)         AS org_short_name
    , CAST(transaction_time AS string)       AS transaction_time
    , CAST(resolution_number AS string)      AS resolution_number
    , CAST(transaction_content AS string)    AS transaction_content
    , CAST(relation_start_date AS date) AS relation_start_date
    , CAST(relation_end_date AS date)   AS relation_end_date
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_related_person') }}