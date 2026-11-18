/*
*--------------------------------------------------------------------*
* Program code: atm_sc_organization_unit
* Program name: Atomic Securities Company Organization Unit SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_br AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , branch_code
        , full_name
        , name_en
        , branch_status
        , provisional
        , valid_dossier_date
        , operation_date
        , official_operation_date
        , director_name
        , representative_name
        , representative_title
        , director_personnel_id
        , issuing_authority
        , business_lines
        , attachment_path
        , note
        , record_status
    FROM {{ ref('ods_scms_sc_firm_branch') }}
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_br.id") }}                           AS sc_ou_id
    , CAST(sc_fi_br.id AS string)                                                                       AS sc_ou_code
    , CAST('SCMS_SC_FIRM_BRANCH' AS string)                                                             AS src_stm_code
    , CAST('BRANCH' AS string)                                                                          AS ou_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                         AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                     AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_br.sc_firm_branch_id") }}          AS parent_ou_id
    , CAST(sc_fi_br.sc_firm_branch_id AS string)                                                        AS parent_ou_code
    , CAST(sc_fi_br.branch_code AS string)                                                              AS ou_code
    , CAST(sc_fi_br.full_name AS string)                                                                AS ou_nm
    , CAST(sc_fi_br.name_en AS string)                                                                  AS ou_english_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }} AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                   AS cl_sc_firm_status_code
    , CAST(sc_fi_br.provisional AS int)                                                                 AS provisional_ind
    , CAST(sc_fi_br.valid_dossier_date AS date)                                                         AS valid_dossier_dt
    , CAST(sc_fi_br.operation_date AS date)                                                             AS operation_dt
    , CAST(sc_fi_br.official_operation_date AS date)                                                    AS official_operation_dt
    , CAST(sc_fi_br.director_name AS string)                                                            AS director_nm
    , CAST(sc_fi_br.representative_name AS string)                                                      AS representative_nm
    , CAST(sc_fi_br.representative_title AS string)                                                     AS representative_title
    , CAST(sc_fi_br.director_personnel_id AS string)                                                    AS personnel_director_id
    , CAST(sc_fi_br.issuing_authority AS string)                                                        AS administrative_authority_nm
    , CAST(sc_fi_br.business_lines AS string)                                                           AS business_lines
    , CAST(sc_fi_br.attachment_path AS string)                                                          AS attachment_path
    , CAST(sc_fi_br.note AS string)                                                                     AS note
    , CAST(NULL AS string)                                                                              AS ou_legacy_nm
    , CAST(NULL AS string)                                                                              AS cl_sc_event_tp_id
    , CAST(NULL AS string)                                                                              AS cl_sc_event_tp_code
    , CAST(NULL AS string)                                                                              AS document_nbr
    , CAST(NULL AS date)                                                                                AS document_dt
    , CAST(NULL AS string)                                                                              AS document_file_path
    , CAST(NULL AS int)                                                                                 AS document_declaration_ind
    , CAST(NULL AS date)                                                                                AS validity_start_dt
    , CAST(NULL AS date)                                                                                AS validity_end_dt
    , CAST(NULL AS string)                                                                              AS scope_of_operation
    , CAST(NULL AS string)                                                                              AS representative_id
FROM sc_fi_br
    LEFT JOIN sc_fi_in ON sc_fi_br.SC_FIRM_INFO_ID = sc_fi_in.SC_FIRM_INFO_ID
    LEFT JOIN ca_sc_fi_st ON sc_fi_br.BRANCH_STATUS = ca_sc_fi_st.ID