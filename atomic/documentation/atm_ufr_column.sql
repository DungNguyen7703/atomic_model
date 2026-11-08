/*
*--------------------------------------------------------------------*
* Program code: atm_ufr_column
* Program name: Atomic Unstructured Financial Report Column
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Created model for SCD2 and aligned with LLD lld_IDS_REP_COLUMN.yaml
*--------------------------------------------------------------------*
*/

WITH rep_col AS (
    SELECT
        id
        , col_cd
        , rep_form_id
        , col_name_vi
        , col_name_en
        , col_index
        , duplicate_col_flg
        , data_type_cd
        , col_formula
        , col_description
    FROM {{ ref('ods_ids_rep_column') }}
),

rep_form AS (
    SELECT
        id
    FROM {{ ref('ods_ids_rep_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REP_COLUMN', "rep_col.id") }}          AS ufr_column_id
    , CAST(rep_col.id AS string)                                                  AS ufr_column_code
    , CAST('IDS_REP_COLUMN' AS string)                                            AS src_stm_code
    , CAST(rep_col.col_cd AS string)                                              AS column_code
    , {{ generate_surrogate_key_bigint('IDS_REP_FORMS', "rep_col.rep_form_id") }} AS ufr_id
    , CAST(rep_form.id AS string)                                                 AS ufr_code
    , CAST(rep_col.col_name_vi AS string)                                         AS column_nm
    , CAST(rep_col.col_name_en AS string)                                         AS column_english_nm
    , CAST(rep_col.col_index AS int)                                              AS column_index
    , CAST(rep_col.duplicate_col_flg AS int)                                      AS duplicate_column_ind
    , CAST(rep_col.data_type_cd AS string)                                        AS column_data_tp_code
    , CAST(rep_col.col_formula AS string)                                         AS column_formula
    , CAST(rep_col.col_description AS string)                                     AS column_description
FROM rep_col
    LEFT JOIN rep_form ON rep_col.rep_form_id = rep_form.id
