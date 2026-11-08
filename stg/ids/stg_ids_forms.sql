/*
*--------------------------------------------------------------------*
* Program code: stg_ids_forms
* Program name: Staging IDS.FORMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(form_cd AS string)            AS form_cd
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS timestamp)    AS updated_date
    , CAST(form_name_vi AS string)       AS form_name_vi
    , CAST(form_name_en AS string)       AS form_name_en
    , CAST(form_type_cd AS string)       AS form_type_cd
    , CAST(news_type_cd AS string)       AS news_type_cd
    , CAST(sub_news_type_cd AS string)   AS sub_news_type_cd
    , CAST(officer_approval_flg AS int)  AS officer_approval_flg
    , CAST(post_checked_flg AS int)      AS post_checked_flg
    , CAST(activated_flg AS int)         AS activated_flg
    , CAST(ca_signed_flg AS int)         AS ca_signed_flg
    , CAST(leader_approval_flg AS int)   AS leader_approval_flg
    , CAST(published_flg AS int)         AS published_flg
    , CAST(title_formula AS string)      AS title_formula
    , CAST(parent_id AS bigint)             AS parent_id
    , CAST(report_type AS int)           AS report_type
    , CAST(control_unit_cd AS string)    AS control_unit_cd
    , CAST(operating_unit_cd AS string)  AS operating_unit_cd
    , CAST(delete_flg AS int)            AS delete_flg
    , CAST(system_cd AS string)          AS system_cd
    , CAST(news_type_group_cd AS string) AS news_type_group_cd
    , CAST(title_formula_en AS string )  AS title_formula_en
FROM {{ source('source_ids', 'raw_forms') }}