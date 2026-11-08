/*
*--------------------------------------------------------------------*
* Program code: atm_discretionary_investment_account
* Program name: Atomic Discretionary Investment Account
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FMS_INVES_ACC.
*--------------------------------------------------------------------*
*/

WITH in_ac AS (
    SELECT
        id
        , inves_id
        , account
        , contract_no
        , acc_place
        , date_report
        , ad_scale
        , act_scale
        , list_value
        , manager_fee
    FROM {{ ref('ods_fms_inves_acc') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INVES_ACC', "in_ac.id") }}   AS discretionary_investment_account_id
    , CAST(in_ac.id AS string)                                           AS discretionary_investment_account_code
    , CAST('FMS_INVES_ACC' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_INVES', "in_ac.inves_id") }} AS discretionary_investment_investor_id
    , CAST(in_ac.inves_id AS string)                                     AS discretionary_investment_investor_code
    , CAST(in_ac.account AS string)                                      AS account_nbr
    , CAST(in_ac.contract_no AS string)                                  AS contract_nbr
    , CAST(in_ac.acc_place AS string)                                    AS account_opening_place
    , CAST(in_ac.date_report AS date)                                    AS rpt_dt
    , CAST(in_ac.ad_scale AS decimal(23,2))                              AS committed_entrustment_scale_amt
    , CAST(in_ac.act_scale AS decimal(23,2))                             AS actual_entrustment_scale_amt
    , CAST(in_ac.list_value AS decimal(23,2))                            AS portfolio_val_amt
    , CAST(in_ac.manager_fee AS decimal(23,2))                           AS management_fee_amt
FROM in_ac