/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_derivative_list_flat
* Program name: GSTT Buffer chart template [2338] bang-phai-sinh
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2338] bang-phai-sinh -> mart.gstt_fct_derivative_list_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_DER (sàn 03)
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    total_derivative_vol,
    total_derivative_negotiated_vol,
    total_derivative_val,
    total_derivative_negotiated_val,
    foreign_net_derivative_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    underlying_symbol,
    maturity_dt,
    reference_price,
    close_price,
    price_change
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND floor_code = '03'
