/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_top_foreign_trading_by_index_flat
* Program name: GSTT Buffer chart template [2374] top-nn-theo-chi-so
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2374] top-nn-theo-chi-so -> mart.gstt_fct_top_foreign_trading_by_index_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
*                                       Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
*                                       Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
*                                       Cột dẫn xuất: eps_vs_chi_so_eps
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
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_eps,
    CAST(net_profit_after_tax_ttm AS DOUBLE) / nullIf(CAST(outstanding_share_quantity AS DOUBLE), 0) - CAST(idx_eps AS DOUBLE) AS eps_vs_chi_so_eps
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }} s
     LEFT JOIN {{ ref('gstt_fct_index_constituent_snpst_flat') }} b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
