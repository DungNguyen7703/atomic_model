/*
*--------------------------------------------------------------------*
* Program code: atm_pc_securities_offering_result
* Program name: Atomic Public Company Securities Offering Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH se_of_re AS (
    SELECT
        id
        , securities_offering_id
        , offering_phase_name
        , result_report_date
        , offering_end_date
        , offering_method_cd
        , security_type_cd
        , total_successful_qty
        , actual_offering_price
        , total_collected_am
        , successful_ratio
        , issuer_successful_qty
        , shareholder_successful_qty
        , issuer_collected_am
        , shareholder_collected_am
        , capital_source
        , employee_qty
        , domestic_successful_qty
        , domestic_collected_am
        , foreign_successful_qty
        , foreign_collected_am
        , post_issuance_total_qty
        , total_treasury_share
        , total_outstanding_share
        , domestic_offering_price
        , domestic_offering_qty
        , domestic_registered_qty
        , domestic_distributed_qty
        , domestic_reg_investor_qty
        , domestic_dist_investor_qty
        , domestic_undist_investor_qty
        , domestic_remaining_qty
        , domestic_distributed_pct
        , foreign_offering_price
        , foreign_offering_qty
        , foreign_registered_qty
        , foreign_distributed_qty
        , foreign_reg_investor_qty
        , foreign_dist_investor_qty
        , foreign_undist_investor_qty
        , foreign_remaining_qty
        , foreign_distributed_pct
        , certificate_no
        , certificate_date
        , official_letter_no
        , official_letter_date
        , approval_status_cd
        , approver_user_id
        , approver_user_name
        , processor_user_id
        , processor_user_name
        , revision_reason
        , total_expense
        , underwriting_fee
        , distribution_fee
        , audit_fee
        , other_expense
        , net_offering_proceeds
        , is_sync
        , delete_flg
        , approver_comment
        , extension_date
        , bond_ticker
        , result_single_obj
    FROM {{ ref('ods_ids_securities_offering_result') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING_RESULT', "se_of_re.id") }}                AS pc_securities_offering_result_id
    , CAST(se_of_re.id AS string)                                                                       AS pc_securities_offering_result_code
    , CAST('IDS_SECURITIES_OFFERING_RESULT' AS string)                                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING', "se_of_re.securities_offering_id") }} AS pc_securities_offering_id
    , CAST(se_of_re.securities_offering_id AS string)                                                   AS pc_securities_offering_code
    , CAST(se_of_re.offering_phase_name AS string)                                                      AS offering_phase_nm
    , CAST(se_of_re.result_report_date AS date)                                                         AS result_rpt_dt
    , CAST(se_of_re.offering_end_date AS date)                                                          AS offering_end_dt
    , CAST(se_of_re.offering_method_cd AS string)                                                       AS offering_method_code_snpst
    , CAST(se_of_re.security_type_cd AS string)                                                         AS security_tp_code
    , CAST(se_of_re.total_successful_qty AS int)                                                        AS total_successful_quantity
    , CAST(se_of_re.actual_offering_price AS decimal(23,2))                                             AS actual_offering_price
    , CAST(se_of_re.total_collected_am AS decimal(23,2))                                                AS total_collected_amt
    , CAST(se_of_re.successful_ratio AS decimal(5,2))                                                   AS successful_ratio_percentage
    , CAST(se_of_re.issuer_successful_qty AS int)                                                       AS issuer_successful_quantity
    , CAST(se_of_re.shareholder_successful_qty AS int)                                                  AS shareholder_successful_quantity
    , CAST(se_of_re.issuer_collected_am AS decimal(23,2))                                               AS issuer_collected_amt
    , CAST(se_of_re.shareholder_collected_am AS decimal(23,2))                                          AS shareholder_collected_amt
    , CAST(se_of_re.capital_source AS string)                                                           AS capital_src
    , CAST(se_of_re.employee_qty AS int)                                                                AS employee_quantity
    , CAST(se_of_re.domestic_successful_qty AS int)                                                     AS domestic_successful_quantity
    , CAST(se_of_re.domestic_collected_am AS decimal(23,2))                                             AS domestic_collected_amt
    , CAST(se_of_re.foreign_successful_qty AS int)                                                      AS foreign_successful_quantity
    , CAST(se_of_re.foreign_collected_am AS decimal(23,2))                                              AS foreign_collected_amt
    , CAST(se_of_re.post_issuance_total_qty AS int)                                                     AS post_issuance_total_quantity
    , CAST(se_of_re.total_treasury_share AS int)                                                        AS total_treasury_share
    , CAST(se_of_re.total_outstanding_share AS int)                                                     AS total_outstanding_share
    , CAST(se_of_re.domestic_offering_price AS decimal(23,2))                                           AS domestic_offering_price
    , CAST(se_of_re.domestic_offering_qty AS int)                                                       AS domestic_offering_quantity
    , CAST(se_of_re.domestic_registered_qty AS int)                                                     AS domestic_registered_quantity
    , CAST(se_of_re.domestic_distributed_qty AS int)                                                    AS domestic_distributed_quantity
    , CAST(se_of_re.domestic_reg_investor_qty AS int)                                                   AS domestic_registered_investor_quantity
    , CAST(se_of_re.domestic_dist_investor_qty AS int)                                                  AS domestic_distributed_investor_quantity
    , CAST(se_of_re.domestic_undist_investor_qty AS int)                                                AS domestic_undistributed_investor_quantity
    , CAST(se_of_re.domestic_remaining_qty AS int)                                                      AS domestic_remaining_quantity
    , CAST(se_of_re.domestic_distributed_pct AS decimal(5,2))                                           AS domestic_distributed_percentage
    , CAST(se_of_re.foreign_offering_price AS decimal(23,2))                                            AS foreign_offering_price
    , CAST(se_of_re.foreign_offering_qty AS int)                                                        AS foreign_offering_quantity
    , CAST(se_of_re.foreign_registered_qty AS int)                                                      AS foreign_registered_quantity
    , CAST(se_of_re.foreign_distributed_qty AS int)                                                     AS foreign_distributed_quantity
    , CAST(se_of_re.foreign_reg_investor_qty AS int)                                                    AS foreign_registered_investor_quantity
    , CAST(se_of_re.foreign_dist_investor_qty AS int)                                                   AS foreign_distributed_investor_quantity
    , CAST(se_of_re.foreign_undist_investor_qty AS int)                                                 AS foreign_undistributed_investor_quantity
    , CAST(se_of_re.foreign_remaining_qty AS int)                                                       AS foreign_remaining_quantity
    , CAST(se_of_re.foreign_distributed_pct AS decimal(5,2))                                            AS foreign_distributed_percentage
    , CAST(se_of_re.certificate_no AS string)                                                           AS certificate_nbr
    , CAST(se_of_re.certificate_date AS date)                                                           AS certificate_dt
    , CAST(se_of_re.official_letter_no AS string)                                                       AS official_letter_nbr
    , CAST(se_of_re.official_letter_date AS date)                                                       AS official_letter_dt
    , CAST(se_of_re.approval_status_cd AS string)                                                       AS approval_status_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "se_of_re.approver_user_id") }}                     AS approver_user_id
    , CAST(se_of_re.approver_user_id AS string)                                                         AS approver_user_code
    , CAST(se_of_re.approver_user_name AS string)                                                       AS approver_user_nm_snpst
    , {{ generate_surrogate_key_bigint('IAM_USERS', "se_of_re.processor_user_id") }}                    AS processor_user_id
    , CAST(se_of_re.processor_user_id AS string)                                                        AS processor_user_code
    , CAST(se_of_re.processor_user_name AS string)                                                      AS processor_user_nm_snpst
    , CAST(se_of_re.revision_reason AS string)                                                          AS revision_reason
    , CAST(se_of_re.total_expense AS decimal(23,2))                                                     AS total_expense
    , CAST(se_of_re.underwriting_fee AS decimal(23,2))                                                  AS underwriting_fee
    , CAST(se_of_re.distribution_fee AS decimal(23,2))                                                  AS distribution_fee
    , CAST(se_of_re.audit_fee AS decimal(23,2))                                                         AS audit_fee
    , CAST(se_of_re.other_expense AS decimal(23,2))                                                     AS other_expense
    , CAST(se_of_re.net_offering_proceeds AS decimal(23,2))                                             AS net_offering_proceeds
    , CAST(se_of_re.is_sync AS int)                                                                     AS synced_from_external_stm_indicator
    , CAST(se_of_re.delete_flg AS int)                                                                  AS deleted_indicator
    , CAST(se_of_re.approver_comment AS string)                                                         AS approver_comment
    , CAST(se_of_re.extension_date AS date)                                                             AS extension_dt
    , CAST(se_of_re.bond_ticker AS string)                                                              AS bond_ticker
    , CAST(se_of_re.result_single_obj AS string)                                                        AS result_single_object
FROM se_of_re