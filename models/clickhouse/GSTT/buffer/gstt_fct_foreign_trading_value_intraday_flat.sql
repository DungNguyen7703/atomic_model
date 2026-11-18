/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_foreign_trading_value_intraday_flat
* Program name: GSTT Buffer chart template [2381] nuoc-ngoai-gtnn-intraday
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2381] nuoc-ngoai-gtnn-intraday -> mart.gstt_fct_foreign_trading_value_intraday_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_foreign_trading_min_snpst_flat
*                                       Universe/lọc tĩnh: NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03' AND (toHour(trade_minute_tms) * 60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    trade_minute_tms,
    foreign_buy_val_at_min,
    foreign_sell_val_at_min,
    floor_code,
    stock_tp_code
FROM {{ ref('gstt_fct_foreign_trading_min_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03' AND (hour(trade_minute_tms) * 60 + minute(trade_minute_tms)) BETWEEN 540 AND 885
