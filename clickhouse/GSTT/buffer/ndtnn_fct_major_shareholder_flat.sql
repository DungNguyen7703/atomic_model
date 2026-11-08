/*
*--------------------------------------------------------------------*
* Program code: ndtnn_fct_major_shareholder_flat
* Program name: GSTT Buffer chart template [2397] co-dong-lon
* Created by:
* Created date: 2026-10-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		tuan.nguyenvanb		[MOI, LLD commit v5] Bang buffer chart template [2397] co-dong-lon -> mart.ndtnn_fct_major_shareholder_flat (ten chuan v5, thay mart.buffer_*).
*                                       Sinh tu Datamart/flat-table/GSTT/buffer/02_populate (ClickHouse) sang Spark SQL:
*                                       toFloat64 -> CAST AS DOUBLE, ifNull -> coalesce, toHour/toMinute -> hour/minute, bo SETTINGS join_use_nulls.
*                                       Nguồn: datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat
*                                       Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
*                                       Grain: giữ grain flat nguồn
*--------------------------------------------------------------------*
*/

SELECT
    snpst_cdr_dt,
    equity_ticker_symbol,
    ticker_symbol,
    total_issued_share_quantity,
    current_foreign_holding_quantity
FROM {{ ref('ndtnn_fct_public_company_foreign_ownership_snpst_flat') }}
WHERE snpst_cdr_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
