/*
*--------------------------------------------------------------------*
* Program code: stg_audit_rep_column
* Program name: Staging AUDIT.REP_COLUMN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(col_name_vi AS string)     AS col_name_vi
    , CAST(col_name_en AS string)     AS col_name_en
    , CAST(rep_form_id AS bigint)     AS rep_form_id
    , CAST(col_index AS int)          AS col_index
    , CAST(duplicate_col_flg AS int)  AS duplicate_col_flg
    , CAST(data_type_cd AS string)    AS data_type_cd
    , CAST(col_formula AS string)     AS col_formula
    , CAST(col_cd AS string)          AS col_cd
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS timestamp) AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS timestamp) AS updated_date
    , CAST(col_description AS string) AS col_description
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(system_cd AS string)       AS system_cd
FROM {{ source('source_audit', 'raw_rep_column') }}