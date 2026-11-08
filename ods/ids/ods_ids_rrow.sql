/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rrow
* Program name: ODS IDS.RROW
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
    , row_type_cd
    , row_formula
    , row_index
    , report_catalog_id
    , report_year
    , rc_type_cd
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , description
    , row_desc
    , formula_desc
FROM {{ ref('stg_ids_rrow') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')