/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_user_report
* Program name: Staging SCMS.LNK_USER_REPORT
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
    CAST(user_id AS bigint)      AS user_id
    , CAST(form_report_id AS bigint) AS form_report_id
    , CAST(id AS bigint)           AS id
    , CAST(sc_firm_info_id AS bigint) AS sc_firm_info_id
FROM {{ source('source_scms', 'raw_lnk_user_report') }}