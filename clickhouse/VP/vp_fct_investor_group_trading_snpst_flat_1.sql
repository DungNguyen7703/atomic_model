/*
*--------------------------------------------------------------------*
* Program code: vp_fct_investor_group_trading_snpst_flat
* Program name: VP Fct Investor Group Trading Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-29      huy.pham        [MOI] Flat table ClickHouse: Fact Investor Group
*                                 Trading Snapshot x Calendar Date Dim x Security
*                                 Trading Snapshot Dim x Industry Dim. Grain = 1 dong /
*                                 ma CK|hop dong / ngay GD / san /
*                                 investor_group_code / src_stm_code.
*                                 cdr_dt derive tu snpst_dt_dim_id (NOT NULL) de
*                                 dam bao partition key khong NULL.
* 2026-10-30      huy.pham        Them CAST tuong minh cho tung cot de khop kieu CK DDL.
* 2026-11-18      claude          [O_VP_87] Them 4 cot KL/GT khop lenh va thoa thuan.
* 2026-11-19      claude          [K_VP_518] Them derivative_term tu dtm (da tinh san).
* 2026-11-07      huy.pham        [SUA] Bo qua dtm_security_trading_snpst_dim_hstr —
*                                 dim chua du lat cat ngay lich su. Thay bang sts_all/sts
*                                 tu atm_security_trading_snapshot, dedup theo
*                                 (ticker_symbol, trading_dt), JOIN theo ticker_symbol
*                                 va trading_dt = snpst_dt_dim_id. stock_tp_nm derive
*                                 inline theo CASE floor_code + stock_tp_code + fund_tp_code
*                                 (dong nhat voi dtm_security_trading_snpst_dim).
*                                 Bo WHERE filter etl_date de lay toan bo lich su.
*--------------------------------------------------------------------*
*/

WITH sts_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        full_nm,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        CASE
            WHEN floor_code = '10' THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'E' THEN 'ETF'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'M' THEN 'Chứng chỉ quỹ'
                    WHEN stock_tp_code = '4' THEN 'Chứng quyền'
                    ELSE 'Khác'
                END
            WHEN floor_code IN ('02', '04') THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN stock_tp_code = '3' THEN 'Chứng chỉ quỹ'
                    WHEN stock_tp_code = '4' THEN 'Phái sinh'
                    WHEN stock_tp_code = '5' THEN 'Chứng quyền'
                    WHEN stock_tp_code = '6' THEN 'ETF'
                    ELSE 'Khác'
                END
            WHEN floor_code = '03' THEN 'Phái sinh'
            ELSE 'Khác'
        END                                                         AS stock_tp_nm,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        covered_warrant_tp_code,
        exercise_price,
        exercise_ratio,
        exercise_style_code,
        put_or_call_code,
        contract_multiplier,
        maturity_month_year,
        coupon_rate,
        yield,
        open_price,
        high_price,
        low_price,
        ceiling_price,
        floor_price,
        reference_price,
        close_price,
        price_change,
        product_group_id,
        product_id,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

