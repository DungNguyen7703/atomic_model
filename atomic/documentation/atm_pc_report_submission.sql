/*
*--------------------------------------------------------------------*
* Program code: atm_pc_report_submission
* Program name: Atomic Public Company Report Submission
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD2 and align with LLD lld_IDS_COMPANY_DATA.yaml
*--------------------------------------------------------------------*
*/

WITH co_da AS (
    SELECT
        id
        , company_profile_id
        , doc_title
        , form_id
        , news_status_cd
        , report_year
        , report_quarter
        , report_month
        , parent_id
        , doc_no
        , doc_date
        , doc_summary
        , doc_sign_date
        , submission_date
        , approval_date
        , rejection_date
        , submission_deadline_date
        , overdue_days
        , ref_id
        , digital_signature_flg
        , news_type_cd
        , reject_reason
        , review_date
        , send_back_date
        , link_id
        , language_cd
    FROM {{ ref('ods_ids_company_data') }}
),

form AS (
    SELECT
        id
        , form_cd
    FROM {{ ref('ods_ids_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "co_da.id") }}                                     AS pc_rpt_submission_id
    , CAST(co_da.id AS string)                                                                              AS pc_rpt_submission_code
    , CAST('IDS_COMPANY_DATA' AS string)                                                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_da.company_profile_id") }}               AS pc_id
    , CAST(co_da.company_profile_id AS string)                                                              AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "form.form_cd") }}                                      AS fr_id
    , CAST(form.form_cd AS string)                                                                          AS fr_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "co_da.parent_id") }}                            AS parent_submission_id
    , CAST(co_da.parent_id AS string)                                                                       AS parent_submission_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "co_da.ref_id") }}                               AS original_submission_id
    , CAST(co_da.ref_id AS string)                                                                          AS original_submission_code
    , CAST(co_da.doc_title AS string)                                                                       AS document_title
    , CAST(co_da.news_status_cd AS string)                                                                  AS approval_status_code
    , CAST(co_da.report_year AS int)                                                                        AS rpt_year
    , CAST(co_da.report_quarter AS int)                                                                     AS rpt_quarter
    , CAST(co_da.report_month AS int)                                                                       AS rpt_month
    , CAST(co_da.doc_no AS string)                                                                          AS document_nbr
    , CAST(co_da.doc_date AS date)                                                                          AS document_dt
    , CAST(co_da.doc_summary AS string)                                                                     AS document_summary
    , CAST(co_da.doc_sign_date AS date)                                                                     AS document_sign_dt
    , CAST(co_da.submission_date AS date)                                                                   AS submission_dt
    , CAST(co_da.approval_date AS date)                                                                     AS approval_dt
    , CAST(co_da.rejection_date AS date)                                                                    AS rejection_dt
    , CAST(co_da.submission_deadline_date AS date)                                                          AS submission_deadline_dt
    , CAST(co_da.overdue_days AS int)                                                                       AS overdue_days
    , CAST(co_da.digital_signature_flg AS int)                                                              AS has_digital_signature_ind
    , CAST(co_da.news_type_cd AS string)                                                                    AS news_tp_code
    , CAST(co_da.reject_reason AS string)                                                                   AS reject_reason
    , CAST(co_da.review_date AS timestamp)                                                                  AS review_tms
    , CAST(co_da.send_back_date AS timestamp)                                                               AS send_back_tms
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "co_da.link_id") }}                              AS linked_submission_id
    , CAST(co_da.link_id AS string)                                                                         AS linked_submission_code
    , CAST(co_da.language_cd AS string)                                                                     AS language_code
    , CAST(NULL AS string)                                                                                  AS alert_audit_content
    , CAST(NULL AS timestamp)                                                                               AS close_tms
    , CAST(NULL AS string)                                                                                  AS pc_securities_offering_id
    , CAST(NULL AS string)                                                                                  AS pc_securities_offering_code
    , CAST(NULL AS string)                                                                                  AS offering_disclosure_tp_code
    , CAST(NULL AS string)                                                                                  AS legal_entity_id
    , CAST(NULL AS string)                                                                                  AS legal_entity_code
    , CAST(NULL AS string)                                                                                  AS pc_tender_offer_id
    , CAST(NULL AS string)                                                                                  AS pc_tender_offer_code
    , CAST(NULL AS string)                                                                                  AS pc_treasury_share_transaction_id
    , CAST(NULL AS string)                                                                                  AS pc_treasury_share_transaction_code
    , CAST(NULL AS string)                                                                                  AS approver_user_id
    , CAST(NULL AS string)                                                                                  AS approver_user_code
    , CAST(NULL AS string)                                                                                  AS approver_user_nm
    , CAST(NULL AS int)                                                                                     AS flattened_ind
FROM co_da
    LEFT JOIN form ON co_da.form_id = form.id
