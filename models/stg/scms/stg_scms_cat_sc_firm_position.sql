/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_sc_firm_position
* Program name: Staging SCMS.CAT_SC_FIRM_POSITION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))         AS id
    , CAST(code AS string)              AS code
    , CAST(item_name AS string)         AS item_name
    , CAST(description AS string)       AS description
    , CAST(record_status AS int)        AS record_status
    , CAST(applicable_entity AS string) AS applicable_entity
    , CAST(ecatalog_id AS string)       AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_sc_firm_position') }}