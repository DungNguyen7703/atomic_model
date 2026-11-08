/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_trading_snpst
* Program name: Fact Market Trading Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		claude			[UPD] Dong bo LLD 5ebc3276 (BA BM030a cap nhat 27/10): cong theo thanh phan chi so tai ngay
*									giao dich - securities_trade noi atm_security_trading_snapshot (ban ghi cuoi phien moi
*									(trading_dt, isin_code), floor_code IN 02/04/10) roi noi atm_index_constituent_snapshot theo
*									ticker_symbol + trading_dt; chi lay index_code HOSE/HNX/30/HNX30/100 (UPCOM chua co so);
*									khop lenh bo board G4 (G1,G2,G3,G7,G8); thoa thuan chi T1,T2,T3,R1 (bo T4,T6 - da thuoc lo le);
*									doi cot nguon index_constituent: symbol -> ticker_symbol.
* 2026-11-04		duxn			[REF] Chuan hoa phan tang CTE va doi ten CTE ngan gon, ro nghia (max 2 tu).
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
        AND index_code IN ('HOSE','HNX','30','HNX30','100')
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
        match_amt,
        match_quantity,
        board_tp_code
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
        AND market_code IN ('HOSE','HNX','UPCOM','30','HNX30','100')
        AND src_stm_code = 'MDDS_JAD_MARKETINFOR'
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
        trade_raw.match_amt,
        trade_raw.match_quantity,
        trade_raw.board_tp_code
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
        SUM(match_amt) AS total_trading_val,
        SUM(match_quantity) AS total_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') THEN match_amt 
                 ELSE 0 END) AS matched_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS matched_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') THEN match_amt 
                 ELSE 0 END) AS negotiated_trading_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') THEN match_quantity 
                 ELSE 0 END) AS negotiated_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN match_amt 
                 ELSE 0 END) AS odd_lot_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN match_quantity 
                 ELSE 0 END) AS odd_lot_trading_vol
    FROM trade_index
    GROUP BY 
        trade_dt, 
        index_code
)

SELECT
    CAST(date_format(market_index.trading_dt, 'yyyyMMdd') AS string)     AS snpst_dt_dim_id,
    CAST(constituent_dim.index_constituent_dim_id AS string)             AS index_constituent_dim_id,
    CAST(market_index.market_index_val AS decimal(23,2))                 AS market_index_val,
    CAST(trade_summary.total_trading_val AS decimal(23,2))               AS total_trading_val,
    CAST(trade_summary.total_trading_vol AS int)                         AS total_trading_vol,
    CAST(trade_summary.matched_trading_val AS decimal(23,2))             AS matched_trading_val,
    CAST(trade_summary.matched_trading_vol AS int)                       AS matched_trading_vol,
    CAST(trade_summary.negotiated_trading_val AS decimal(23,2))          AS negotiated_trading_val,
    CAST(trade_summary.negotiated_trading_vol AS int)                    AS negotiated_trading_vol,
    CAST(trade_summary.odd_lot_trading_val AS decimal(23,2))             AS odd_lot_trading_val,
    CAST(trade_summary.odd_lot_trading_vol AS int)                       AS odd_lot_trading_vol,
    CAST('ORDERTRADE_TRADE_BOOK_HOSE_HNX' AS string)                     AS src_stm_code
FROM market_index
LEFT JOIN trade_summary
    ON trade_summary.index_code = market_index.market_code
LEFT JOIN constituent_dim
    ON constituent_dim.index_code = market_index.market_code
