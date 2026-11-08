/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_valuation_report_bm021_flat
* Program name: GSTT Buffer chart template [2391] bm021-mss-dinh-gia
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2391] bm021-mss-dinh-gia -> mart.gstt_fct_valuation_report_bm021_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: pct_bien_dong_ngay
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    outstanding_share_quantity,
    net_profit_after_tax,
    net_profit_after_tax_ttm,
    owner_equity,
    weighted_average_outstanding_share_quantity,
    weighted_average_outstanding_share_quantity_ttm,
    owner_equity_weighted_average_outstanding_share_quantity,
    owner_equity_weighted_average_outstanding_share_quantity_ttm,
    owner_equity_average_4_quarter,
    floor_code,
    stock_tp_code,
    listed_share_count,
    first_trading_dt,
    high_price,
    low_price,
    reference_price,
    close_price,
    (CAST(high_price AS DOUBLE) - CAST(low_price AS DOUBLE)) / nullIf(CAST(reference_price AS DOUBLE), 0) * 100 AS pct_bien_dong_ngay
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03'
