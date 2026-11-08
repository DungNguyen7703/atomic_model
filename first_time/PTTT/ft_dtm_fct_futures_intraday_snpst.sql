-- [FIRST-TIME] ft_dtm_fct_futures_intraday_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_futures_intraday_snpst (config ft_target='fct_futures_intraday_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_futures_intraday_snpst
* Program name: Fact Futures Intraday Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_futures_intraday_snpst:
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_securities_trade / ft_atm_end_of_day_open_interest),
*									  BO cac cua so ngay (BETWEEN etl_date-80..etl_date, rpt_dt = etl_date) va BO WHERE trading_dt = etl_date cuoi cung
*									  de nap toan bo lich su trong 1 lan.
*									- append: ds_snpst_dt = trading_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- close_price_previous_day: phien lien truoc theo TUNG ngay (LAG tren cac ngay co du lieu cua cung co so), giu rang buoc 15 ngay lich nhu daily.
*									- total_trading_vol_matched_average_50_days: cua so 50 dong theo ma, giong daily.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr_snpst_hist_raw AS (
    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , underlying_symbol
        , maturity_month_year
        , close_price
        , reference_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 80) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE stock_tp_code = '4'
        AND floor_code = '03'
),

fut_snpst AS (
    SELECT trading_dt, symbol, isin_code, underlying_symbol, maturity_month_year, close_price, reference_price
    FROM se_tr_snpst_hist_raw
    WHERE rn = 1
),

tr_hist AS (
    SELECT
        trade_dt
        , security_symbol_code
        , SUM(execution_vol) AS vol
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 80) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code = 'DVX'
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
    GROUP BY trade_dt, security_symbol_code
),

tr_by_contract AS (
    SELECT
        fut_snpst.trading_dt
        , fut_snpst.symbol
        , SUM(tr_hist.vol) AS total_trading_vol_matched
    FROM fut_snpst
    INNER JOIN tr_hist
        ON tr_hist.trade_dt = fut_snpst.trading_dt
        AND tr_hist.security_symbol_code = fut_snpst.isin_code
    GROUP BY fut_snpst.trading_dt, fut_snpst.symbol
),

joined_hist AS (
    SELECT
        fut_snpst.trading_dt
        , fut_snpst.symbol
        , fut_snpst.underlying_symbol
        , fut_snpst.maturity_month_year
        , fut_snpst.close_price
        , fut_snpst.reference_price
        , COALESCE(tr_by_contract.total_trading_vol_matched, 0) AS total_trading_vol_matched
    FROM fut_snpst
    LEFT JOIN tr_by_contract
        ON tr_by_contract.trading_dt = fut_snpst.trading_dt
        AND tr_by_contract.symbol = fut_snpst.symbol
),

windowed AS (
    SELECT
        joined_hist.*
        , AVG(joined_hist.total_trading_vol_matched) OVER (
            PARTITION BY joined_hist.symbol
            ORDER BY joined_hist.trading_dt
            ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS total_trading_vol_matched_average_50_days
    FROM joined_hist
),

-- [BACKFILL-UAT-NEW] Phien lien truoc theo TUNG ngay: LAG tren cac ngay co du lieu cua cung co so; chi giu neu cach <= 15 ngay lich (giong cua so cua daily)
und_dates AS (
    SELECT DISTINCT underlying_symbol, trading_dt
    FROM fut_snpst
),

prev_session AS (
    SELECT
        underlying_symbol
        , trading_dt
        , LAG(trading_dt) OVER (PARTITION BY underlying_symbol ORDER BY trading_dt) AS prev_trading_dt
    FROM und_dates
),

prev_close AS (
    SELECT
        fut_snpst.symbol
        , prev_session.trading_dt
        , fut_snpst.close_price AS close_price_previous_day
    FROM fut_snpst
    INNER JOIN prev_session
        ON prev_session.underlying_symbol = fut_snpst.underlying_symbol
        AND prev_session.prev_trading_dt = fut_snpst.trading_dt
        AND prev_session.prev_trading_dt >= date_sub(prev_session.trading_dt, 15)
),

eo_oi_all AS (
    SELECT
        ticker_symbol
        , rpt_dt
        , open_interest_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, rpt_dt ORDER BY ds_snpst_dt DESC) AS rn
    FROM {{ ft_ref('ft_atm_end_of_day_open_interest') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE rpt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

eo_oi AS (
    SELECT ticker_symbol, rpt_dt, open_interest_quantity
    FROM eo_oi_all
    WHERE rn = 1
)

SELECT
    CAST(date_format(windowed.trading_dt, 'yyyyMMdd') AS string)                     AS snpst_dt_dim_id,
    CAST(windowed.symbol AS string)                                                   AS security_symbol_code,
    CAST(windowed.underlying_symbol AS string)                                        AS underlying_symbol,
    CAST(windowed.maturity_month_year AS string)                                      AS maturity_month_year,
    CAST(windowed.close_price AS decimal(23,2))                                       AS close_price,
    CAST(windowed.reference_price AS decimal(23,2))                                   AS reference_price,
    CAST(prev_close.close_price_previous_day AS decimal(23,2))                        AS close_price_previous_day,
    CAST(
        (windowed.close_price - windowed.reference_price)
        / NULLIF(windowed.reference_price, 0) * 100
    AS decimal(5,2))                                                                  AS price_change_percentage,
    CAST(windowed.total_trading_vol_matched AS decimal(23,2))                         AS total_trading_vol_matched,
    CAST(windowed.total_trading_vol_matched_average_50_days AS decimal(23,2))         AS total_trading_vol_matched_average_50_days,
    CAST(
        windowed.total_trading_vol_matched
        / NULLIF(windowed.total_trading_vol_matched_average_50_days, 0) * 100
    AS decimal(5,2))                                                                  AS liquidity_spike_ratio,
    CAST(eo_oi.open_interest_quantity AS bigint)                                      AS open_interest_quantity,
    CAST(windowed.trading_dt AS date)                                                 AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM windowed
LEFT JOIN eo_oi
    ON eo_oi.ticker_symbol = windowed.symbol
    AND eo_oi.rpt_dt = windowed.trading_dt
LEFT JOIN prev_close
    ON prev_close.symbol = windowed.symbol
    AND prev_close.trading_dt = windowed.trading_dt   -- [BACKFILL-UAT-NEW] noi theo ngay
-- [BACKFILL-UAT-ORIG] WHERE windowed.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
