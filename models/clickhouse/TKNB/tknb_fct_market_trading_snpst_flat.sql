-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_market_trading_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT 
        snpst_dt_dim_id,
        index_constituent_dim_id,
        market_index_val,
        total_trading_val,
        total_trading_vol,
        matched_trading_val,
        matched_trading_vol,
        negotiated_trading_val,
        negotiated_trading_vol,
        odd_lot_trading_val,
        odd_lot_trading_vol,
        src_stm_code
    FROM {{ ref('dtm_fct_market_trading_snpst')}}
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
    f.total_trading_val,
    f.total_trading_vol,
    f.matched_trading_val,
    f.matched_trading_vol,
    f.negotiated_trading_val,
    f.negotiated_trading_vol,
    f.odd_lot_trading_val,
    f.odd_lot_trading_vol,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    dim.index_code,
    dim.index_id,
    dim.index_nm
FROM fact f
JOIN dim_index_constituent dim 
    ON f.index_constituent_dim_id = dim.index_constituent_dim_id




    