sts AS (
    SELECT * FROM sts_all WHERE rn = 1
)

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_INVESTOR_GROUP_TRADING_SNPST
    CAST(f.investor_group_trading_snpst_id  AS string)           AS investor_group_trading_snpst_id,
    CAST(f.snpst_dt_dim_id                  AS string)           AS snpst_dt_dim_id,
    CAST(f.security_trading_snpst_dim_id    AS string)           AS security_trading_snpst_dim_id,
    CAST(f.industry_dim_id                  AS string)           AS industry_dim_id,
    CAST(f.security_symbol_code             AS string)           AS security_symbol_code,
    CAST(f.market_id_code                   AS string)           AS market_id_code,
    CAST(f.investor_group_code              AS string)           AS investor_group_code,
    CAST(f.buy_vol                          AS bigint)           AS buy_vol,
    CAST(f.buy_val                          AS decimal(23,2))    AS buy_val,
    CAST(f.sell_vol                         AS bigint)           AS sell_vol,
    CAST(f.sell_val                         AS decimal(23,2))    AS sell_val,
    CAST(f.src_stm_code                     AS string)           AS src_stm_code,
    CAST(f.order_matching_vol               AS bigint)           AS order_matching_vol,
    CAST(f.order_matching_val               AS decimal(23,2))    AS order_matching_val,
    CAST(f.negotiated_trade_vol             AS bigint)           AS negotiated_trade_vol,
    CAST(f.negotiated_trade_val             AS decimal(23,2))    AS negotiated_trade_val,
    CAST(f.derivative_term                  AS string)           AS derivative_term,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)        AS cdr_dt,
    CAST(cal.year                           AS bigint)           AS year,
    CAST(cal.quarter                        AS bigint)           AS quarter,
    CAST(cal.month                          AS bigint)           AS month,
    CAST(cal.day_of_week                    AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                     AS string)           AS is_weekend,
    CAST(cal.holiday_flag                   AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                AS string)           AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT (atm_security_trading_snapshot, all floor_code)
    CAST(sts.ticker_symbol                  AS string)           AS symbol,
    CAST(sts.full_nm                        AS string)           AS security_full_nm,
    CAST(sts.floor_code                     AS string)           AS floor_code,
    CAST(sts.stock_tp_code                  AS string)           AS stock_tp_code,
    CAST(sts.stock_tp_nm                    AS string)           AS stock_tp_nm,
    CAST(sts.underlying_symbol              AS string)           AS underlying_symbol,
    CAST(sts.isin_code                      AS string)           AS isin_code,
    CAST(sts.issuer_nm                      AS string)           AS issuer_nm,
    CAST(sts.listed_share_count             AS bigint)           AS listed_share_count,
    CAST(sts.first_trading_dt               AS date)             AS first_trading_dt,
    CAST(sts.last_trading_dt                AS date)             AS last_trading_dt,
    CAST(sts.issue_dt                       AS date)             AS issue_dt,
    CAST(sts.maturity_dt                    AS date)             AS maturity_dt,
    CAST(sts.fund_tp_code                   AS string)           AS fund_tp_code,
    CAST(sts.covered_warrant_tp_code        AS string)           AS covered_warrant_tp_code,
    CAST(sts.exercise_price                 AS decimal(23,2))    AS exercise_price,
    CAST(sts.exercise_ratio                 AS string)           AS exercise_ratio,
    CAST(sts.exercise_style_code            AS string)           AS exercise_style_code,
    CAST(sts.put_or_call_code               AS string)           AS put_or_call_code,
    CAST(sts.contract_multiplier            AS string)           AS contract_multiplier,
    CAST(sts.maturity_month_year            AS string)           AS maturity_month_year,
    CAST(sts.coupon_rate                    AS decimal(8,5))     AS coupon_rate,
    CAST(sts.yield                          AS decimal(8,5))     AS yield,
    CAST(sts.open_price                     AS decimal(23,2))    AS open_price,
    CAST(sts.high_price                     AS decimal(23,2))    AS high_price,
    CAST(sts.low_price                      AS decimal(23,2))    AS low_price,
    CAST(sts.ceiling_price                  AS decimal(23,2))    AS ceiling_price,
    CAST(sts.floor_price                    AS decimal(23,2))    AS floor_price,
    CAST(sts.reference_price                AS decimal(23,2))    AS reference_price,
    CAST(sts.close_price                    AS decimal(23,2))    AS close_price,
    CAST(sts.price_change                   AS decimal(23,2))    AS price_change,
    CAST(sts.product_group_id               AS string)           AS product_group_id,
    CAST(sts.product_id                     AS string)           AS product_id,
    CAST(sts.src_stm_code                   AS string)           AS sts_dim_src_stm_code,

    -- From: INDUSTRY DIMENSION
    CAST(ind.industry_code                  AS string)           AS industry_code,
    CAST(ind.industry_nm                    AS string)           AS industry_nm

