/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report
* Program name: Atomic Securities Company Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fo_re AS (
    SELECT
        id
        , report_code
        , report_name
        , legal_basis
        , report_group
        , requires_disclosure
        , requires_import
        , attachment_path
        , description
        , report_type
        , version
        , version_date
        , sender_entity
        , form_report_id
        , report_style
        , disclosure_news_type
        , next_form_id
        , excel_template_path
        , summary
        , input_report
        , note
        , signature_type
        , eform_enabled
        , structure_format
        , primary_source_type
        , identifier_field
        , display_location
        , show_grand_total_row
    FROM {{ ref('ods_scms_form_report') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_re.id") }}               AS sc_rpt_id
    , CAST(fo_re.id AS string)                                                        AS sc_rpt_code
    , CAST(fo_re.report_code AS string)                                               AS rpt_code
    , CAST('SCMS_FORM_REPORT' AS string)                                              AS src_stm_code
    , CAST(fo_re.report_name AS string)                                               AS sc_rpt_nm
    , CAST(fo_re.legal_basis AS string)                                               AS legal_basis
    , CAST(fo_re.report_group AS string)                                              AS rpt_group
    , CAST(fo_re.requires_disclosure AS int)                                          AS disclosure_required_ind
    , CAST(fo_re.requires_import AS int)                                              AS import_required_ind
    , CAST(fo_re.attachment_path AS string)                                           AS attachment_path
    , CAST(fo_re.description AS string)                                               AS description
    , CAST(fo_re.report_type AS string)                                               AS rpt_tp_code
    , CAST(fo_re.version AS int)                                                      AS version_nbr
    , CAST(fo_re.version_date AS date)                                                AS version_dt
    , CAST(fo_re.sender_entity AS string)                                             AS sender_entity_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_re.form_report_id") }} AS parent_sc_rpt_id
    , CAST(fo_re.form_report_id AS string)                                            AS parent_sc_rpt_code
    , CAST(fo_re.report_style AS string)                                              AS rpt_style_code
    , CAST(fo_re.disclosure_news_type AS string)                                      AS disclosure_news_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_re.next_form_id") }}   AS next_sc_rpt_id
    , CAST(fo_re.next_form_id AS string)                                              AS next_sc_rpt_code
    , CAST(fo_re.excel_template_path AS string)                                       AS excel_template_path
    , CAST(fo_re.summary AS int)                                                      AS summary_ind
    , CAST(fo_re.input_report AS int)                                                 AS input_rpt_ind
    , CAST(fo_re.note AS string)                                                      AS note
    , CAST(fo_re.signature_type AS string)                                            AS signature_tp_code
    , CAST(fo_re.eform_enabled AS int)                                                AS eform_enabled_ind
    , CAST(fo_re.structure_format AS string)                                          AS structure_format
    , CAST(fo_re.primary_source_type AS string)                                       AS primary_src_tp_code
    , CAST(fo_re.identifier_field AS string)                                          AS identifier_field
    , CAST(fo_re.display_location AS string)                                          AS display_location
    , CAST(fo_re.show_grand_total_row AS int)                                         AS show_grand_total_row_ind
FROM fo_re