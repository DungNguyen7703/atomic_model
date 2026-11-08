/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_index_valuation_flat
* Program name: GSTT Buffer chart template [2352] dinh-gia
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2352] dinh-gia -> mart.gstt_fct_index_valuation_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_index_constituent_snpst_flat, datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ không loại sàn 03
*                                       Grain: 1 dòng / mã CK / chỉ số / ngày (INNER JOIN: chỉ mã thuộc rổ)
*--------------------------------------------------------------------*
*/

SELECT
    idx.cdr_dt AS cdr_dt,
    idx.symbol AS symbol,
    index_code,
    outstanding_share_quantity,
    net_profit_after_tax,
    owner_equity,
    floor_code,
    stock_tp_code,
    close_price,
    idx_market_index_val,
    idx_market_cap,
    idx_pe,
    idx_pb,
    idx_eps
FROM {{ ref('gstt_fct_index_constituent_snpst_flat') }} idx
     JOIN {{ ref('gstt_fct_stock_portfolio_snpst_flat') }} s
       ON s.symbol = idx.symbol AND s.cdr_dt = idx.cdr_dt
WHERE idx.cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
