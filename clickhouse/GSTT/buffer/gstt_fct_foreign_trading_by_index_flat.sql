/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_foreign_trading_by_index_flat
* Program name: GSTT Buffer chart template [2382] nuoc-ngoai-theo-chi-so
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2382] nuoc-ngoai-theo-chi-so -> mart.gstt_fct_foreign_trading_by_index_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
*                                       Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: ty_trong_freefloat_tren_tong_von_hoa_idx
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    index_code,
    idx_foreign_net_vol,
    idx_foreign_net_val,
    idx_market_cap,
    idx_free_float_market_cap,
    CAST(idx_free_float_market_cap AS DOUBLE) / nullIf(CAST(idx_market_cap AS DOUBLE), 0) * 100 AS ty_trong_freefloat_tren_tong_von_hoa_idx
FROM {{ ref('gstt_fct_index_constituent_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
