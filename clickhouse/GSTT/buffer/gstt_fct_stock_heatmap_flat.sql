/*
*--------------------------------------------------------------------*
* Program code: gstt_fct_stock_heatmap_flat
* Program name: GSTT Buffer chart template [2399] heat-map
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2399] heat-map -> mart.gstt_fct_stock_heatmap_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
*                                       Universe/lọc tĩnh: floor_code IN ('10','02','04') AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND (ifNull(public_company_dim_id, '') != '' OR ifNull(securities_company_dim_id, '') != '')
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    cdr_dt,
    symbol,
    public_company_dim_id,
    securities_company_dim_id,
    outstanding_share_quantity,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm
FROM {{ ref('gstt_fct_stock_portfolio_snpst_flat') }}
WHERE cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND floor_code IN ('10','02','04') AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND (coalesce(public_company_dim_id, '') != '' OR coalesce(securities_company_dim_id, '') != '')
