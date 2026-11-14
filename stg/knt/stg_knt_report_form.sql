/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_form
* Program name: Staging KNT.REPORT_FORM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang decimal(38,10) (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))          AS id
    , CAST(form_code AS string) AS form_code
    , CAST(form_name AS string) AS form_name
    , CAST(system_code AS decimal(38,10)) AS system_code
FROM {{ source('source_knt', 'raw_report_form') }}