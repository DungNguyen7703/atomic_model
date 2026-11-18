/*
*--------------------------------------------------------------------*
* Program code: atm_fund_distribution_agent_x_investment_fund_relationship
* Program name: Atomic Fund Distribution Agent X Investment Fund Relationship
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Doi ten tu atm_investment_fund_x_fund_distribution_agent_relationship theo LLD Atomic FMS UAT 20261006
*										(lld_FMS_AGEN_FUNDS.yaml, entity fund_distribution_agent_x_investment_fund_relationship); bo cot *_rltnp_id/code (luon NULL, LLD khong co)
*--------------------------------------------------------------------*
*/

WITH ag_fu AS (
    SELECT
        fund_id
        , agency_id
    FROM {{ ref('ods_fms_agen_funds') }}
)

SELECT
    CAST('FMS_AGEN_FUNDS' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "ag_fu.fund_id") }}      AS investment_fund_id
    , CAST(ag_fu.fund_id AS string)                                          AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_AGENCIES', "ag_fu.agency_id") }} AS fund_distribution_agent_id
    , CAST(ag_fu.agency_id AS string)                                        AS fund_distribution_agent_code
FROM ag_fu