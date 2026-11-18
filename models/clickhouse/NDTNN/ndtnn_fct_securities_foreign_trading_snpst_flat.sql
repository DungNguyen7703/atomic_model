-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_securities_foreign_trading_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Securities Foreign Trading Snapshot
    f.snpst_dt_dim_id,
    f.securities_dim_id,
    f.public_company_dim_id,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.total_market_val,
    -- CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt,
    -- SECURITIES DIMENSION
    sec_dim.symbol                     AS symbol,
    sec_dim.security_full_nm           AS security_full_nm,
    sec_dim.stock_tp_code              AS stock_tp_code,
    sec_dim.floor_code                 AS floor_code,
    sec_dim.listed_share_count         AS listed_share_count,
    sec_dim.total_listing_vol          AS total_listing_vol,
    sec_dim.underlying_symbol          AS underlying_symbol,
    sec_dim.issuer_nm                  AS issuer_nm,
    sec_dim.listing_dt                 AS listing_dt,
    sec_dim.symbol_status_code         AS symbol_status_code,
    sec_dim.trading_time               AS trading_time,
    sec_dim.src_stm_code                AS securities_src_stm_code,
    -- PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code      AS business_line_level_1_code,
    pc_dim.ids_registration_dt             AS ids_registration_dt,
    pc_dim.public_company_status_code      AS public_company_status_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm,
    pc_dim.public_company_english_nm       AS public_company_english_nm,
    pc_dim.enterprise_tp_code              AS enterprise_tp_code,
    pc_dim.public_company_tp_code          AS public_company_tp_code,
    pc_dim.head_office_province_nm         AS head_office_province_nm,
    pc_dim.operating_status_code           AS operating_status_code,
    pc_dim.has_state_ownership_indicator   AS has_state_ownership_indicator,
    pc_dim.charter_capital_amt             AS charter_capital_amt,
    pc_dim.first_registration_dt           AS first_registration_dt,
    pc_dim.latest_registration_dt          AS latest_registration_dt,
    pc_dim.latest_registration_province_nm AS latest_registration_province_nm,
    pc_dim.ids_registration_indicator      AS ids_registration_indicator,
    pc_dim.public_company_form_code        AS public_company_form_code,
    pc_dim.former_state_owned_indicator    AS former_state_owned_indicator,
    pc_dim.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc_dim.has_parent_company_indicator    AS has_parent_company_indicator,
    pc_dim.has_subsidiary_indicator        AS has_subsidiary_indicator,
    pc_dim.has_joint_venture_indicator     AS has_joint_venture_indicator,
    pc_dim.ipo_company_indicator           AS ipo_company_indicator,
    pc_dim.src_stm_code                    AS public_company_src_stm_code

FROM {{ ref('dtm_fct_securities_foreign_trading_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_dim') }} sec_dim
    ON sec_dim.securities_dim_id = f.securities_dim_id
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE trade_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')