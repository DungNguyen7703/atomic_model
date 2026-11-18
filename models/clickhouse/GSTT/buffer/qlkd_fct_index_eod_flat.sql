/*
*--------------------------------------------------------------------*
* Program code: qlkd_fct_index_eod_flat
* Program name: GSTT Buffer chart template [2351] chi-so-eod
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2351] chi-so-eod -> mart.qlkd_fct_index_eod_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.qlkd_fct_market_index_snpst_flat
*                                       Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    market_code,
    market_index_val,
    open_index,
    high_index,
    low_index,
    prior_index,
    index_change,
    index_percent_change,
    advances_count,
    declines_count,
    no_change_count,
    ceiling_count,
    floor_count,
    index_nm
FROM {{ ref('qlkd_fct_market_index_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
