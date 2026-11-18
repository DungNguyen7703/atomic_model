/*
*--------------------------------------------------------------------*
* Program code: atm_ufr_row
* Program name: Atomic Unstructured Financial Report Row
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Created model for SCD2 and aligned with LLD lld_IDS_REP_ROW.yaml
*--------------------------------------------------------------------*
*/

WITH rep_row AS (
    SELECT
        id
        , row_cd
        , rep_form_id
        , row_name_vi
        , row_name_en
        , row_index
        , duplicate_row_flg
        , data_type_cd
        , allow_col_sum_flg
        , row_description
    FROM {{ ref('ods_ids_rep_row') }}
),

rep_form AS (
    SELECT
        id
    FROM {{ ref('ods_ids_rep_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REP_ROW', "rep_row.id") }}             AS ufr_row_id
    , CAST(rep_row.id AS string)                                                  AS ufr_row_code
    , CAST('IDS_REP_ROW' AS string)                                               AS src_stm_code
    , CAST(rep_row.row_cd AS string)                                              AS row_code
    , {{ generate_surrogate_key_bigint('IDS_REP_FORMS', "rep_row.rep_form_id") }} AS ufr_id
    , CAST(rep_form.id AS string)                                                 AS ufr_code
    , CAST(rep_row.row_name_vi AS string)                                         AS row_nm
    , CAST(rep_row.row_name_en AS string)                                         AS row_english_nm
    , CAST(rep_row.row_index AS int)                                              AS row_index
    , CAST(rep_row.duplicate_row_flg AS int)                                      AS duplicate_row_ind
    , CAST(rep_row.data_type_cd AS string)                                        AS row_data_tp_code
    , CASE WHEN CAST(rep_row.allow_col_sum_flg AS int) = 1 THEN 1 ELSE 0 END      AS allow_column_sum_ind
    , CAST(rep_row.row_description AS string)                                     AS row_description
FROM rep_row
    LEFT JOIN rep_form ON rep_row.rep_form_id = rep_form.id
