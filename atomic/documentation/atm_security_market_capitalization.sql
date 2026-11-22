/*
*--------------------------------------------------------------------*
* Program code: atm_security_market_capitalization
* Program name: Atomic Security Market Capitalization
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_HNX_MARKET_CAPITALIZATION.yaml (UAT chua co): entity security_market_capitalization, snapshot nhu cac entity HNX khac.
*--------------------------------------------------------------------*
*/

WITH x AS (
    SELECT
        ticker_symbol
        , reference_price
        , open_price
        , close_price
        , average_price
        , highest_price
        , lowest_price
        , change_points
        , change_percentage
        , even_lot_match_volume
        , even_lot_match_value
        , odd_lot_match_volume
        , odd_lot_match_value
        , even_lot_put_through_volume
        , even_lot_put_through_value
        , odd_lot_put_through_volume
        , odd_lot_put_through_value
        , total_trading_volume
        , volume_weight_percentage
        , total_trading_value
        , value_weight_percentage
        , outstanding_shares
        , market_capitalization
        , market_cap_weight_percentage
        , report_year
        , report_month
        , report_day
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_market_capitalization') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_MARKET_CAPITALIZATION', "x.ticker_symbol") }} AS security_market_capitalization_id
    , CAST('HNX_MARKET_CAPITALIZATION' AS string) AS src_stm_code
    , CAST(x.ticker_symbol AS string) AS ticker_symbol
    , CAST(x.reference_price AS decimal(23,2)) AS reference_price
    , CAST(x.open_price AS decimal(23,2)) AS open_price
    , CAST(x.close_price AS decimal(23,2)) AS close_price
    , CAST(x.average_price AS decimal(23,2)) AS average_price
    , CAST(x.highest_price AS decimal(23,2)) AS highest_price
    , CAST(x.lowest_price AS decimal(23,2)) AS lowest_price
    , CAST(x.change_points AS decimal(23,2)) AS change_point
    , CAST(x.change_percentage AS decimal(5,2)) AS change_percentage
    , CAST(x.even_lot_match_volume AS bigint) AS even_lot_match_vol
    , CAST(x.even_lot_match_value AS decimal(23,2)) AS even_lot_match_val
    , CAST(x.odd_lot_match_volume AS bigint) AS odd_lot_match_vol
    , CAST(x.odd_lot_match_value AS decimal(23,2)) AS odd_lot_match_val
    , CAST(x.even_lot_put_through_volume AS bigint) AS even_lot_put_through_vol
    , CAST(x.even_lot_put_through_value AS decimal(23,2)) AS even_lot_put_through_val
    , CAST(x.odd_lot_put_through_volume AS bigint) AS odd_lot_put_through_vol
    , CAST(x.odd_lot_put_through_value AS decimal(23,2)) AS odd_lot_put_through_val
    , CAST(x.total_trading_volume AS bigint) AS total_trading_vol
    , CAST(x.volume_weight_percentage AS decimal(5,2)) AS vol_weight_percentage
    , CAST(x.total_trading_value AS decimal(23,2)) AS total_trading_val
    , CAST(x.value_weight_percentage AS decimal(5,2)) AS val_weight_percentage
    , CAST(x.outstanding_shares AS bigint) AS outstanding_share_quantity
    , CAST(x.market_capitalization AS decimal(23,2)) AS market_capitalization_val
    , CAST(x.market_cap_weight_percentage AS decimal(5,2)) AS market_capitalization_weight_percentage
    , CAST(x.report_year AS int) AS rpt_year
    , CAST(x.report_month AS int) AS rpt_month
    , CAST(x.report_day AS int) AS rpt_day
FROM x
