/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_bond_list_flat
* Program name: GSTT Buffer chart template [2337] bang-trai-phieu
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2337] bang-trai-phieu -> mart.gstt_fct_bond_list_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: klgd_rong
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_negotiated_vol,
    bond_trading_vol,
    bond_negotiated_vol,
    bond_trading_val,
    bond_negotiated_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    issuer_nm,
    maturity_dt,
    coupon_rate,
    yield,
    open_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    total_matched_vol - total_negotiated_vol AS klgd_rong
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND stock_tp_code = '1' AND floor_code IN ('04','10','03','02')
