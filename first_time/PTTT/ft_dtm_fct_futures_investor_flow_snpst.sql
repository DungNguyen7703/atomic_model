-- [FIRST-TIME] ft_dtm_fct_futures_investor_flow_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_futures_investor_flow_snpst (config ft_target='fct_futures_investor_flow_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_futures_investor_flow_snpst
* Program name: Fact Futures Investor Flow Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_futures_investor_flow_snpst:
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_securities_trade), BO loc theo etl_date de nap toan bo lich su 1 lan.
*									- append: ds_snpst_dt = trading_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- Dedupe ban tin cuoi ngay da theo (ticker_symbol, ds_snpst_dt); gom so lenh DVX da theo (trade_dt, security_symbol_code); noi theo ISIN va ngay -> khong can doi them khoa ngay.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH fu_raw AS (
    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , underlying_symbol
        , stock_tp_code
        , floor_code
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fu_symbols AS (
    SELECT
        trading_dt
        , symbol
        , isin_code
        , underlying_symbol
    FROM fu_raw
    WHERE rn = 1
        AND stock_tp_code = '4'
        AND floor_code = '03'
),

flow AS (
    SELECT
        trade_dt
        , security_symbol_code
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_vol ELSE 0 END) AS foreign_buy_vol
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_vol ELSE 0 END) AS foreign_sell_vol
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('A','E','P') THEN execution_vol ELSE 0 END) AS proprietary_buy_vol
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('A','E','P') THEN execution_vol ELSE 0 END) AS proprietary_sell_vol
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code = 'DVX'
    GROUP BY
        trade_dt
        , security_symbol_code
),

joined AS (
    SELECT
        fu_symbols.trading_dt
        , fu_symbols.symbol
        , fu_symbols.underlying_symbol
        , COALESCE(flow.foreign_buy_vol, 0)      AS foreign_buy_vol
        , COALESCE(flow.foreign_sell_vol, 0)     AS foreign_sell_vol
        , COALESCE(flow.proprietary_buy_vol, 0)  AS proprietary_buy_vol
        , COALESCE(flow.proprietary_sell_vol, 0) AS proprietary_sell_vol
    FROM fu_symbols
    LEFT JOIN flow
        ON flow.security_symbol_code = fu_symbols.isin_code
        AND flow.trade_dt = fu_symbols.trading_dt
)

SELECT
    CAST(date_format(joined.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(joined.symbol AS string)                              AS security_symbol_code,
    CAST(joined.underlying_symbol AS string)                   AS underlying_symbol,
    CAST(joined.foreign_buy_vol AS decimal(23,2))              AS foreign_buy_vol,
    CAST(joined.foreign_sell_vol AS decimal(23,2))             AS foreign_sell_vol,
    CAST(joined.foreign_buy_vol - joined.foreign_sell_vol AS decimal(23,2))      AS foreign_net_vol,
    CAST(joined.proprietary_buy_vol AS decimal(23,2))          AS proprietary_buy_vol,
    CAST(joined.proprietary_sell_vol AS decimal(23,2))         AS proprietary_sell_vol,
    CAST(joined.proprietary_buy_vol - joined.proprietary_sell_vol AS decimal(23,2)) AS proprietary_net_vol,
    CAST(joined.trading_dt AS date)                            AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM joined
