/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_security_trading_detail_snpst
* Program name: Fact Security Trading Detail Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		duxn				BA BM035 12/08/2026: chi hien ma co giao dich -> order_summary va
*									trade_summary doi LEFT JOIN thanh INNER JOIN (khop query BA: ma phai
*									co ca trade book va order book).
* 2026-11-07		duxn				Sua lech BA: (1) gia TB = LEAD(vol_weighted_average_price) (vwap) thay averageprice;
*									(2) order_raw quy ma HNX (side 1/2, replace_cancel 2/3) ve S/B, M/C nhu HOSE;
*									quy tac tu huy chi ap dung HOSE.
* 2026-11-07		claude			[UPD] Dong bo LLD 836eb5bb: ten cot Atomic theo LLD - securities_trade (execution_vol/val ->
*									match_quantity/match_amt, security_symbol_code -> ticker_symbol); securities_order
*									(security_symbol_code -> ticker_symbol, broker_id -> member_code, side_ind -> side,
*									order_vol -> order_quantity, auto_cancel_reason_code -> automated_cancel_tp_code);
*									foreign_ownership: giu make_date(rpt_year, rpt_month, rpt_day).
*--------------------------------------------------------------------*
*/

WITH snapshot_window AS (
    -- Cua so :etl_date .. :etl_date + 15 ngay de tim phien giao dich KE TIEP (LEAD)
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        symbol_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        vol_weighted_average_price,
        high_price,
        low_price,
        contract_multiplier,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY trading_dt, ticker_symbol
            ORDER BY trading_time DESC, sequence DESC)
        AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt BETWEEN to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                         AND date_add(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 15)
        AND floor_code IN ('02','04','03','10')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

snapshot_dim AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

