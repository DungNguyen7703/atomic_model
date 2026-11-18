/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_index_realtime_flat
* Program name: GSTT Buffer chart template [2349] chi-so-realtime
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2349] chi-so-realtime -> mart.gstt_fct_index_realtime_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_market_index_intraday_flat
*                                       Universe/lọc tĩnh: substring(index_time, 1, 5) BETWEEN '09:00' AND '14:45'
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    market_code,
    index_time,
    market_index_val_at_time,
    total_val_at_time
FROM {{ ref('gstt_fct_market_index_intraday_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND substring(index_time, 1, 5) BETWEEN '09:00' AND '14:45'
