/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_ownership_relation
* Program name: Staging SCMS.SC_FIRM_OWNERSHIP_RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (6 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: end_date, ownership_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(sc_firm_info_id AS bigint)        AS sc_firm_info_id
    , CAST(registered_address AS string)     AS registered_address
    , CAST(note AS string)                   AS note
    , CAST(enterprise_type_id AS bigint)     AS enterprise_type_id
    , CAST(relation_type AS string)          AS relation_type
    , CAST(enterprise_code AS string)        AS enterprise_code
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(end_date AS date)            AS end_date
    , CAST(ownership_date AS date)      AS ownership_date
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS bigint)       AS last_modified_by
    , CAST(created_by AS bigint)             AS created_by
    , CAST(country_id AS bigint)             AS country_id
    , CAST(company_name AS string)           AS company_name
    , CAST(ownership_ratio AS decimal(10,2)) AS ownership_ratio
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_ownership_relation') }}