order_raw AS (
    SELECT
        trade_dt,
        ticker_symbol,
        member_code,
        securities_order_code,
        original_order_code,
        src_stm_code,
        -- HNX: replace_cancel 2=sua, 3=huy -> quy ve M/C nhu HOSE
        CASE WHEN src_stm_code = 'ORDERTRADE_ORDER_BOOK_HNX' THEN
                 CASE order_action_tp_code WHEN '2' THEN 'M' WHEN '3' THEN 'C' ELSE order_action_tp_code END
             ELSE order_action_tp_code END AS order_action_tp_code,
        automated_cancel_tp_code,
        -- HNX: sell_buy_classification_code 1=Sell, 2=Buy -> quy ve S/B nhu HOSE
        CASE WHEN src_stm_code = 'ORDERTRADE_ORDER_BOOK_HNX' THEN
                 CASE side WHEN '2' THEN 'B' WHEN '1' THEN 'S' END
             ELSE side END AS side,
        order_quantity
    FROM {{ ref('atm_securities_order') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
),

foreign_ownership AS (
    SELECT
        ticker_symbol,
        make_date(rpt_year, rpt_month, rpt_day) AS rpt_dt,
        max_foreign_ownership_ratio,
        remaining_foreign_holding_quantity,
        total_issued_share_quantity
    FROM {{ ref('atm_foreign_ownership_information') }}
    WHERE make_date(rpt_year, rpt_month, rpt_day) = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'
),

snapshot_lead AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        symbol_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        high_price,
        low_price,
        contract_multiplier,
        src_stm_code,
        LEAD(vol_weighted_average_price) OVER (
            PARTITION BY isin_code
            ORDER BY trading_dt)
        AS next_average_price
    FROM snapshot_window
    WHERE rn = 1
),

trading_snapshot AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        symbol_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        CASE WHEN next_average_price = 0 THEN reference_price
             ELSE next_average_price END AS average_price,
        high_price,
        low_price,
        CAST(COALESCE(contract_multiplier, 1) AS decimal(23,4)) AS contract_multiplier,
        src_stm_code
    FROM snapshot_lead
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- Lenh bi sua/huy thay the: ton tai ban ghi KHAC tro original_order_code ve lenh nay
order_replaced AS (
    SELECT DISTINCT
        trade_dt,
        ticker_symbol,
        member_code,
        original_order_code AS securities_order_code
    FROM order_raw
    WHERE order_action_tp_code IN ('M','C')
        AND original_order_code IS NOT NULL
        AND original_order_code <> securities_order_code
),

-- KL cua lenh goc (dung cho ban ghi huy tay)
order_orig AS (
    SELECT
        trade_dt,
        ticker_symbol,
        member_code,
        securities_order_code,
        MAX(order_quantity) AS order_quantity
    FROM order_raw
    GROUP BY
        trade_dt,
        ticker_symbol,
        member_code,
        securities_order_code
),

order_final AS (
    SELECT
        o.trade_dt,
        o.ticker_symbol,
        o.side,
        o.order_action_tp_code,
        o.order_quantity,
        oo.order_quantity AS orig_order_vol
    FROM order_raw o
    LEFT JOIN order_replaced r
        ON r.trade_dt = o.trade_dt
        AND r.ticker_symbol = o.ticker_symbol
        AND r.member_code = o.member_code
        AND r.securities_order_code = o.securities_order_code
    LEFT JOIN order_orig oo
        ON oo.trade_dt = o.trade_dt
        AND oo.ticker_symbol = o.ticker_symbol
        AND oo.member_code = o.member_code
        AND oo.securities_order_code = o.original_order_code
    WHERE r.securities_order_code IS NULL
        -- HNX: ban ghi huy tu dong
        AND COALESCE(TRIM(o.automated_cancel_tp_code), '0') <> '1'
        -- HOSE: ban ghi tu huy (chi ap dung HOSE; HNX khong co quy tac nay trong query BA)
        AND NOT (o.src_stm_code = 'ORDERTRADE_ORDER_BOOK_HOSE'
                 AND o.order_action_tp_code = 'C'
                 AND COALESCE(o.original_order_code, '#') = o.securities_order_code)
),

order_agg AS (
    SELECT
        trade_dt,
        ticker_symbol,
        COUNT(CASE WHEN side = 'B' THEN 1 END) AS buy_order_cnt,
        SUM(CASE WHEN side = 'B' THEN
                 CASE WHEN order_action_tp_code = 'C' THEN orig_order_vol ELSE order_quantity END
            END)                                   AS buy_order_vol,
        COUNT(CASE WHEN side = 'S' THEN 1 END) AS sell_order_cnt,
        SUM(CASE WHEN side = 'S' THEN
                 CASE WHEN order_action_tp_code = 'C' THEN orig_order_vol ELSE order_quantity END
            END)                                   AS sell_order_vol
    FROM order_final
    GROUP BY
        trade_dt,
        ticker_symbol
),

trade_agg AS (
    SELECT
        trade_dt,
        ticker_symbol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') THEN match_quantity 
                 ELSE 0 END) AS matched_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') THEN match_amt 
                 ELSE 0 END) AS matched_trading_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') THEN match_quantity 
                 ELSE 0 END) AS negotiated_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') THEN match_amt 
                 ELSE 0 END) AS negotiated_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN match_quantity 
                 ELSE 0 END) AS odd_lot_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN match_amt 
                 ELSE 0 END) AS odd_lot_trading_val,
        SUM(match_quantity) AS total_trading_vol,
        SUM(match_amt) AS total_trading_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_total_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity    
                 ELSE 0 END) AS foreign_investor_total_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_total_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_total_sell_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_negotiated_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_negotiated_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_negotiated_buy_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_negotiated_sell_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_matched_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_matched_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_matched_buy_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_amt 
                 ELSE 0 END) AS foreign_investor_matched_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_total_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_total_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_total_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_total_sell_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_negotiated_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity
                 ELSE 0 END) AS proprietary_negotiated_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_negotiated_buy_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','R1') AND SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_negotiated_sell_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_matched_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_matched_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_matched_buy_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G7','G8') AND SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_amt 
                 ELSE 0 END) AS proprietary_matched_sell_val
    FROM trade_raw
    GROUP BY
        trade_dt,
        ticker_symbol
),

