/*
*--------------------------------------------------------------------*
* Program code: atm_pc_treasury_share_transaction_result
* Program name: Atomic Pc Treasury Share Transaction Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_treasury_share_id
        , registered_trans_qty
        , executed_trans_qty
        , total_treasury_share_before
        , total_treasury_share_after
        , treasury_trans_purpose
        , average_trans_price
        , trans_start_date
        , trans_end_date
        , transaction_method
        , securities_agent_name_vi
        , securities_agent_name_en
        , unexecuted_qty_reason
        , certificate_no
        , certificate_date
        , official_letter_no
        , official_letter_date
        , approval_status_cd
        , revision_reason
        , approver_comment
        , funding_source
    FROM {{ ref('ods_ids_treasury_share_trans_result') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_TREASURY_SHARE_TRANS_RESULT', "id") }}                      AS pc_treasury_share_transaction_result_id
    , CAST(id AS string)                                                                              AS pc_treasury_share_transaction_result_code
    , CAST('IDS_TREASURY_SHARE_TRANS_RESULT' AS string)                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_TREASURY_SHARES', "company_treasury_share_id") }} AS pc_treasury_share_transaction_id
    , CAST(company_treasury_share_id AS string)                                                       AS pc_treasury_share_transaction_code
    , CAST(registered_trans_qty AS bigint)                                                            AS registered_transaction_quantity
    , CAST(executed_trans_qty AS bigint)                                                              AS executed_transaction_quantity
    , CAST(total_treasury_share_before AS bigint)                                                     AS total_treasury_share_before_quantity
    , CAST(total_treasury_share_after AS bigint)                                                      AS total_treasury_share_after_quantity
    , CAST(treasury_trans_purpose AS string)                                                          AS treasury_transaction_purpose
    , CAST(funding_source AS string)                                                                  AS funding_src_description
    , CAST(average_trans_price AS decimal(23,2))                                                      AS average_transaction_price_amt
    , CAST(trans_start_date AS date)                                                                  AS transaction_start_dt
    , CAST(trans_end_date AS date)                                                                    AS transaction_end_dt
    , CAST(transaction_method AS string)                                                              AS transaction_method
    , CAST(securities_agent_name_vi AS string)                                                        AS securities_agent_nm
    , CAST(securities_agent_name_en AS string)                                                        AS securities_agent_english_nm
    , CAST(unexecuted_qty_reason AS string)                                                           AS unexecuted_quantity_reason
    , CAST(certificate_no AS string)                                                                  AS certificate_nbr
    , CAST(certificate_date AS date)                                                                  AS certificate_dt
    , CAST(official_letter_no AS string)                                                              AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                              AS official_letter_dt
    , CAST(approval_status_cd AS string)                                                              AS approval_status_code
    , CAST(revision_reason AS string)                                                                 AS revision_reason
    , CAST(approver_comment AS string)                                                                AS approver_comment
FROM src
