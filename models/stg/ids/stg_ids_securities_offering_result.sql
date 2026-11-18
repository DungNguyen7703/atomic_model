/*
*--------------------------------------------------------------------*
* Program code: stg_ids_securities_offering_result
* Program name: Staging IDS.SECURITIES_OFFERING_RESULT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                AS id
    , CAST(securities_offering_id AS bigint)          AS securities_offering_id
    , CAST(offering_phase_name AS string)             AS offering_phase_name
    , CAST(result_report_date AS date)                AS result_report_date
    , CAST(offering_end_date AS date)                 AS offering_end_date
    , CAST(offering_method_cd AS string)              AS offering_method_cd
    , CAST(security_type_cd AS string)                AS security_type_cd
    , CAST(total_successful_qty AS bigint)            AS total_successful_qty
    , CAST(actual_offering_price AS decimal(19,0))    AS actual_offering_price
    , CAST(total_collected_am AS decimal(19,0))       AS total_collected_am
    , CAST(successful_ratio AS decimal(5,2))          AS successful_ratio
    , CAST(issuer_successful_qty AS bigint)           AS issuer_successful_qty
    , CAST(shareholder_successful_qty AS bigint)      AS shareholder_successful_qty
    , CAST(issuer_collected_am AS decimal(19,0))      AS issuer_collected_am
    , CAST(shareholder_collected_am AS decimal(19,0)) AS shareholder_collected_am
    , CAST(capital_source AS string)                  AS capital_source
    , CAST(employee_qty AS int)                       AS employee_qty
    , CAST(domestic_successful_qty AS bigint)         AS domestic_successful_qty
    , CAST(domestic_collected_am AS decimal(19,0))    AS domestic_collected_am
    , CAST(foreign_successful_qty AS bigint)          AS foreign_successful_qty
    , CAST(foreign_collected_am AS decimal(19,0))     AS foreign_collected_am
    , CAST(post_issuance_total_qty AS bigint)         AS post_issuance_total_qty
    , CAST(total_treasury_share AS bigint)            AS total_treasury_share
    , CAST(total_outstanding_share AS bigint)         AS total_outstanding_share
    , CAST(domestic_offering_price AS decimal(19,0))  AS domestic_offering_price
    , CAST(domestic_offering_qty AS bigint)           AS domestic_offering_qty
    , CAST(domestic_registered_qty AS bigint)         AS domestic_registered_qty
    , CAST(domestic_distributed_qty AS bigint)        AS domestic_distributed_qty
    , CAST(domestic_reg_investor_qty AS int)          AS domestic_reg_investor_qty
    , CAST(domestic_dist_investor_qty AS int)         AS domestic_dist_investor_qty
    , CAST(domestic_undist_investor_qty AS int)       AS domestic_undist_investor_qty
    , CAST(domestic_remaining_qty AS bigint)          AS domestic_remaining_qty
    , CAST(domestic_distributed_pct AS decimal(5,2))  AS domestic_distributed_pct
    , CAST(foreign_offering_price AS decimal(19,0))   AS foreign_offering_price
    , CAST(foreign_offering_qty AS bigint)            AS foreign_offering_qty
    , CAST(foreign_registered_qty AS bigint)          AS foreign_registered_qty
    , CAST(foreign_distributed_qty AS bigint)         AS foreign_distributed_qty
    , CAST(foreign_reg_investor_qty AS int)           AS foreign_reg_investor_qty
    , CAST(foreign_dist_investor_qty AS int)          AS foreign_dist_investor_qty
    , CAST(foreign_undist_investor_qty AS int)        AS foreign_undist_investor_qty
    , CAST(foreign_remaining_qty AS bigint)           AS foreign_remaining_qty
    , CAST(foreign_distributed_pct AS decimal(5,2))   AS foreign_distributed_pct
    , CAST(certificate_no AS string)                  AS certificate_no
    , CAST(certificate_date AS date)                  AS certificate_date
    , CAST(official_letter_no AS string)              AS official_letter_no
    , CAST(official_letter_date AS date)              AS official_letter_date
    , CAST(approval_status_cd AS string)              AS approval_status_cd
    , CAST(approver_user_id AS string)                AS approver_user_id
    , CAST(approver_user_name AS string)              AS approver_user_name
    , CAST(processor_user_id AS string)               AS processor_user_id
    , CAST(processor_user_name AS string)             AS processor_user_name
    , CAST(revision_reason AS string)                 AS revision_reason
    , CAST(total_expense AS decimal(19,0))            AS total_expense
    , CAST(underwriting_fee AS decimal(19,0))         AS underwriting_fee
    , CAST(distribution_fee AS decimal(19,0))         AS distribution_fee
    , CAST(audit_fee AS decimal(19,0))                AS audit_fee
    , CAST(other_expense AS decimal(19,0))            AS other_expense
    , CAST(net_offering_proceeds AS decimal(24,0))    AS net_offering_proceeds
    , CAST(is_sync AS int)                            AS is_sync
    , CAST(delete_flg AS int)                         AS delete_flg
    , CAST(created_by AS string)                      AS created_by
    , CAST(created_date AS date)                      AS created_date
    , CAST(updated_by AS string)                      AS updated_by
    , CAST(updated_date AS date)                      AS updated_date
    , CAST(extension_date AS date)                    AS extension_date
    , CAST(bond_ticker AS string)                     AS bond_ticker
    , CAST(result_single_obj AS string)               AS result_single_obj
    , CAST(approver_comment AS string)                AS approver_comment
FROM {{ source('source_ids', 'raw_securities_offering_result') }}