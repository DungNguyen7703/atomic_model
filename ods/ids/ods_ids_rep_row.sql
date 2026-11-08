/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rep_row
* Program name: ODS IDS.REP_ROW
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
    , row_name_vi
    , row_name_en
    , row_cd
    , rep_form_id
    , row_index
    , duplicate_row_flg
    , data_type_cd
    , allow_col_sum_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , row_description
    , delete_flg
    , system_cd
FROM {{ ref('stg_ids_rep_row') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')