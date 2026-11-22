/*
*--------------------------------------------------------------------*
* Program code: atm_sc_profile_change
* Program name: Atomic Securities Company Profile Change
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_PROFILE_CHANGE.yaml (Fact Append/incremental_rebase append); sc_id/sc_code lay tu SC_FIRM_INFO.CODE (join sc_firm_info_id = sc_fi_in.id); sc_ou_id theo CASE ENTITY_TYPE (CN/PGD/TRU_SO_CHINH/VPDD) nhu LLD
* 2026-11-13		claude		[Sua] Dong bo LLD/DM moi (Data Modeler 2026-11-13): 26 -> 17 cot; bo 18 cot NULL padding; doi/them cot subject_display_nm, cl_sc_event_tp_id/code, event_tp_nm, before/after_change_information, license_decision_document_nbr, effective_dt, execution_tms; loai HAS_APPROVAL_DOC, PERFORMED_BY, PERFORMER_NAME, AFTER_DATA_JSON, ADMIN_PROCEDURE_PROFILE_ID
* 2026-11-13		claude		[Sua] Theo BRD (Append): loc ODS theo execution_time trong ngay etl_date (TO_TIMESTAMP + INTERVAL 1 DAY, dong bo STG/ODS); LLD khong co data_dt nen partition_by execution_tms (yml)
* 2026-11-14		claude		[Fix] cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, EVENT_TYPE_CODE) theo LLD/DM moi; cl_sc_event_tp_code = CAT_EVENT_TYPE.EVENT_TYPE_CODE lay qua join ods_scms_cat_event_type (event_type_id = id)
*--------------------------------------------------------------------*
*/

WITH ca_ev_ty AS (
    SELECT
        id AS ca_ev_ty_id
        , event_type_code AS ca_ev_ty_code
    FROM {{ ref('ods_scms_cat_event_type') }}
),

sc_fi_pr_ch AS (
    SELECT
        id
        , sc_firm_info_id
        , entity_type
        , entity_id
        , subject_display_name
        , execution_time
        , event_type_id
        , event_type_name
        , before_info
        , after_info
        , license_decision_doc_number
        , effective_date
    FROM {{ ref('ods_scms_sc_firm_profile_change') }}
    WHERE execution_time >= TO_TIMESTAMP('{{ var("etl_date") }}') AND execution_time < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_PROFILE_CHANGE', "sc_fi_pr_ch.id") }} AS sc_profile_change_id
    , CAST(sc_fi_pr_ch.id AS string)                                                     AS sc_profile_change_code
    , CAST('SCMS_SC_FIRM_PROFILE_CHANGE' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}          AS sc_id
    , CAST(sc_fi_in.code AS string)                                                      AS sc_code
    , CAST(sc_fi_pr_ch.entity_type AS string)                                            AS ou_tp_code
    , CASE
        WHEN sc_fi_pr_ch.entity_type = 'CN' THEN {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_pr_ch.entity_id") }}
        WHEN sc_fi_pr_ch.entity_type = 'PGD' THEN {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_pr_ch.entity_id") }}
        WHEN sc_fi_pr_ch.entity_type = 'TRU_SO_CHINH' THEN {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_pr_ch.entity_id") }}
        WHEN sc_fi_pr_ch.entity_type = 'VPDD' THEN {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_pr_ch.entity_id") }}
        ELSE NULL
    END                                                                                  AS sc_ou_id
    , CAST(sc_fi_pr_ch.entity_id AS string)                                              AS sc_ou_code
    , CAST(sc_fi_pr_ch.subject_display_name AS string)                                   AS subject_display_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }} AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                           AS cl_sc_event_tp_code
    , CAST(sc_fi_pr_ch.event_type_name AS string)                                        AS event_tp_nm
    , CAST(sc_fi_pr_ch.before_info AS string)                                            AS before_change_information
    , CAST(sc_fi_pr_ch.after_info AS string)                                             AS after_change_information
    , CAST(sc_fi_pr_ch.license_decision_doc_number AS string)                            AS license_decision_document_nbr
    , CAST(sc_fi_pr_ch.effective_date AS date)                                           AS effective_dt
    , CAST(sc_fi_pr_ch.execution_time AS timestamp)                                      AS execution_tms
FROM sc_fi_pr_ch
    LEFT JOIN sc_fi_in ON sc_fi_pr_ch.sc_firm_info_id = sc_fi_in.id
    LEFT JOIN ca_ev_ty ON sc_fi_pr_ch.event_type_id = ca_ev_ty.id
