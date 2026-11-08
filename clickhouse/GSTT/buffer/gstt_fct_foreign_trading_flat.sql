/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_foreign_trading_flat
* Program name: GSTT Buffer chart template [2379] nuoc-ngoai
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2379] nuoc-ngoai -> mart.gstt_fct_foreign_trading_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: ty_le_mua_rong_nn_klgd
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    open_price,
    high_price,
    low_price,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    (CAST(foreign_buy_vol AS DOUBLE) - CAST(foreign_sell_vol AS DOUBLE)) / nullIf(CAST(total_matched_vol AS DOUBLE), 0) * 100 AS ty_le_mua_rong_nn_klgd
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03'
