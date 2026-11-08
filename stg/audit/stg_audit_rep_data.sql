/*
*--------------------------------------------------------------------*
* Program code: stg_audit_rep_data
* Program name: Staging AUDIT.REP_DATA
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))         AS id
    , CAST(company_profile_id AS int)   AS company_profile_id
    , CAST(legal_entity_id AS int)      AS legal_entity_id
    , CAST(company_data_id AS int)      AS company_data_id
    , CAST(rep_form_id AS int)          AS rep_form_id
    , CAST(data_value AS decimal(38,2)) AS data_value
    , CAST(text_value AS string)        AS text_value
    , CAST(rep_row_id AS int)           AS rep_row_id
    , CAST(rep_col_id AS int)           AS rep_col_id
    , CAST(rep_row_index AS int)        AS rep_row_index
    , CAST(rep_col_index AS int)        AS rep_col_index
    , CAST(col_data_type AS string)     AS col_data_type
    , CAST(row_data_type AS string)     AS row_data_type
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
FROM {{ source('source_audit', 'raw_rep_data') }}