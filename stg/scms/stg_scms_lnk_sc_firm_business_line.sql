/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_business_line
* Program name: Staging SCMS.LNK_SC_FIRM_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sc_firm_id AS bigint)    AS sc_firm_id
    , CAST(business_line_id AS bigint) AS business_line_id
    , CAST(record_status AS int)    AS record_status
    , CAST(id AS bigint)            AS id
FROM {{ source('source_scms', 'raw_lnk_sc_firm_business_line') }}