/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_practitioner_business_line
* Program name: Staging SCMS.LNK_PRACTITIONER_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(licensed_practitioner_id AS bigint) AS licensed_practitioner_id
    , CAST(business_line_id AS bigint)      AS business_line_id
FROM {{ source('source_scms', 'raw_lnk_practitioner_business_line') }}