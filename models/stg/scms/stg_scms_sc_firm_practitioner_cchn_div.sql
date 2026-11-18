/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_practitioner_cchn_div
* Program name: Staging SCMS.SC_FIRM_PRACTITIONER_CCHN_DIV
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(cchn_id AS bigint)           AS cchn_id
    , CAST(business_division_id AS bigint) AS business_division_id
    , CAST(sort_order AS bigint)        AS sort_order
FROM {{ source('source_scms', 'raw_sc_firm_practitioner_cchn_div') }}