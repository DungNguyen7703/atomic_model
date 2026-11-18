/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_market_overview_flat
* Program name: GSTT Buffer chart template [2378] tong-quan
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2378] tong-quan -> mart.gstt_fct_market_overview_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
*                                       Cột dẫn xuất: chenh_lech_von_hoa_freefloat_vs_thuong
*--------------------------------------------------------------------*
*/

SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    outstanding_share_quantity,
    free_float_share_quantity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    open_price,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    idx_market_cap,
    idx_free_float_market_cap,
    CAST(close_price AS DOUBLE) * (CAST(outstanding_share_quantity AS DOUBLE) - CAST(free_float_share_quantity AS DOUBLE)) AS chenh_lech_von_hoa_freefloat_vs_thuong
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }} s
     LEFT JOIN {{ ref('gstt_fct_index_constituent_snpst_flat') }} b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
