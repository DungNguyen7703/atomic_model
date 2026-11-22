/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_market_capitalization
* Program name: ODS HNX.MARKET_CAPITALIZATION
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao ODS theo LLD lld_HNX_MARKET_CAPITALIZATION.yaml (UAT chua co). Cot nguon = source_columns cua LLD; can xac nhan bang hnx_stg.market_capitalization ton tai.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string) AS ticker_symbol
    , CAST(reference_price AS decimal(23,2)) AS reference_price
    , CAST(open_price AS decimal(23,2)) AS open_price
    , CAST(close_price AS decimal(23,2)) AS close_price
    , CAST(average_price AS decimal(23,2)) AS average_price
    , CAST(highest_price AS decimal(23,2)) AS highest_price
    , CAST(lowest_price AS decimal(23,2)) AS lowest_price
    , CAST(change_points AS decimal(23,2)) AS change_points
    , CAST(change_percentage AS decimal(5,2)) AS change_percentage
    , CAST(even_lot_match_volume AS bigint) AS even_lot_match_volume
    , CAST(even_lot_match_value AS decimal(23,2)) AS even_lot_match_value
    , CAST(odd_lot_match_volume AS bigint) AS odd_lot_match_volume
    , CAST(odd_lot_match_value AS decimal(23,2)) AS odd_lot_match_value
    , CAST(even_lot_put_through_volume AS bigint) AS even_lot_put_through_volume
    , CAST(even_lot_put_through_value AS decimal(23,2)) AS even_lot_put_through_value
    , CAST(odd_lot_put_through_volume AS bigint) AS odd_lot_put_through_volume
    , CAST(odd_lot_put_through_value AS decimal(23,2)) AS odd_lot_put_through_value
    , CAST(total_trading_volume AS bigint) AS total_trading_volume
    , CAST(volume_weight_percentage AS decimal(5,2)) AS volume_weight_percentage
    , CAST(total_trading_value AS decimal(23,2)) AS total_trading_value
    , CAST(value_weight_percentage AS decimal(5,2)) AS value_weight_percentage
    , CAST(outstanding_shares AS bigint) AS outstanding_shares
    , CAST(market_capitalization AS decimal(23,2)) AS market_capitalization
    , CAST(market_cap_weight_percentage AS decimal(5,2)) AS market_cap_weight_percentage
    , CAST(report_year AS int) AS report_year
    , CAST(report_month AS int) AS report_month
    , CAST(report_day AS int) AS report_day
FROM {{ source('source_hnx', 'raw_market_capitalization') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
