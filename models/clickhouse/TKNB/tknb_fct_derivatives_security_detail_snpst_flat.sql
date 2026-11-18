-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_derivatives_security_detail_snpst
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        security_trading_snpst_dim_id,
        open_interest_quantity,
        trading_vol,
        trading_val,
        foreign_investor_buy_vol,
        foreign_investor_sell_vol,
        foreign_investor_buy_val,
        foreign_investor_sell_val,
        proprietary_buy_vol,
        proprietary_sell_vol,
        proprietary_buy_val,
        proprietary_sell_val,
        src_stm_code
    FROM {{ ref('dtm_fct_derivatives_security_detail_snpst')}}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_security_trading AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        security_full_nm,
        floor_code,
        isin_code,
        maturity_dt,
        contract_multiplier
    FROM {{ ref('dtm_security_trading_snpst_dim')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
)

SELECT
    f.snpst_dt_dim_id,
    f.security_trading_snpst_dim_id,
    f.open_interest_quantity,
    f.trading_vol,
    f.trading_val,
    f.foreign_investor_buy_vol,
    f.foreign_investor_sell_vol,
    f.foreign_investor_buy_val,
    f.foreign_investor_sell_val,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')          AS snpst_cdr_dt,
    dim.symbol,
    dim.security_full_nm,
    dim.floor_code,
    dim.isin_code,
    dim.maturity_dt,
    CAST(dim.contract_multiplier AS decimal(23,2))  AS contract_multiplier
FROM fact f
LEFT JOIN dim_security_trading dim
    ON f.security_trading_snpst_dim_id = dim.security_trading_snpst_dim_id
