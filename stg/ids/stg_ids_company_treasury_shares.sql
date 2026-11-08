/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_treasury_shares
* Program name: Staging IDS.COMPANY_TREASURY_SHARES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(company_profile_id AS int)             AS company_profile_id
    , CAST(transaction_type_cd AS string)         AS transaction_type_cd
    , CAST(consulting_org AS string)              AS consulting_org
    , CAST(audit_org AS string)                   AS audit_org
    , CAST(other_org AS string)                   AS other_org
    , CAST(official_letter_no AS string)          AS official_letter_no
    , CAST(official_letter_date AS date)          AS official_letter_date
    , CAST(approval_status_cd AS string)          AS approval_status_cd
    , CAST(administrative_status_cd AS string)    AS administrative_status_cd
    , CAST(approver_user_id AS string)            AS approver_user_id
    , CAST(approver_user_name AS string)          AS approver_user_name
    , CAST(processor_user_id AS string)           AS processor_user_id
    , CAST(processor_user_name AS string)         AS processor_user_name
    , CAST(revision_reason AS string)             AS revision_reason
    , CAST(total_treasury_share_before AS bigint) AS total_treasury_share_before
    , CAST(latest_treasury_trans_qty AS bigint)   AS latest_treasury_trans_qty
    , CAST(latest_treasury_trans_date AS date)    AS latest_treasury_trans_date
    , CAST(latest_offering_end_date AS date)      AS latest_offering_end_date
    , CAST(total_registered_trans_qty AS bigint)  AS total_registered_trans_qty
    , CAST(par_value AS int)                      AS par_value
    , CAST(treasury_trans_purpose AS string)      AS treasury_trans_purpose
    , CAST(planned_trans_start_date AS date)      AS planned_trans_start_date
    , CAST(planned_trans_end_date AS date)        AS planned_trans_end_date
    , CAST(transaction_method AS string)          AS transaction_method
    , CAST(pricing_method AS string)              AS pricing_method
    , CAST(daily_trans_qty AS int)                AS daily_trans_qty
    , CAST(min_trans_price AS int)                AS min_trans_price
    , CAST(max_trans_price AS int)                AS max_trans_price
    , CAST(securities_agent_name_vi AS string)    AS securities_agent_name_vi
    , CAST(securities_agent_name_en AS string)    AS securities_agent_name_en
    , CAST(securities_agent_addr AS string)       AS securities_agent_addr
    , CAST(securities_agent_phone AS string)      AS securities_agent_phone
    , CAST(certificate_no AS string)              AS certificate_no
    , CAST(certificate_date AS date)              AS certificate_date
    , CAST(administrative_proc_cd AS string)      AS administrative_proc_cd
    , CAST(application_cd AS string)              AS application_cd
    , CAST(created_by AS string)                  AS created_by
    , CAST(created_date AS date)                  AS created_date
    , CAST(updated_by AS string)                  AS updated_by
    , CAST(updated_date AS date)                  AS updated_date
    , CAST(delete_flg AS int)                     AS delete_flg
    , CAST(submission_date AS date)               AS submission_date
    , CAST(approver_comment AS string)            AS approver_comment
    , CAST(legal_entity_id AS int)                AS legal_entity_id
    , CAST(funding_source AS string)              AS funding_source
FROM {{ source('source_ids', 'raw_company_treasury_shares') }}