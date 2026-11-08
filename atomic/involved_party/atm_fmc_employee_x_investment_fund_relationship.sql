/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_employee_x_investment_fund_relationship
* Program name: Atomic Fund Management Company Employee X Investment Fund Relationship
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Doi ten tu atm_investment_fund_x_fmc_employee_relationship theo LLD Atomic FMS UAT 20261006
*										(lld_FMS_FUND_TL_PRO.yaml, entity fmc_employee_x_investment_fund_relationship); bo cot *_rltnp_id/code (luon NULL, LLD khong co)
*--------------------------------------------------------------------*
*/

WITH fu_tl_pr AS (
    SELECT
        fund_id
        , tlpr_id
    FROM {{ ref('ods_fms_fund_tl_pro') }}
)

SELECT
    CAST('FMS_FUND_TL_PRO' AS string)                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "fu_tl_pr.fund_id") }}       AS investment_fund_id
    , CAST(fu_tl_pr.fund_id AS string)                                           AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "fu_tl_pr.tlpr_id") }} AS fmc_employee_id
    , CAST(fu_tl_pr.tlpr_id AS string)                                           AS fmc_employee_code
FROM fu_tl_pr