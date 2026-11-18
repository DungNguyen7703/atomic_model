/*
*--------------------------------------------------------------------*
* Program code: atm_financial_report
* Program name: Atomic Financial Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD2 and align with LLD lld_IDS_FORMS.yaml
*--------------------------------------------------------------------*
*/

WITH form AS (
    SELECT
        form_cd
        , parent_id
        , form_name_vi
        , form_name_en
        , form_type_cd
        , news_type_cd
        , sub_news_type_cd
        , news_type_group_cd
        , officer_approval_flg
        , post_checked_flg
        , ca_signed_flg
        , leader_approval_flg
        , title_formula
        , title_formula_en
        , report_type
        , control_unit_cd
        , operating_unit_cd
    FROM {{ ref('ods_ids_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_FORMS', "form.form_cd") }}     AS fr_id
    , CAST(form.form_cd AS string)                                       AS fr_code
    , CAST('IDS_FORMS' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "form.parent_id") }} AS parent_fr_id
    , CAST(form.parent_id AS string)                                     AS parent_fr_code
    , CAST(form.form_name_vi AS string)                                  AS fr_nm
    , CAST(form.form_name_en AS string)                                  AS fr_english_nm
    , CAST(form.form_type_cd AS string)                                  AS fr_tp_code
    , CAST(form.news_type_cd AS string)                                  AS news_tp_code
    , CAST(form.sub_news_type_cd AS string)                              AS news_sub_tp_code
    , CAST(form.news_type_group_cd AS string)                            AS form_group_tp_code
    , CAST(form.officer_approval_flg AS int)                             AS officer_auto_approval_ind
    , CAST(form.post_checked_flg AS int)                                 AS post_checked_ind
    , CAST(form.ca_signed_flg AS int)                                    AS ca_signed_ind
    , CAST(form.leader_approval_flg AS int)                              AS leader_auto_approval_ind
    , CAST(form.title_formula AS string)                                 AS title_formula
    , CAST(form.title_formula_en AS string)                              AS title_formula_english
    , CAST(form.report_type AS string)                                   AS rpt_tp_code
    , CAST(form.control_unit_cd AS string)                               AS control_unit_code
    , CAST(form.operating_unit_cd AS string)                             AS operating_unit_code
FROM form
