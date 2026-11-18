/*
*--------------------------------------------------------------------*
* Program code: atm_discretionary_investment_investor
* Program name: Atomic Discretionary Investment Investor
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in AS (
    SELECT
        id
        , sec_id
        , nat_id
        , sto_id
        , item_name
        , dorf
        , relation_ship
        , ad_scale
        , act_scale
        , list_value
    FROM {{ ref('ods_fms_inves') }}
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fms_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INVES', "in.id") }}            AS discretionary_investment_investor_id
    , CAST(in.id AS string)                                              AS discretionary_investment_investor_code
    , CAST('FMS_INVES' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "in.sec_id") }} AS fmc_id
    , CAST(in.sec_id AS string)                                          AS fmc_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}  AS nationality_id
    , CAST(nati.sname AS string)                                         AS nationality_code
    , CAST(in.sto_id AS string)                                          AS stockholder_tp_code
    , CAST(in.item_name AS string)                                       AS discretionary_investment_investor_full_nm
    , CAST(in.dorf AS string)                                            AS organization_territory_tp_code
    , CAST(in.relation_ship AS string)                                   AS rltnp_description
    , CAST(in.ad_scale AS decimal(23,2))                                 AS committed_entrustment_scale_amt
    , CAST(in.act_scale AS decimal(23,2))                                AS actual_entrustment_scale_amt
    , CAST(in.list_value AS decimal(23,2))                               AS portfolio_val_amt
FROM in
    LEFT JOIN nati ON in.NAT_ID = nati.ID