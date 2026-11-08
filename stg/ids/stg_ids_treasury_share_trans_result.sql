/*
*--------------------------------------------------------------------*
* Program code: stg_ids_treasury_share_trans_result
* Program name: Staging IDS.TREASURY_SHARE_TRANS_RESULT
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
    , CAST(company_treasury_share_id AS int)      AS company_treasury_share_id
    , CAST(registered_trans_qty AS bigint)        AS registered_trans_qty
    , CAST(executed_trans_qty AS bigint)          AS executed_trans_qty
    , CAST(total_treasury_share_before AS bigint) AS total_treasury_share_before
    , CAST(total_treasury_share_after AS bigint)  AS total_treasury_share_after
    , CAST(treasury_trans_purpose AS string)      AS treasury_trans_purpose
    , CAST(average_trans_price AS int)            AS average_trans_price
    , CAST(trans_start_date AS date)              AS trans_start_date
    , CAST(trans_end_date AS date)                AS trans_end_date
    , CAST(transaction_method AS string)          AS transaction_method
    , CAST(securities_agent_name_vi AS string)    AS securities_agent_name_vi
    , CAST(securities_agent_name_en AS string)    AS securities_agent_name_en
    , CAST(unexecuted_qty_reason AS string)       AS unexecuted_qty_reason
    , CAST(certificate_no AS string)              AS certificate_no
    , CAST(certificate_date AS date)              AS certificate_date
    , CAST(official_letter_no AS string)          AS official_letter_no
    , CAST(official_letter_date AS date)          AS official_letter_date
    , CAST(approval_status_cd AS string)          AS approval_status_cd
    , CAST(approver_user_id AS string)            AS approver_user_id
    , CAST(approver_user_name AS string)          AS approver_user_name
    , CAST(processor_user_id AS string)           AS processor_user_id
    , CAST(processor_user_name AS string)         AS processor_user_name
    , CAST(revision_reason AS string)             AS revision_reason
    , CAST(created_by AS string)                  AS created_by
    , CAST(created_date AS date)                  AS created_date
    , CAST(updated_by AS string)                  AS updated_by
    , CAST(updated_date AS date)                  AS updated_date
    , CAST(delete_flg AS int)                     AS delete_flg
    , CAST(approver_comment AS string)            AS approver_comment
    , CAST(result_report_date AS date)            AS result_report_date
    , CAST(extension_date AS date)                AS extension_date
    , CAST(funding_source AS string)              AS funding_source
FROM {{ source('source_ids', 'raw_treasury_share_trans_result') }}