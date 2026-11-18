/*
*--------------------------------------------------------------------*
* Program code: atm_private_corp_bond_trading_summary
* Program name: Atomic Private Corp Bond Trading Summary
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_tr AS (
    SELECT
        indicator
        , unit
        , value
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_private_corp_bond_trading') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_TRADING', "pr_tr.indicator") }} AS private_corp_bond_trading_summary_id
    , CAST('HNX_PRIVATE_CORP_BOND_TRADING' AS string)  AS src_stm_code
    , CAST(pr_tr.indicator AS string)                  AS indicator_name
    , CAST(pr_tr.unit AS string)                       AS measurement_unit
    , CAST(pr_tr.value AS decimal(23,4))               AS indicator_value
FROM pr_tr
