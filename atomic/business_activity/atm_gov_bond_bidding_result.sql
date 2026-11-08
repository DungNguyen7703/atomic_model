/*
*--------------------------------------------------------------------*
* Program code: atm_gov_bond_bidding_result
* Program name: Atomic Gov Bond Bidding Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH go_bo AS (
    SELECT
        bidding_session
        , bidding_method
        , bond_code
        , issuer_name
        , bond_type
        , term
        , issue_date
        , issue_method
        , calling_value
        , bidding_value
        , winning_value
        , nominal_interest_rate
        , winning_interest_rate
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_gov_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_GOV_BOND_OFFERING', "go_bo.bidding_session") }} AS gov_bond_bidding_result_id
    , CAST(go_bo.bidding_session AS string)            AS bidding_session
    , CAST('HNX_GOV_BOND_OFFERING' AS string)          AS src_stm_code
    , CAST(go_bo.bidding_method AS string)             AS bidding_method
    , CAST(go_bo.bond_code AS string)                  AS bond_code
    , CAST(go_bo.issuer_name AS string)                AS issuer_name
    , CAST(go_bo.bond_type AS string)                  AS bond_tp
    , CAST(go_bo.term AS string)                       AS bond_term
    , CAST(go_bo.issue_date AS date)                   AS issue_date
    , CAST(go_bo.issue_method AS string)                AS issue_method
    , CAST(go_bo.calling_value AS decimal(23,2))        AS calling_value
    , CAST(go_bo.bidding_value AS decimal(23,2))        AS bidding_value
    , CAST(go_bo.winning_value AS decimal(23,2))        AS winning_value
    , CAST(go_bo.nominal_interest_rate AS decimal(5,2)) AS nominal_interest_rate
    , CAST(go_bo.winning_interest_rate AS decimal(5,2)) AS winning_interest_rate
    , CAST(go_bo.report_month AS string)                AS report_month
FROM go_bo
