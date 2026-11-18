/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_listed_equity_snpst
* Program name: Dtm Fct Listed Equity Snapshot
* Created by: huy.pham
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-29      huy.pham        [MOI, theo LLD DTM_VP_fct_listed_equity_snpst.csv]
*                                 Fact snapshot co phieu / chung chi quy niem yet cuoi
*                                 ngay. Grain = 1 ma (stock_tp_code 2/3/6) / ngay GD
*                                 (MDDS MDDS_JAD_STOCKINFOR, floor_code IN 02/04/10).
*                                 Moi ETL chay 2 partition: ngay D va ngay D-1. Dong
*                                 ngay D: next_day_vol_weighted_average_price/market_price/
*                                 market_cap_val = NULL (chua co ban tin D+1). Dong ngay
*                                 D-1: dien cac cot tren tu ban tin ngay D (O_VP_40).
*                                 Von hoa chi tinh cho co phieu (stock_tp_code='2');
*                                 UPCoM (floor_code='04') dung VWAP thay close_price
*                                 (VWAP=0 -> reference_price). Khoi luong luu hanh:
*                                 VSDC_OUTSTANDING_SHARES theo dung ngay GD (O_VP_40).
*                                 average_price dung lam vol_weighted_average_price —
*                                 can MDDS xac nhan ten cot chinh xac (O_VP_40).
*--------------------------------------------------------------------*
*/

WITH prev_dt AS (
    SELECT MAX(cdr_dt) AS prev_trading_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
    WHERE is_trading_date = 'Y'
        AND cdr_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sn_all AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        close_price,
        reference_price,
        listed_share_count,
        average_price,
        trading_time,
        sequence,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code IN ('2', '3', '6')
        AND floor_code IN ('02', '04', '10')
        AND trading_dt IN (
            to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'),
            (SELECT prev_trading_dt FROM prev_dt)
        )
),

sn AS (
    SELECT ticker_symbol, trading_dt, floor_code, stock_tp_code,
           close_price, reference_price, listed_share_count, average_price, src_stm_code
    FROM sn_all
    WHERE rn = 1
),

-- ban tin cuoi ngay etl_date: lay average_price lam next_day_vwap cho dong prev_trading_dt
nxt_all AS (
    SELECT
        ticker_symbol,
        average_price AS next_day_vwap,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

nxt AS (
    SELECT ticker_symbol, next_day_vwap
    FROM nxt_all
    WHERE rn = 1
),

lsi AS (
    SELECT ticker_symbol, outstanding_share_quantity, transaction_dt
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

joined AS (
    SELECT
        sn.ticker_symbol,
        sn.trading_dt,
        sn.floor_code,
        sn.stock_tp_code,
        sn.close_price,
        sn.reference_price,
        sn.listed_share_count,
        sn.src_stm_code,
        lsi.outstanding_share_quantity,
        -- next_day_vwap: chi lay cho dong prev_trading_dt (ban tin etl_date = T+1 cua prev)
        CASE WHEN sn.trading_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
             THEN nxt.next_day_vwap
        END                                                    AS nxt_vwap,
        -- market_price: HOSE/HNX = close_price; UPCoM = VWAP(T) lay tu ban tin T+1
        CASE
            WHEN sn.floor_code = '04' THEN
                CASE WHEN sn.trading_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') THEN
                    CASE WHEN nxt.next_day_vwap IS NULL THEN NULL
                         ELSE COALESCE(NULLIF(nxt.next_day_vwap, 0), sn.reference_price)
                    END
                END
            ELSE sn.close_price
        END                                                    AS market_price_calc
    FROM sn
    LEFT JOIN nxt
        ON  nxt.ticker_symbol = sn.ticker_symbol
    LEFT JOIN lsi
        ON  lsi.ticker_symbol  = sn.ticker_symbol
        AND lsi.transaction_dt = sn.trading_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', "CONCAT(date_format(trading_dt,'yyyyMMdd'), '|', ticker_symbol, '|', src_stm_code)") }} AS string) AS listed_equity_snpst_id,
    CAST(date_format(trading_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(ticker_symbol AS string)                            AS ticker_symbol,
    CAST(floor_code AS string)                               AS floor_code,
    CAST(stock_tp_code AS string)                            AS stock_tp_code,
    CAST(outstanding_share_quantity AS bigint)               AS outstanding_share_quantity,
    CAST(listed_share_count AS bigint)                       AS listed_share_quantity,
    CAST(listed_share_count * 10000 AS decimal(23,2))        AS listed_share_val,
    CAST(close_price AS decimal(23,2))                       AS close_price,
    CAST(reference_price AS decimal(23,2))                   AS reference_price,
    CAST(nxt_vwap AS bigint)                                 AS next_day_vol_weighted_average_price,
    CAST(market_price_calc AS decimal(23,2))                 AS market_price,
    CAST(
        CASE WHEN stock_tp_code = '2'
             THEN market_price_calc * outstanding_share_quantity
        END
    AS decimal(23,2))                                        AS market_cap_val,
    CAST(src_stm_code AS string)                             AS src_stm_code
FROM joined
