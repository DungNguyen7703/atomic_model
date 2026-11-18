/*
*--------------------------------------------------------------------*
* Program code: atm_brokerage_market_share_hose_brokerage_market_share
* Program name: Atomic Brokerage Market Share – HOSE.BROKERAGE_MARKET_SHARE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH br_ms AS (
    SELECT
        member_code
        , broker_name
        , buy_trading_value
        , sell_trading_value
        , market_share_by_value
        --, classification
        , report_quarter
        , ds_snpst_dt
    FROM {{ ref('ods_hose_brokerage_market_share') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HOSE_BROKERAGE_MARKET_SHARE', "br_ms.member_code") }} AS brokerage_market_share_id
    , CAST('HOSE_BROKERAGE_MARKET_SHARE' AS string) AS src_stm_code
    , CAST(br_ms.member_code AS string) AS sc_member_code
    , CAST(br_ms.broker_name AS string) AS sc_nm
    , CAST(
        COALESCE(br_ms.buy_trading_value, 0) + COALESCE(br_ms.sell_trading_value, 0)
        AS decimal(23,2)
    ) AS total_trading_value
    , CAST(br_ms.market_share_by_value * 100 AS decimal(22,14)) AS market_share_by_value
    , CAST(NULL AS string) AS security_tp_code
    , CAST(br_ms.report_quarter AS string) AS report_quarter
FROM br_ms
