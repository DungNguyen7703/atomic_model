/*
*--------------------------------------------------------------------*
* Program code: stg_audit_rep_row
* Program name: Staging AUDIT.REP_ROW
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
    , CAST(row_name_vi AS string)     AS row_name_vi
    , CAST(row_name_en AS string)     AS row_name_en
    , CAST(row_cd AS string)          AS row_cd
    , CAST(rep_form_id AS bigint)     AS rep_form_id
    , CAST(row_index AS int)          AS row_index
    , CAST(duplicate_row_flg AS int)  AS duplicate_row_flg
    , CAST(data_type_cd AS string)    AS data_type_cd
    , CAST(allow_col_sum_flg AS int)  AS allow_col_sum_flg
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS timestamp) AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS timestamp) AS updated_date
    , CAST(row_description AS string) AS row_description
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(system_cd AS string)       AS system_cd
FROM {{ source('source_audit', 'raw_rep_row') }}