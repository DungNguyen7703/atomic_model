/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rep_column
* Program name: ODS IDS.REP_COLUMN
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
    , rep_form_id
    , col_index
    , duplicate_col_flg
    , data_type_cd
    , col_formula
    , col_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , col_description
    , delete_flg
    , system_cd
FROM {{ ref('stg_ids_rep_column') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')