/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_investor_category_index_trading_flat
* Program name: GSTT Buffer chart template [2386] phan-loai-ndt-index
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2386] phan-loai-ndt-index -> mart.gstt_fct_investor_category_index_trading_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_investor_category_index_trading_snpst_flat
*                                       Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    index_code,
    investor_category_code,
    buy_val,
    sell_val,
    matched_buy_val,
    matched_sell_val,
    market_index_val
FROM {{ ref('gstt_fct_investor_category_index_trading_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
