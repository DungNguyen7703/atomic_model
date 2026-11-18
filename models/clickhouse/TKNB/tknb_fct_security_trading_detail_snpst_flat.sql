-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_security_trading_detail_snpst
-- Type  : FACT
-- Dim   : dtm_security_trading_snpst_dim (GSTT, dung chung)
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        security_trading_snpst_dim_id,
        trading_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        average_price,
        high_price,
        low_price,
        buy_order_cnt,
        buy_order_vol,
        sell_order_cnt,
        sell_order_vol,
        matched_trading_vol,
        matched_trading_val,
        negotiated_trading_vol,
        negotiated_trading_val,
        odd_lot_trading_vol,
        odd_lot_trading_val,
        total_trading_vol,
        total_trading_val,
        max_foreign_ownership_ratio,
        remaining_foreign_ownership_ratio,
        foreign_investor_total_buy_vol,
        foreign_investor_total_sell_vol,
        foreign_investor_total_buy_val,
        foreign_investor_total_sell_val,
        foreign_investor_negotiated_buy_vol,
        foreign_investor_negotiated_sell_vol,
        foreign_investor_negotiated_buy_val,
        foreign_investor_negotiated_sell_val,
        foreign_investor_matched_buy_vol,
        foreign_investor_matched_sell_vol,
        foreign_investor_matched_buy_val,
        foreign_investor_matched_sell_val,
        proprietary_total_buy_vol,
        proprietary_total_sell_vol,
        proprietary_total_buy_val,
        proprietary_total_sell_val,
        proprietary_negotiated_buy_vol,
        proprietary_negotiated_sell_vol,
        proprietary_negotiated_buy_val,
        proprietary_negotiated_sell_val,
        proprietary_matched_buy_vol,
        proprietary_matched_sell_vol,
        proprietary_matched_buy_val,
        proprietary_matched_sell_val,
        src_stm_code
    FROM {{ ref('dtm_fct_security_trading_detail_snpst')}}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_security_trading AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        security_full_nm,
        floor_code,
        stock_tp_code,
        isin_code
    FROM {{ ref('dtm_security_trading_snpst_dim')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
)

SELECT
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.trading_status_code,
    f.reference_price,
    f.ceiling_price,
    f.floor_price,
    f.close_price,
    f.average_price,
    f.high_price,
    f.low_price,
    f.buy_order_cnt,
    f.buy_order_vol,
    f.sell_order_cnt,
    f.sell_order_vol,
    f.matched_trading_vol,
    f.matched_trading_val,
    f.negotiated_trading_vol,
    f.negotiated_trading_val,
    f.odd_lot_trading_vol,
    f.odd_lot_trading_val,
    f.total_trading_vol,
    f.total_trading_val,
    f.max_foreign_ownership_ratio,
    f.remaining_foreign_ownership_ratio,
    f.foreign_investor_total_buy_vol,
    f.foreign_investor_total_sell_vol,
    f.foreign_investor_total_buy_val,
    f.foreign_investor_total_sell_val,
    f.foreign_investor_negotiated_buy_vol,
    f.foreign_investor_negotiated_sell_vol,
    f.foreign_investor_negotiated_buy_val,
    f.foreign_investor_negotiated_sell_val,
    f.foreign_investor_matched_buy_vol,
    f.foreign_investor_matched_sell_vol,
    f.foreign_investor_matched_buy_val,
    f.foreign_investor_matched_sell_val,
    f.proprietary_total_buy_vol,
    f.proprietary_total_sell_vol,
    f.proprietary_total_buy_val,
    f.proprietary_total_sell_val,
    f.proprietary_negotiated_buy_vol,
    f.proprietary_negotiated_sell_vol,
    f.proprietary_negotiated_buy_val,
    f.proprietary_negotiated_sell_val,
    f.proprietary_matched_buy_vol,
    f.proprietary_matched_sell_vol,
    f.proprietary_matched_buy_val,
    f.proprietary_matched_sell_val,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    dim.symbol,
    dim.security_full_nm,
    dim.floor_code,
    dim.stock_tp_code,
    dim.isin_code
FROM fact f
LEFT JOIN dim_security_trading dim
    ON f.security_trading_snpst_dim_id = dim.security_trading_snpst_dim_id