order_summary AS (
    SELECT
        trading_snapshot.ticker_symbol,
        SUM(order_agg.buy_order_cnt)  AS buy_order_cnt,
        SUM(order_agg.buy_order_vol)  AS buy_order_vol,
        SUM(order_agg.sell_order_cnt) AS sell_order_cnt,
        SUM(order_agg.sell_order_vol) AS sell_order_vol
    FROM trading_snapshot
    INNER JOIN order_agg
        ON order_agg.trade_dt = trading_snapshot.trading_dt
        AND order_agg.ticker_symbol IN (trading_snapshot.ticker_symbol, trading_snapshot.isin_code)
    GROUP BY
        trading_snapshot.ticker_symbol
),

trade_summary AS (
    SELECT
        trading_snapshot.ticker_symbol,
        SUM(trade_agg.matched_trading_vol)                                                         AS matched_trading_vol,
        SUM(trade_agg.matched_trading_val * trading_snapshot.contract_multiplier)                  AS matched_trading_val,
        SUM(trade_agg.negotiated_trading_vol)                                                      AS negotiated_trading_vol,
        SUM(trade_agg.negotiated_trading_val * trading_snapshot.contract_multiplier)               AS negotiated_trading_val,
        SUM(trade_agg.odd_lot_trading_vol)                                                         AS odd_lot_trading_vol,
        SUM(trade_agg.odd_lot_trading_val * trading_snapshot.contract_multiplier)                  AS odd_lot_trading_val,
        SUM(trade_agg.total_trading_vol)                                                           AS total_trading_vol,
        SUM(trade_agg.total_trading_val * trading_snapshot.contract_multiplier)                    AS total_trading_val,
        SUM(trade_agg.foreign_investor_total_buy_vol)                                              AS foreign_investor_total_buy_vol,
        SUM(trade_agg.foreign_investor_total_sell_vol)                                             AS foreign_investor_total_sell_vol,
        SUM(trade_agg.foreign_investor_total_buy_val * trading_snapshot.contract_multiplier)       AS foreign_investor_total_buy_val,
        SUM(trade_agg.foreign_investor_total_sell_val * trading_snapshot.contract_multiplier)      AS foreign_investor_total_sell_val,
        SUM(trade_agg.foreign_investor_negotiated_buy_vol)                                         AS foreign_investor_negotiated_buy_vol,
        SUM(trade_agg.foreign_investor_negotiated_sell_vol)                                        AS foreign_investor_negotiated_sell_vol,
        SUM(trade_agg.foreign_investor_negotiated_buy_val * trading_snapshot.contract_multiplier)  AS foreign_investor_negotiated_buy_val,
        SUM(trade_agg.foreign_investor_negotiated_sell_val * trading_snapshot.contract_multiplier) AS foreign_investor_negotiated_sell_val,
        SUM(trade_agg.foreign_investor_matched_buy_vol)                                            AS foreign_investor_matched_buy_vol,
        SUM(trade_agg.foreign_investor_matched_sell_vol)                                           AS foreign_investor_matched_sell_vol,
        SUM(trade_agg.foreign_investor_matched_buy_val * trading_snapshot.contract_multiplier)     AS foreign_investor_matched_buy_val,
        SUM(trade_agg.foreign_investor_matched_sell_val * trading_snapshot.contract_multiplier)    AS foreign_investor_matched_sell_val,
        SUM(trade_agg.proprietary_total_buy_vol)                                                   AS proprietary_total_buy_vol,
        SUM(trade_agg.proprietary_total_sell_vol)                                                  AS proprietary_total_sell_vol,
        SUM(trade_agg.proprietary_total_buy_val * trading_snapshot.contract_multiplier)            AS proprietary_total_buy_val,
        SUM(trade_agg.proprietary_total_sell_val * trading_snapshot.contract_multiplier)           AS proprietary_total_sell_val,
        SUM(trade_agg.proprietary_negotiated_buy_vol)                                              AS proprietary_negotiated_buy_vol,
        SUM(trade_agg.proprietary_negotiated_sell_vol)                                             AS proprietary_negotiated_sell_vol,
        SUM(trade_agg.proprietary_negotiated_buy_val * trading_snapshot.contract_multiplier)       AS proprietary_negotiated_buy_val,
        SUM(trade_agg.proprietary_negotiated_sell_val * trading_snapshot.contract_multiplier)      AS proprietary_negotiated_sell_val,
        SUM(trade_agg.proprietary_matched_buy_vol)                                                 AS proprietary_matched_buy_vol,
        SUM(trade_agg.proprietary_matched_sell_vol)                                                AS proprietary_matched_sell_vol,
        SUM(trade_agg.proprietary_matched_buy_val * trading_snapshot.contract_multiplier)          AS proprietary_matched_buy_val,
        SUM(trade_agg.proprietary_matched_sell_val * trading_snapshot.contract_multiplier)         AS proprietary_matched_sell_val
    FROM trading_snapshot
    INNER JOIN trade_agg
        ON trade_agg.trade_dt = trading_snapshot.trading_dt
        AND trade_agg.ticker_symbol IN (trading_snapshot.ticker_symbol, trading_snapshot.isin_code)
    GROUP BY
        trading_snapshot.ticker_symbol
)

