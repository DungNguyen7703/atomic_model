/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_derivatives_security_detail_snpst
* Program name: Fact Derivatives Security Detail Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		duxn			[REF] Chuan hoa phan tang CTE: dua cac CTE trich xuat bang nguon len dau,
*									cac CTE tong hop/bien doi xu ly tu cac CTE truoc.
* 2026-11-07		claude			[UPD] Dong bo LLD 836eb5bb: ten cot Atomic securities_trade theo LLD (execution_vol/price ->
*									match_quantity/match_price, security_symbol_code -> ticker_symbol, market_id_code ->
*									market_code); open interest: rpt_dt -> make_date(rpt_year, rpt_month, rpt_day).
*--------------------------------------------------------------------*
*/

WITH snapshot_raw AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        contract_multiplier,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY trading_dt, ticker_symbol
            ORDER BY trading_time DESC, sequence DESC)
        AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code = '03'
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

trade_raw AS (
    SELECT
        trade_dt,
        ticker_symbol,
        match_quantity,
        match_price,
        buy_account_nbr,
        sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_code = 'DVX'
),

open_interest AS (
    SELECT
        make_date(rpt_year, rpt_month, rpt_day) AS rpt_dt,
        ticker_symbol,
        open_interest_quantity
    FROM {{ ref('atm_end_of_day_open_interest') }}
    WHERE make_date(rpt_year, rpt_month, rpt_day) = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'VSDC_END_OF_DAY_OPEN_INTEREST'
),

trading_snapshot AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        CAST(COALESCE(contract_multiplier, 1) AS decimal(23,4)) AS contract_multiplier,
        src_stm_code
    FROM snapshot_raw
    WHERE rn = 1
),

trade_agg AS (
    SELECT
        trade_dt,
        ticker_symbol,
        SUM(match_quantity)                                            AS trading_vol,
        SUM(match_quantity * match_price)                              AS trading_amt,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity 
                 ELSE 0 END) AS foreign_investor_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN match_quantity * match_price 
                 ELSE 0 END) AS foreign_investor_buy_amt,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN match_quantity * match_price  
                 ELSE 0 END) AS foreign_investor_sell_amt,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity 
                 ELSE 0 END) AS proprietary_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity * match_price 
                 ELSE 0 END) AS proprietary_buy_amt,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A') THEN match_quantity * match_price 
                 ELSE 0 END) AS proprietary_sell_amt
    FROM trade_raw
    GROUP BY
        trade_dt,
        ticker_symbol
),

trade_summary AS (
    SELECT
        trading_snapshot.ticker_symbol,
        SUM(trade_agg.trading_vol)                AS trading_vol,
        SUM(trade_agg.trading_amt)                AS trading_amt,
        SUM(trade_agg.foreign_investor_buy_vol)   AS foreign_investor_buy_vol,
        SUM(trade_agg.foreign_investor_sell_vol)  AS foreign_investor_sell_vol,
        SUM(trade_agg.foreign_investor_buy_amt)   AS foreign_investor_buy_amt,
        SUM(trade_agg.foreign_investor_sell_amt)  AS foreign_investor_sell_amt,
        SUM(trade_agg.proprietary_buy_vol)        AS proprietary_buy_vol,
        SUM(trade_agg.proprietary_sell_vol)       AS proprietary_sell_vol,
        SUM(trade_agg.proprietary_buy_amt)        AS proprietary_buy_amt,
        SUM(trade_agg.proprietary_sell_amt)       AS proprietary_sell_amt
    FROM trading_snapshot
    INNER JOIN trade_agg
        ON trade_agg.trade_dt = trading_snapshot.trading_dt
        AND trade_agg.ticker_symbol IN (trading_snapshot.ticker_symbol, trading_snapshot.isin_code)
    GROUP BY
        trading_snapshot.ticker_symbol
),

interest_summary AS (
    SELECT
        trading_snapshot.ticker_symbol,
        SUM(open_interest.open_interest_quantity) AS open_interest_quantity
    FROM trading_snapshot
    INNER JOIN open_interest
        ON open_interest.rpt_dt = trading_snapshot.trading_dt
        AND open_interest.ticker_symbol IN (trading_snapshot.ticker_symbol, trading_snapshot.isin_code)
    GROUP BY
        trading_snapshot.ticker_symbol
)

SELECT
    CAST(date_format(trading_snapshot.trading_dt, 'yyyyMMdd') AS string)                                    AS snpst_dt_dim_id,
    CAST(snapshot_dim.security_trading_snpst_dim_id AS string)                                              AS security_trading_snpst_dim_id,
    CAST(interest_summary.open_interest_quantity AS bigint)                                                 AS open_interest_quantity,
    CAST(trade_summary.trading_vol AS bigint)                                                               AS trading_vol,
    CAST(trade_summary.trading_amt * trading_snapshot.contract_multiplier AS decimal(23,2))                 AS trading_val,
    CAST(trade_summary.foreign_investor_buy_vol AS bigint)                                                  AS foreign_investor_buy_vol,
    CAST(trade_summary.foreign_investor_sell_vol AS bigint)                                                 AS foreign_investor_sell_vol,
    CAST(trade_summary.foreign_investor_buy_amt * trading_snapshot.contract_multiplier AS decimal(23,2))    AS foreign_investor_buy_val,
    CAST(trade_summary.foreign_investor_sell_amt * trading_snapshot.contract_multiplier AS decimal(23,2))   AS foreign_investor_sell_val,
    CAST(trade_summary.proprietary_buy_vol AS bigint)                                                       AS proprietary_buy_vol,
    CAST(trade_summary.proprietary_sell_vol AS bigint)                                                      AS proprietary_sell_vol,
    CAST(trade_summary.proprietary_buy_amt * trading_snapshot.contract_multiplier AS decimal(23,2))         AS proprietary_buy_val,
    CAST(trade_summary.proprietary_sell_amt * trading_snapshot.contract_multiplier AS decimal(23,2))        AS proprietary_sell_val,
    CAST(trading_snapshot.src_stm_code AS string)                                                           AS src_stm_code
FROM trading_snapshot
INNER JOIN snapshot_dim
    ON snapshot_dim.symbol = trading_snapshot.ticker_symbol
LEFT JOIN trade_summary
    ON trade_summary.ticker_symbol = trading_snapshot.ticker_symbol
LEFT JOIN interest_summary
    ON interest_summary.ticker_symbol = trading_snapshot.ticker_symbol
