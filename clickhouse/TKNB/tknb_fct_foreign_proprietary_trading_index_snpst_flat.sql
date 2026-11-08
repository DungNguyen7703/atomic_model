-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_foreign_proprietary_trading_index_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT 
        snpst_dt_dim_id,
        index_constituent_dim_id,
        market_index_val,
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
    FROM {{ ref('dtm_fct_foreign_proprietary_trading_index_snpst')}}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_index_constituent AS (
    SELECT 
        index_constituent_dim_id,
        index_code,
        index_id,
        index_nm
    FROM {{ ref('dtm_index_constituent_dim')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_CSIDXINFOR'
)

SELECT 
    f.snpst_dt_dim_id,
    f.index_constituent_dim_id,
    f.market_index_val,
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
    dim.index_code,
    dim.index_id,
    dim.index_nm
FROM fact f
JOIN dim_index_constituent dim 
    ON f.index_constituent_dim_id = dim.index_constituent_dim_id




    