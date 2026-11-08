/*
*--------------------------------------------------------------------*
* Program code: stg_ids_rcol
* Program name: Staging IDS.RCOL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(col_name_vi AS string)    AS col_name_vi
    , CAST(col_name_en AS string)    AS col_name_en
    , CAST(col_index AS int)         AS col_index
    , CAST(report_catalog_id AS bigint) AS report_catalog_id
    , CAST(col_type_cd AS string)    AS col_type_cd
    , CAST(col_formula AS string)    AS col_formula
    , CAST(report_year AS string)    AS report_year
    , CAST(rc_type_cd AS string)     AS rc_type_cd
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(created_by AS string)     AS created_by
    , CAST(created_date AS date)     AS created_date
    , CAST(updated_by AS string)     AS updated_by
    , CAST(updated_date AS date)     AS updated_date
    , CAST(description AS string)    AS description
    , CAST(col_desc AS string)       AS col_desc
    , CAST(formula_desc AS string)   AS formula_desc
    , CAST(col_cd AS string)         AS col_cd
FROM {{ source('source_ids', 'raw_rcol') }}