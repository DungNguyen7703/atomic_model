/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_top_losers_by_index_flat
* Program name: GSTT Buffer chart template [2362] top-giam-gia-theo-chi-so
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2362] top-giam-gia-theo-chi-so -> mart.gstt_fct_top_losers_by_index_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: giữ grain flat nguồn
*                                       Cột dẫn xuất: bien_do_so_voi_san
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (CAST(close_price AS DOUBLE) - CAST(floor_price AS DOUBLE)) / nullIf(CAST(ceiling_price AS DOUBLE) - CAST(floor_price AS DOUBLE), 0) * 100 AS bien_do_so_voi_san
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03'
