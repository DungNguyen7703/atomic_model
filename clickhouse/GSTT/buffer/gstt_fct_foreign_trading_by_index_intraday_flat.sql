/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_foreign_trading_by_index_intraday_flat
* Program name: GSTT Buffer chart template [2383] nuoc-ngoai-theo-chi-so-intraday
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2383] nuoc-ngoai-theo-chi-so-intraday -> mart.gstt_fct_foreign_trading_by_index_intraday_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
*                                       Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: dinh_gia_theo_pe_pb
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    index_code,
    idx_pe,
    idx_pb,
    CAST(idx_pe AS DOUBLE) / nullIf(CAST(idx_pb AS DOUBLE), 0) AS dinh_gia_theo_pe_pb
FROM {{ ref('gstt_fct_index_constituent_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