SELECT
    CAST(date_format(trading_snapshot.trading_dt, 'yyyyMMdd') AS string)                AS snpst_dt_dim_id,
    CAST(snapshot_dim.security_trading_snpst_dim_id AS string)                          AS security_trading_snpst_dim_id,
    CAST(trading_snapshot.symbol_status_code AS string)                                 AS trading_status_code,
    CAST(trading_snapshot.reference_price AS decimal(23,2))                             AS reference_price,
    CAST(trading_snapshot.ceiling_price AS decimal(23,2))                               AS ceiling_price,
    CAST(trading_snapshot.floor_price AS decimal(23,2))                                 AS floor_price,
    CAST(trading_snapshot.close_price AS decimal(23,2))                                 AS close_price,
    CAST(trading_snapshot.average_price AS decimal(23,2))                               AS average_price,
    CAST(trading_snapshot.high_price AS decimal(23,2))                                  AS high_price,
    CAST(trading_snapshot.low_price AS decimal(23,2))                                   AS low_price,
    CAST(order_summary.buy_order_cnt AS int)                                            AS buy_order_cnt,
    CAST(order_summary.buy_order_vol AS bigint)                                         AS buy_order_vol,
    CAST(order_summary.sell_order_cnt AS int)                                           AS sell_order_cnt,
    CAST(order_summary.sell_order_vol AS bigint)                                        AS sell_order_vol,
    CAST(trade_summary.matched_trading_vol AS bigint)                                   AS matched_trading_vol,
    CAST(trade_summary.matched_trading_val AS decimal(23,2))                            AS matched_trading_val,
    CAST(trade_summary.negotiated_trading_vol AS bigint)                                AS negotiated_trading_vol,
    CAST(trade_summary.negotiated_trading_val AS decimal(23,2))                         AS negotiated_trading_val,
    CAST(trade_summary.odd_lot_trading_vol AS bigint)                                   AS odd_lot_trading_vol,
    CAST(trade_summary.odd_lot_trading_val AS decimal(23,2))                            AS odd_lot_trading_val,
    CAST(trade_summary.total_trading_vol AS bigint)                                     AS total_trading_vol,
    CAST(trade_summary.total_trading_val AS decimal(23,2))                              AS total_trading_val,
    CAST(foreign_ownership.max_foreign_ownership_ratio AS decimal(9,4))                 AS max_foreign_ownership_ratio,
    CAST(100 * CAST(foreign_ownership.remaining_foreign_holding_quantity AS decimal(23,4))
        / NULLIF(CAST(foreign_ownership.total_issued_share_quantity AS decimal(23,4)), 0) 
        AS decimal(9,4))                                                                AS remaining_foreign_ownership_ratio,
    CAST(trade_summary.foreign_investor_total_buy_vol AS bigint)                        AS foreign_investor_total_buy_vol,
    CAST(trade_summary.foreign_investor_total_sell_vol AS bigint)                       AS foreign_investor_total_sell_vol,
    CAST(trade_summary.foreign_investor_total_buy_val AS decimal(23,2))                 AS foreign_investor_total_buy_val,
    CAST(trade_summary.foreign_investor_total_sell_val AS decimal(23,2))                AS foreign_investor_total_sell_val,
    CAST(trade_summary.foreign_investor_negotiated_buy_vol AS bigint)                   AS foreign_investor_negotiated_buy_vol,
    CAST(trade_summary.foreign_investor_negotiated_sell_vol AS bigint)                  AS foreign_investor_negotiated_sell_vol,
    CAST(trade_summary.foreign_investor_negotiated_buy_val AS decimal(23,2))            AS foreign_investor_negotiated_buy_val,
    CAST(trade_summary.foreign_investor_negotiated_sell_val AS decimal(23,2))           AS foreign_investor_negotiated_sell_val,
    CAST(trade_summary.foreign_investor_matched_buy_vol AS bigint)                      AS foreign_investor_matched_buy_vol,
    CAST(trade_summary.foreign_investor_matched_sell_vol AS bigint)                     AS foreign_investor_matched_sell_vol,
    CAST(trade_summary.foreign_investor_matched_buy_val AS decimal(23,2))               AS foreign_investor_matched_buy_val,
    CAST(trade_summary.foreign_investor_matched_sell_val AS decimal(23,2))              AS foreign_investor_matched_sell_val,
    CAST(trade_summary.proprietary_total_buy_vol AS bigint)                             AS proprietary_total_buy_vol,
    CAST(trade_summary.proprietary_total_sell_vol AS bigint)                            AS proprietary_total_sell_vol,
    CAST(trade_summary.proprietary_total_buy_val AS decimal(23,2))                      AS proprietary_total_buy_val,
    CAST(trade_summary.proprietary_total_sell_val AS decimal(23,2))                     AS proprietary_total_sell_val,
    CAST(trade_summary.proprietary_negotiated_buy_vol AS bigint)                        AS proprietary_negotiated_buy_vol,
    CAST(trade_summary.proprietary_negotiated_sell_vol AS bigint)                       AS proprietary_negotiated_sell_vol,
    CAST(trade_summary.proprietary_negotiated_buy_val AS decimal(23,2))                 AS proprietary_negotiated_buy_val,
    CAST(trade_summary.proprietary_negotiated_sell_val AS decimal(23,2))                AS proprietary_negotiated_sell_val,
    CAST(trade_summary.proprietary_matched_buy_vol AS bigint)                           AS proprietary_matched_buy_vol,
    CAST(trade_summary.proprietary_matched_sell_vol AS bigint)                          AS proprietary_matched_sell_vol,
    CAST(trade_summary.proprietary_matched_buy_val AS decimal(23,2))                    AS proprietary_matched_buy_val,
    CAST(trade_summary.proprietary_matched_sell_val AS decimal(23,2))                   AS proprietary_matched_sell_val,
    CAST(trading_snapshot.src_stm_code AS string)                                       AS src_stm_code
FROM trading_snapshot
INNER JOIN snapshot_dim
    ON snapshot_dim.symbol = trading_snapshot.ticker_symbol
INNER JOIN order_summary
    ON order_summary.ticker_symbol = trading_snapshot.ticker_symbol
INNER JOIN trade_summary
    ON trade_summary.ticker_symbol = trading_snapshot.ticker_symbol
LEFT JOIN foreign_ownership
    ON foreign_ownership.ticker_symbol = trading_snapshot.ticker_symbol
    AND foreign_ownership.rpt_dt = trading_snapshot.trading_dt
