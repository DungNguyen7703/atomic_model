/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_price_volume_history_flat
* Program name: GSTT Buffer chart template [2392] lich-su-gia-khoi-luong
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2392] lich-su-gia-khoi-luong -> mart.gstt_fct_price_volume_history_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: bien_dong_gia_tuyet_doi
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    bond_trading_vol,
    floor_code,
    stock_tp_code,
    high_price,
    low_price,
    close_price,
    high_price - low_price AS bien_dong_gia_tuyet_doi
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND stock_tp_code = '1' AND floor_code IN ('04','10','03','02')
