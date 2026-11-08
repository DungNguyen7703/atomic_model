/*
*--------------------------------------------------------------------*
* Program code: ods_ids_forms
* Program name: ODS IDS.FORMS
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
    , form_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , form_name_vi
    , form_name_en
    , form_type_cd
    , news_type_cd
    , sub_news_type_cd
    , officer_approval_flg
    , post_checked_flg
    , activated_flg
    , ca_signed_flg
    , leader_approval_flg
    , published_flg
    , title_formula
    , parent_id
    , report_type
    , control_unit_cd
    , operating_unit_cd
    , delete_flg
    , system_cd
    , news_type_group_cd
    , title_formula_en
FROM {{ ref('stg_ids_forms') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND activated_flg = 1
    AND delete_flg = 0