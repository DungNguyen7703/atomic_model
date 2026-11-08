/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_proprietary_trading_index_snpst
* Program name: Fact Foreign Proprietary Trading Index Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		duxn			[REF] Chuan hoa phan tang CTE va doi ten CTE ngan gon, ro nghia (max 2 tu).
* 2026-11-07		claude			[UPD] Dong bo LLD 836eb5bb: ten cot Atomic securities_trade theo LLD (execution_val/vol ->
*									match_amt/match_quantity, security_symbol_code -> ticker_symbol, market_id_code ->
*									market_code); loc src_stm_code trade book theo LLD: HOSE_TRADE_BOOK, HNX_TRADE_BOOK.
*--------------------------------------------------------------------*
*/

WITH index_constituent AS (
    SELECT DISTINCT
        ticker_symbol,
        trading_dt,
        index_code
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND index_code IN ('HNX','HOSE','30','HNX30','100')
),

snapshot_raw AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        floor_code,
        ROW_NUMBER() OVER (
            PARTITION BY trading_dt, isin_code
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

constituent_dim AS (
    SELECT
        index_constituent_dim_id,
        index_code
    FROM {{ ref('dtm_index_constituent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_CSIDXINFOR'
),

trade_raw AS (
    SELECT
        trade_dt,
        ticker_symbol,
        match_quantity,
        match_amt,
        board_tp_code,
        buy_account_nbr,
        sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code IN ('HOSE_TRADE_BOOK','HNX_TRADE_BOOK')
        AND market_code IN ('STK','STX','UPX')
),

market_raw AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val,
        ROW_NUMBER() OVER (
            PARTITION BY market_code
            ORDER BY index_time DESC) 
        AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND market_code IN ('HOSE','HNX','UPCOM','30','HNX30','100')
),

trading_snapshot AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt
    FROM snapshot_raw
    WHERE rn = 1
        AND floor_code IN ('02','04','10')
),

market_index AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val
    FROM market_raw
    WHERE rn = 1
),

trade_index AS (
    SELECT
        trade_raw.trade_dt,
        index_constituent.index_code,
        trade_raw.match_quantity,
        trade_raw.match_amt,
        trade_raw.board_tp_code,
        trade_raw.buy_account_nbr,
        trade_raw.sell_account_nbr
    FROM trade_raw
    INNER JOIN trading_snapshot
        ON  trading_snapshot.trading_dt = trade_raw.trade_dt
        AND trade_raw.ticker_symbol IN (trading_snapshot.ticker_symbol, trading_snapshot.isin_code)
    INNER JOIN index_constituent
        ON  index_constituent.ticker_symbol = trading_snapshot.ticker_symbol
        AND index_constituent.trading_dt = trade_raw.trade_dt
),

trade_summary AS (
    SELECT
        trade_dt,
        index_code,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_total_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_total_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_total_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_total_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_negotiated_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_negotiated_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_negotiated_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_negotiated_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_matched_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_matched_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_matched_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_matched_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity
                 ELSE 0 END) AS proprietary_total_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity
                 ELSE 0 END) AS proprietary_total_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt
                 ELSE 0 END) AS proprietary_total_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt
                 ELSE 0 END) AS proprietary_total_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_quantity 
                 ELSE 0 END) AS proprietary_negotiated_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_quantity 
                 ELSE 0 END) AS proprietary_negotiated_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_amt 
                 ELSE 0 END) AS proprietary_negotiated_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN match_amt 
                 ELSE 0 END) AS proprietary_negotiated_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS proprietary_matched_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS proprietary_matched_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_amt 
                 ELSE 0 END) AS proprietary_matched_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN match_amt 
                 ELSE 0 END) AS proprietary_matched_sell_val
    FROM trade_index
    GROUP BY
        trade_dt,
        index_code
)

SELECT
    CAST(date_format(market_index.trading_dt, 'yyyyMMdd') AS string)             AS snpst_dt_dim_id,
    CAST(constituent_dim.index_constituent_dim_id AS string)                     AS index_constituent_dim_id,
    CAST(market_index.market_index_val AS decimal(23,2))                         AS market_index_val,
    CAST(trade_summary.foreign_investor_total_buy_vol AS int)                    AS foreign_investor_total_buy_vol,
    CAST(trade_summary.foreign_investor_total_sell_vol AS int)                   AS foreign_investor_total_sell_vol,
    CAST(trade_summary.foreign_investor_total_buy_val AS decimal(23,2))          AS foreign_investor_total_buy_val,
    CAST(trade_summary.foreign_investor_total_sell_val AS decimal(23,2))         AS foreign_investor_total_sell_val,
    CAST(trade_summary.foreign_investor_negotiated_buy_vol AS int)               AS foreign_investor_negotiated_buy_vol,
    CAST(trade_summary.foreign_investor_negotiated_sell_vol AS int)              AS foreign_investor_negotiated_sell_vol,
    CAST(trade_summary.foreign_investor_negotiated_buy_val AS decimal(23,2))     AS foreign_investor_negotiated_buy_val,
    CAST(trade_summary.foreign_investor_negotiated_sell_val AS decimal(23,2))    AS foreign_investor_negotiated_sell_val,
    CAST(trade_summary.foreign_investor_matched_buy_vol AS int)                  AS foreign_investor_matched_buy_vol,
    CAST(trade_summary.foreign_investor_matched_sell_vol AS int)                 AS foreign_investor_matched_sell_vol,
    CAST(trade_summary.foreign_investor_matched_buy_val AS decimal(23,2))        AS foreign_investor_matched_buy_val,
    CAST(trade_summary.foreign_investor_matched_sell_val AS decimal(23,2))       AS foreign_investor_matched_sell_val,
    CAST(trade_summary.proprietary_total_buy_vol AS int)                         AS proprietary_total_buy_vol,
    CAST(trade_summary.proprietary_total_sell_vol AS int)                        AS proprietary_total_sell_vol,
    CAST(trade_summary.proprietary_total_buy_val AS decimal(23,2))               AS proprietary_total_buy_val,
    CAST(trade_summary.proprietary_total_sell_val AS decimal(23,2))              AS proprietary_total_sell_val,
    CAST(trade_summary.proprietary_negotiated_buy_vol AS int)                    AS proprietary_negotiated_buy_vol,
    CAST(trade_summary.proprietary_negotiated_sell_vol AS int)                   AS proprietary_negotiated_sell_vol,
    CAST(trade_summary.proprietary_negotiated_buy_val AS decimal(23,2))          AS proprietary_negotiated_buy_val,
    CAST(trade_summary.proprietary_negotiated_sell_val AS decimal(23,2))         AS proprietary_negotiated_sell_val,
    CAST(trade_summary.proprietary_matched_buy_vol AS int)                       AS proprietary_matched_buy_vol,
    CAST(trade_summary.proprietary_matched_sell_vol AS int)                      AS proprietary_matched_sell_vol,
    CAST(trade_summary.proprietary_matched_buy_val AS decimal(23,2))             AS proprietary_matched_buy_val,
    CAST(trade_summary.proprietary_matched_sell_val AS decimal(23,2))            AS proprietary_matched_sell_val,
    CAST('ORDERTRADE_TRADE_BOOK_HOSE_HNX' AS string)                             AS src_stm_code
FROM market_index
LEFT JOIN trade_summary
    ON trade_summary.index_code = market_index.market_code
JOIN constituent_dim
    ON constituent_dim.index_code = market_index.market_code

