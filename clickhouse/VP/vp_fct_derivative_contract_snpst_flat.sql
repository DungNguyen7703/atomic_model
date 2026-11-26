/*
*--------------------------------------------------------------------*
* Program code: vp_fct_derivative_contract_snpst_flat
* Program name: VP Fct Derivative Contract Snapshot Flat
* Created by: huy.pham
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-29      huy.pham        [MOI] Flat table ClickHouse: Fact Derivative Contract
*                                 Snapshot x Calendar Date Dim x Security Trading Snapshot
*                                 Dim. Grain = 1 dong / ma hop dong / ngay GD.
*                                 f.close_price doi thanh contract_close_price de tranh
*                                 trung ten voi sts_dim.close_price.
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
* 2026-11-07      huy.pham        [SUA] Bo qua dtm_security_trading_snpst_dim_hstr —
*                                 dim chua du lat cat ngay lich su. Thay bang sts_all/sts
*                                 tu atm_security_trading_snapshot (floor_code='03'),
*                                 dedup theo (ticker_symbol, trading_dt), JOIN theo
*                                 ticker_symbol va trading_dt = snpst_dt_dim_id.
*                                 Bo WHERE filter etl_date de lay toan bo lich su.
*--------------------------------------------------------------------*
*/

WITH sts_all AS (
    SELECT
        ticker_symbol,
        trading_dt,
        full_nm,
        floor_code,
        stock_tp_code,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        fund_tp_code,
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
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code = '03'
),

sts AS (
    SELECT * FROM sts_all WHERE rn = 1
)

SELECT /*+ BROADCAST(cal) */
    -- From: FCT_DERIVATIVE_CONTRACT_SNPST
    CAST(f.derivative_contract_snpst_id    AS string)           AS derivative_contract_snpst_id,
    CAST(f.snpst_dt_dim_id                 AS string)           AS snpst_dt_dim_id,
    CAST(f.security_trading_snpst_dim_id   AS string)           AS security_trading_snpst_dim_id,
    CAST(f.ticker_symbol                   AS string)           AS ticker_symbol,
    CAST(f.open_interest_quantity          AS bigint)           AS open_interest_quantity,
    CAST(f.close_price                     AS decimal(23,2))    AS contract_close_price,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)       AS cdr_dt,
    CAST(cal.year                          AS bigint)           AS year,
    CAST(cal.quarter                       AS bigint)           AS quarter,
    CAST(cal.month                         AS bigint)           AS month,
    CAST(cal.day_of_week                   AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                    AS string)           AS is_weekend,
    CAST(cal.holiday_flag                  AS string)           AS holiday_flag,
    CAST(cal.is_trading_date               AS string)           AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT (atm_security_trading_snapshot, floor_code='03')
    CAST(sts.ticker_symbol                 AS string)           AS symbol,
    CAST(sts.full_nm                       AS string)           AS security_full_nm,
    CAST(sts.floor_code                    AS string)           AS floor_code,
    CAST(sts.stock_tp_code                 AS string)           AS stock_tp_code,
    CAST('Phái sinh'                       AS string)           AS stock_tp_nm,
    CAST(sts.underlying_symbol             AS string)           AS underlying_symbol,
    CAST(sts.isin_code                     AS string)           AS isin_code,
    CAST(sts.issuer_nm                     AS string)           AS issuer_nm,
    CAST(sts.listed_share_count            AS bigint)           AS listed_share_count,
    CAST(sts.first_trading_dt              AS date)             AS first_trading_dt,
    CAST(sts.last_trading_dt               AS date)             AS last_trading_dt,
    CAST(sts.issue_dt                      AS date)             AS issue_dt,
    CAST(sts.maturity_dt                   AS date)             AS maturity_dt,
    CAST(sts.fund_tp_code                  AS string)           AS fund_tp_code,
    CAST(sts.covered_warrant_tp_code       AS string)           AS covered_warrant_tp_code,
    CAST(sts.exercise_price                AS decimal(23,2))    AS exercise_price,
    CAST(sts.exercise_ratio                AS string)           AS exercise_ratio,
    CAST(sts.exercise_style_code           AS string)           AS exercise_style_code,
    CAST(sts.put_or_call_code              AS string)           AS put_or_call_code,
    CAST(sts.contract_multiplier           AS string)           AS contract_multiplier,
    CAST(sts.maturity_month_year           AS string)           AS maturity_month_year,
    CAST(sts.coupon_rate                   AS decimal(8,5))     AS coupon_rate,
    CAST(sts.yield                         AS decimal(8,5))     AS yield,
    CAST(sts.open_price                    AS decimal(23,2))    AS open_price,
    CAST(sts.high_price                    AS decimal(23,2))    AS high_price,
    CAST(sts.low_price                     AS decimal(23,2))    AS low_price,
    CAST(sts.ceiling_price                 AS decimal(23,2))    AS ceiling_price,
    CAST(sts.floor_price                   AS decimal(23,2))    AS floor_price,
    CAST(sts.reference_price               AS decimal(23,2))    AS reference_price,
    CAST(sts.close_price                   AS decimal(23,2))    AS close_price,
    CAST(sts.price_change                  AS decimal(23,2))    AS price_change,
    CAST(sts.product_group_id              AS string)           AS product_group_id,
    CAST(sts.src_stm_code                  AS string)           AS sts_dim_src_stm_code

