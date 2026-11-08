/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_practitioner_cchn
* Program name: Staging SCMS.SC_FIRM_PRACTITIONER_CCHN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: securities_license_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(practitioner_id AS bigint)           AS practitioner_id
    , CAST(securities_license_number AS string) AS securities_license_number
    , CAST(securities_license_date AS date) AS securities_license_date
    , CAST(business_division_id AS bigint)      AS business_division_id
    , CAST(responsible_service_id AS bigint)    AS responsible_service_id
    , CAST(sort_order AS bigint)                AS sort_order
    , CAST(created_at AS timestamp)             AS created_at
FROM {{ source('source_scms', 'raw_sc_firm_practitioner_cchn') }}