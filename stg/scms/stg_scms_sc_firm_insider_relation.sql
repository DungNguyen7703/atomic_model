/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_insider_relation
* Program name: Staging SCMS.SC_FIRM_INSIDER_RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang decimal(19,0) (6 cot); kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (4 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: relation_start_date, issue_date, ownership_ratio_date, date_of_birth.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                 AS id
    , CAST(sc_firm_info_id AS decimal(19,0))    AS sc_firm_info_id
    , CAST(senior_personnel_id AS decimal(19,0)) AS senior_personnel_id
    , CAST(full_name AS string)                 AS full_name
    , CAST(national_id AS string)               AS national_id
    , CAST(relationship AS string)              AS relationship
    , CAST(ownership_ratio AS decimal(12,4))    AS ownership_ratio
    , CAST(record_status AS int)                AS record_status
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(created_by AS decimal(19,0))         AS created_by
    , CAST(founding_shareholder AS bigint)      AS founding_shareholder
    , CAST(permanent_address AS string)         AS permanent_address
    , CAST(phone AS string)                     AS phone
    , CAST(email AS string)                     AS email
    , CAST(note AS string)                      AS note
    , CAST(gender AS bigint)                    AS gender
    , CAST(relation_start_date AS date)     AS relation_start_date
    , CAST(issue_date AS date)              AS issue_date
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(ownership_ratio_date AS date)    AS ownership_ratio_date
    , CAST(date_of_birth AS date)           AS date_of_birth
    , CAST(issue_place AS string)               AS issue_place
    , CAST(nationality_id AS bigint)            AS nationality_id
    , CAST(shares_count AS decimal(19,0))       AS shares_count
    , CAST(last_modified_by AS decimal(19,0))   AS last_modified_by
    , CAST(entity_type AS string)               AS entity_type
    , CAST(name_en AS string)                   AS name_en
    , CAST(short_name AS string)                AS short_name
    , CAST(legal_representative_name AS string) AS legal_representative_name
    , CAST(representative_position AS string)   AS representative_position
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_insider_relation') }}