FROM {{ ref('dtm_fct_derivative_contract_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN sts
    ON  sts.ticker_symbol = f.ticker_symbol
    AND sts.trading_dt    = to_date(f.snpst_dt_dim_id, 'yyyyMMdd')
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
        trading_dt,
        full_nm,
        floor_code,
        stock_tp_code,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
        fund_tp_code,
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
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code = '03'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sts AS (
    SELECT * FROM sts_all WHERE rn = 1
)

SELECT
    -- From: FCT_DERIVATIVE_CONTRACT_SNPST
    CAST(f.derivative_contract_snpst_id    AS string)           AS derivative_contract_snpst_id,
    CAST(f.snpst_dt_dim_id                 AS string)           AS snpst_dt_dim_id,
    CAST(f.security_trading_snpst_dim_id   AS string)           AS security_trading_snpst_dim_id,
    CAST(f.ticker_symbol                   AS string)           AS ticker_symbol,
    CAST(f.open_interest_quantity          AS bigint)           AS open_interest_quantity,
    CAST(f.close_price                     AS decimal(23,2))    AS contract_close_price,

    -- From: CALENDAR DATE DIMENSION
    CAST(to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS date)       AS cdr_dt,
    CAST(cal.year                          AS bigint)           AS year,
    CAST(cal.quarter                       AS bigint)           AS quarter,
    CAST(cal.month                         AS bigint)           AS month,
    CAST(cal.day_of_week                   AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                    AS string)           AS is_weekend,
    CAST(cal.holiday_flag                  AS string)           AS holiday_flag,
    CAST(cal.is_trading_date               AS string)           AS is_trading_date,

    -- From: SECURITY TRADING SNAPSHOT (atm_security_trading_snapshot, floor_code='03')
    CAST(sts.ticker_symbol                 AS string)           AS symbol,
    CAST(sts.full_nm                       AS string)           AS security_full_nm,
    CAST(sts.floor_code                    AS string)           AS floor_code,
    CAST(sts.stock_tp_code                 AS string)           AS stock_tp_code,
    CAST('Phái sinh'                       AS string)           AS stock_tp_nm,
    CAST(sts.underlying_symbol             AS string)           AS underlying_symbol,
    CAST(sts.isin_code                     AS string)           AS isin_code,
    CAST(sts.issuer_nm                     AS string)           AS issuer_nm,
    CAST(sts.listed_share_count            AS bigint)           AS listed_share_count,
    CAST(sts.first_trading_dt              AS date)             AS first_trading_dt,
    CAST(sts.last_trading_dt               AS date)             AS last_trading_dt,
    CAST(sts.issue_dt                      AS date)             AS issue_dt,
    CAST(sts.maturity_dt                   AS date)             AS maturity_dt,
    CAST(sts.fund_tp_code                  AS string)           AS fund_tp_code,
    CAST(sts.covered_warrant_tp_code       AS string)           AS covered_warrant_tp_code,
    CAST(sts.exercise_price                AS decimal(23,2))    AS exercise_price,
    CAST(sts.exercise_ratio                AS string)           AS exercise_ratio,
    CAST(sts.exercise_style_code           AS string)           AS exercise_style_code,
    CAST(sts.put_or_call_code              AS string)           AS put_or_call_code,
    CAST(sts.contract_multiplier           AS string)           AS contract_multiplier,
    CAST(sts.maturity_month_year           AS string)           AS maturity_month_year,
    CAST(sts.coupon_rate                   AS decimal(8,5))     AS coupon_rate,
    CAST(sts.yield                         AS decimal(8,5))     AS yield,
    CAST(sts.open_price                    AS decimal(23,2))    AS open_price,
    CAST(sts.high_price                    AS decimal(23,2))    AS high_price,
    CAST(sts.low_price                     AS decimal(23,2))    AS low_price,
    CAST(sts.ceiling_price                 AS decimal(23,2))    AS ceiling_price,
    CAST(sts.floor_price                   AS decimal(23,2))    AS floor_price,
    CAST(sts.reference_price               AS decimal(23,2))    AS reference_price,
    CAST(sts.close_price                   AS decimal(23,2))    AS close_price,
    CAST(sts.price_change                  AS decimal(23,2))    AS price_change,
    CAST(sts.product_group_id              AS string)           AS product_group_id,
    CAST(sts.src_stm_code                  AS string)           AS sts_dim_src_stm_code

FROM {{ ref('dtm_fct_derivative_contract_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN sts
    ON  sts.ticker_symbol = f.ticker_symbol
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')

*--------------------------------------------------------------------*
*/