FROM {{ ref('dtm_fct_investor_group_trading_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN sts
    ON  sts.trading_dt    = to_date(f.snpst_dt_dim_id, 'yyyyMMdd')
    AND (
            (f.market_id_code = 'STK'                     AND sts.ticker_symbol = f.security_symbol_code)
         OR (f.market_id_code IN ('STX', 'UPX', 'DVX')   AND sts.isin_code     = f.security_symbol_code)
    )
LEFT JOIN {{ ref('dtm_industry_dim') }}_hstr ind
    ON  ind.industry_dim_id = f.industry_dim_id
    AND ind.ds_snpst_dt     = to_date('2026-11-05', 'yyyy-MM-dd')
    AND ind.ds_rcrd_st      = 'ACTIVE'
--WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')

/*
*--------------------------------------------------------------------*
* [DAILY] Code chay hang ngay — thay the toan bo phan WITH...SELECT
* phia tren khi chuyen sang che do incremental theo etl_date.
* Luu y:
*   - sts_all: them filter trading_dt = etl_date
*   - JOIN sts: chi can ticker_symbol (sts da filter ngay roi)
*   - WHERE: bat lai filter f.snpst_dt_dim_id = etl_date
*--------------------------------------------------------------------*

WITH sts_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        full_nm,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        CASE
            WHEN floor_code = '10' THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trai phieu'
                    WHEN stock_tp_code = '2' THEN 'Co phieu'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'E' THEN 'ETF'
                    WHEN stock_tp_code = '3' AND fund_tp_code = 'M' THEN 'Chung chi quy'
                    WHEN stock_tp_code = '4' THEN 'Chung quyen'
                    ELSE 'Khac'
                END
            WHEN floor_code IN ('02', '04') THEN
                CASE
                    WHEN stock_tp_code = '1' THEN 'Trai phieu'
                    WHEN stock_tp_code = '2' THEN 'Co phieu'
                    WHEN stock_tp_code = '3' THEN 'Chung chi quy'
                    WHEN stock_tp_code = '4' THEN 'Phai sinh'
                    WHEN stock_tp_code = '5' THEN 'Chung quyen'
                    WHEN stock_tp_code = '6' THEN 'ETF'
                    ELSE 'Khac'
                END
            WHEN floor_code = '03' THEN 'Phai sinh'
            ELSE 'Khac'
        END                                                         AS stock_tp_nm,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        covered_warrant_tp_code,
        exercise_price,
        exercise_ratio,
        exercise_style_code,
        put_or_call_code,
        contract_multiplier,
        maturity_month_year,
        coupon_rate,
        yield,
        open_price,
        high_price,
        low_price,
        ceiling_price,
        floor_price,
        reference_price,
        close_price,
        price_change,
        product_group_id,
        product_id,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sts AS (
    SELECT * FROM sts_all WHERE rn = 1
)

SELECT
    -- From: FCT_INVESTOR_GROUP_TRADING_SNPST
    CAST(f.investor_group_trading_snpst_id  AS string)           AS investor_group_trading_snpst_id,
    CAST(f.snpst_dt_dim_id                  AS string)           AS snpst_dt_dim_id,
    CAST(f.security_trading_snpst_dim_id    AS string)           AS security_trading_snpst_dim_id,
    CAST(f.industry_dim_id                  AS string)           AS industry_dim_id,
    CAST(f.security_symbol_code             AS string)           AS security_symbol_code,
    CAST(f.market_id_code                   AS string)           AS market_id_code,
    CAST(f.investor_group_code              AS string)           AS investor_group_code,
    CAST(f.buy_vol                          AS bigint)           AS buy_vol,
    CAST(f.buy_val                          AS decimal(23,2))    AS buy_val,
    CAST(f.sell_vol                         AS bigint)           AS sell_vol,
    CAST(f.sell_val                         AS decimal(23,2))    AS sell_val,
    CAST(f.src_stm_code                     AS string)           AS src_stm_code,
    CAST(f.order_matching_vol               AS bigint)           AS order_matching_vol,
    CAST(f.order_matching_val               AS decimal(23,2))    AS order_matching_val,
    CAST(f.negotiated_trade_vol             AS bigint)           AS negotiated_trade_vol,
    CAST(f.negotiated_trade_val             AS decimal(23,2))    AS negotiated_trade_val,
    CAST(f.derivative_term                  AS string)           AS derivative_term,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)        AS cdr_dt,
    CAST(cal.year                           AS bigint)           AS year,
    CAST(cal.quarter                        AS bigint)           AS quarter,
    CAST(cal.month                          AS bigint)           AS month,
    CAST(cal.day_of_week                    AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                     AS string)           AS is_weekend,
    CAST(cal.holiday_flag                   AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                AS string)           AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT (atm_security_trading_snapshot, all floor_code)
    CAST(sts.ticker_symbol                  AS string)           AS symbol,
    CAST(sts.full_nm                        AS string)           AS security_full_nm,
    CAST(sts.floor_code                     AS string)           AS floor_code,
    CAST(sts.stock_tp_code                  AS string)           AS stock_tp_code,
    CAST(sts.stock_tp_nm                    AS string)           AS stock_tp_nm,
    CAST(sts.underlying_symbol              AS string)           AS underlying_symbol,
    CAST(sts.isin_code                      AS string)           AS isin_code,
    CAST(sts.issuer_nm                      AS string)           AS issuer_nm,
    CAST(sts.listed_share_count             AS bigint)           AS listed_share_count,
    CAST(sts.first_trading_dt               AS date)             AS first_trading_dt,
    CAST(sts.last_trading_dt                AS date)             AS last_trading_dt,
    CAST(sts.issue_dt                       AS date)             AS issue_dt,
    CAST(sts.maturity_dt                    AS date)             AS maturity_dt,
    CAST(sts.fund_tp_code                   AS string)           AS fund_tp_code,
    CAST(sts.covered_warrant_tp_code        AS string)           AS covered_warrant_tp_code,
    CAST(sts.exercise_price                 AS decimal(23,2))    AS exercise_price,
    CAST(sts.exercise_ratio                 AS string)           AS exercise_ratio,
    CAST(sts.exercise_style_code            AS string)           AS exercise_style_code,
    CAST(sts.put_or_call_code               AS string)           AS put_or_call_code,
    CAST(sts.contract_multiplier            AS string)           AS contract_multiplier,
    CAST(sts.maturity_month_year            AS string)           AS maturity_month_year,
    CAST(sts.coupon_rate                    AS decimal(8,5))     AS coupon_rate,
    CAST(sts.yield                          AS decimal(8,5))     AS yield,
    CAST(sts.open_price                     AS decimal(23,2))    AS open_price,
    CAST(sts.high_price                     AS decimal(23,2))    AS high_price,
    CAST(sts.low_price                      AS decimal(23,2))    AS low_price,
    CAST(sts.ceiling_price                  AS decimal(23,2))    AS ceiling_price,
    CAST(sts.floor_price                    AS decimal(23,2))    AS floor_price,
    CAST(sts.reference_price                AS decimal(23,2))    AS reference_price,
    CAST(sts.close_price                    AS decimal(23,2))    AS close_price,
    CAST(sts.price_change                   AS decimal(23,2))    AS price_change,
    CAST(sts.product_group_id               AS string)           AS product_group_id,
    CAST(sts.product_id                     AS string)           AS product_id,
    CAST(sts.src_stm_code                   AS string)           AS sts_dim_src_stm_code,

    -- From: INDUSTRY DIMENSION
    CAST(ind.industry_code                  AS string)           AS industry_code,
    CAST(ind.industry_nm                    AS string)           AS industry_nm

FROM {{ ref('dtm_fct_investor_group_trading_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN sts
    ON  (f.market_id_code = 'STK'                     AND sts.ticker_symbol = f.security_symbol_code)
    OR  (f.market_id_code IN ('STX', 'UPX', 'DVX')   AND sts.isin_code     = f.security_symbol_code)
LEFT JOIN {{ ref('dtm_industry_dim') }}_hstr ind
    ON  ind.industry_dim_id = f.industry_dim_id
    AND ind.ds_snpst_dt     = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND ind.ds_rcrd_st      = 'ACTIVE'
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')

*--------------------------------------------------------------------*
*/
