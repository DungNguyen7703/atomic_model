/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_indicator_data_source
* Program name: Staging SCMS.FORM_INDICATOR_DATA_SOURCE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))          AS id
    , CAST(code AS string)               AS code
    , CAST(display_name AS string)       AS display_name
    , CAST(db_table_name AS string)      AS db_table_name
    , CAST(detail_url_pattern AS string) AS detail_url_pattern
    , CAST(sort_order AS bigint)         AS sort_order
    , CAST(record_status AS int)         AS record_status
FROM {{ source('source_scms', 'raw_form_indicator_data_source') }}