/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_top_value_by_exchange_flat
* Program name: GSTT Buffer chart template [2376] top-gt-theo-san
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2376] top-gt-theo-san -> mart.gstt_fct_top_value_by_exchange_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ không loại sàn 03
*                                       Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
*                                       Cột dẫn xuất: ty_trong_gtgd_tren_von_hoa
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
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    CAST(total_matched_val AS DOUBLE) / nullIf(CAST(close_price AS DOUBLE) * CAST(outstanding_share_quantity AS DOUBLE), 0) * 100 AS ty_trong_gtgd_tren_von_hoa
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }} s
     LEFT JOIN {{ ref('gstt_fct_index_constituent_snpst_flat') }} b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
