/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_stock_list_flat
* Program name: GSTT Buffer chart template [2336] bang-co-phieu
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2336] bang-co-phieu -> mart.gstt_fct_stock_list_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: vi_the_gia_trong_bien_do
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_matched_val,
    total_derivative_vol,
    total_derivative_val,
    total_negotiated_vol,
    total_negotiated_val,
    foreign_net_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    open_price,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (CAST(close_price AS DOUBLE) - CAST(low_price AS DOUBLE)) / nullIf(CAST(high_price AS DOUBLE) - CAST(low_price AS DOUBLE), 0) * 100 AS vi_the_gia_trong_bien_do
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03'
