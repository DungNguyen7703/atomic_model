/*
*--------------------------------------------------------------------*
* Program code: atm_sc_organization_unit
* Program name: Atomic Securities Company Organization Unit SCMS.SC_FIRM_TRANSACTION_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_tr_of AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , full_name
        , transaction_office_status
        , provisional
        , event_type_id
        , document_number
        , document_date
        , document_file_path
        , document_declaration
        , valid_dossier_date
        , official_operation_date
        , validity_start_date
        , validity_end_date
        , representative_name
        , representative_id
        , attachment_path
        , note
        , record_status
    FROM {{ ref('ods_scms_sc_firm_transaction_office') }}
    where record_status = 1
),

sc_fi_in AS (
    SELECT
        sc_firm_info_id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_sc_fi_st AS (
    SELECT
        id
        , sc_firm_status_code
    FROM {{ ref('ods_scms_cat_sc_firm_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_tr_of.id") }}            AS sc_ou_id
    , CAST(sc_fi_tr_of.id AS string)                                                                    AS sc_ou_code
    , CAST('SCMS_SC_FIRM_TRANSACTION_OFFICE' AS string)                                                 AS src_stm_code
    , CAST('TRANSACTION_OFFICE' AS string)                                                              AS ou_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                         AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                     AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_tr_of.sc_firm_branch_id") }}       AS parent_ou_id
    , CAST(sc_fi_tr_of.sc_firm_branch_id AS string)                                                     AS parent_ou_code
    , CAST(NULL AS string)                                                                              AS ou_code
    , CAST(sc_fi_tr_of.full_name AS string)                                                             AS ou_nm
    , CAST(NULL AS string)                                                                              AS ou_english_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }} AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                   AS cl_sc_firm_status_code
    , CAST(sc_fi_tr_of.provisional AS int)                                                              AS provisional_ind
    , CAST(sc_fi_tr_of.valid_dossier_date AS date)                                                      AS valid_dossier_dt
    , CAST(NULL AS date)                                                                                AS operation_dt
    , CAST(sc_fi_tr_of.official_operation_date AS date)                                                 AS official_operation_dt
    , CAST(NULL AS string)                                                                              AS director_nm
    , CAST(sc_fi_tr_of.representative_name AS string)                                                   AS representative_nm
    , CAST(NULL AS string)                                                                              AS representative_title
    , CAST(NULL AS string)                                                                              AS personnel_director_id
    , CAST(NULL AS string)                                                                              AS administrative_authority_nm
    , CAST(NULL AS string)                                                                              AS business_lines
    , CAST(sc_fi_tr_of.attachment_path AS string)                                                       AS attachment_path
    , CAST(sc_fi_tr_of.note AS string)                                                                  AS note
    , CAST(NULL AS string)                                                                              AS ou_legacy_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "sc_fi_tr_of.event_type_id") }}           AS cl_sc_event_tp_id
    , CAST(sc_fi_tr_of.event_type_id AS string)                                                         AS cl_sc_event_tp_code
    , CAST(sc_fi_tr_of.document_number AS string)                                                       AS document_nbr
    , CAST(sc_fi_tr_of.document_date AS date)                                                           AS document_dt
    , CAST(sc_fi_tr_of.document_file_path AS string)                                                    AS document_file_path
    , CAST(sc_fi_tr_of.document_declaration AS int)                                                     AS document_declaration_ind
    , CAST(sc_fi_tr_of.validity_start_date AS date)                                                     AS validity_start_dt
    , CAST(sc_fi_tr_of.validity_end_date AS date)                                                       AS validity_end_dt
    , CAST(NULL AS string)                                                                              AS scope_of_operation
    , CAST(sc_fi_tr_of.representative_id AS string)                                                     AS representative_id
FROM sc_fi_tr_of
    LEFT JOIN sc_fi_in ON sc_fi_tr_of.SC_FIRM_INFO_ID = sc_fi_in.SC_FIRM_INFO_ID
    LEFT JOIN ca_sc_fi_st ON sc_fi_tr_of.TRANSACTION_OFFICE_STATUS = ca_sc_fi_st.ID