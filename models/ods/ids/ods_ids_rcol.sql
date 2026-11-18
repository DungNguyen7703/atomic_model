/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rcol
* Program name: ODS IDS.RCOL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , col_name_vi
    , col_name_en
    , col_index
    , report_catalog_id
    , col_type_cd
    , col_formula
    , report_year
    , rc_type_cd
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , description
    , col_desc
    , formula_desc
    , col_cd
FROM {{ ref('stg_ids_rcol') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')