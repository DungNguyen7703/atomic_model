/*
*--------------------------------------------------------------------*
* Program code: stg_ids_rep_column
* Program name: Staging IDS.REP_COLUMN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(col_name_vi AS string)     AS col_name_vi
    , CAST(col_name_en AS string)     AS col_name_en
    , CAST(rep_form_id AS int)        AS rep_form_id
    , CAST(col_index AS int)          AS col_index
    , CAST(duplicate_col_flg AS int)  AS duplicate_col_flg
    , CAST(data_type_cd AS string)    AS data_type_cd
    , CAST(col_formula AS string)     AS col_formula
    , CAST(col_cd AS string)          AS col_cd
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS date)      AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
    , CAST(col_description AS string) AS col_description
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(system_cd AS string)       AS system_cd
FROM {{ source('source_ids', 'raw_rep_column') }}