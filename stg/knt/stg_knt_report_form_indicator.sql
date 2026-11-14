/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_form_indicator
* Program name: Staging KNT.REPORT_FORM_INDICATOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang decimal(38,10) (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))                AS id
    , CAST(report_form_id AS decimal(38,10))    AS report_form_id
    , CAST(form_indicator_id AS decimal(38,10)) AS form_indicator_id
    , CAST(sort_order AS decimal(38,10))        AS sort_order
    , CAST(sheet_name AS string)     AS sheet_name
FROM {{ source('source_knt', 'raw_report_form_indicator') }}