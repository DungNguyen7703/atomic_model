/*
*--------------------------------------------------------------------*
* Program code: atm_unstructured_financial_report
* Program name: Atomic Unstructured Financial Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Created model for SCD2 and aligned with LLD lld_IDS_REP_FORMS.yaml
*--------------------------------------------------------------------*
*/

WITH rep_form AS (
    SELECT
        id
        , report_cd
        , report_name_vi
        , report_name_en
        , rp_report_type_cd
        , report_link
    FROM {{ ref('ods_ids_rep_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REP_FORMS', "rep_form.id") }} AS ufr_id
    , CAST(rep_form.id AS string)                                       AS ufr_code
    , CAST('IDS_REP_FORMS' AS string)                                   AS src_stm_code
    , CAST(rep_form.report_cd AS string)                                AS rpt_code
    , CAST(rep_form.report_name_vi AS string)                           AS ufr_nm
    , CAST(rep_form.report_name_en AS string)                           AS ufr_english_nm
    , CAST(rep_form.rp_report_type_cd AS string)                        AS ufr_tp_code
    , CAST(rep_form.report_link AS string)                              AS ufr_link
FROM rep_form
