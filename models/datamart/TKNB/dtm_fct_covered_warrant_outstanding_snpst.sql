/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_covered_warrant_outstanding_snpst
* Program name: Fact Covered Warrant Outstanding Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		claude				Tao moi theo LLD TKNB 7ae22069 (TKNB Nhom 14 TTLK10, thay dtm_ttlk10_cw_outstanding_rpt):
*									grain 1 dong/ma CW/ngay giao dich = :etl_date (khong con SUM theo thang, ky thang do BI tong hop).
*									Chung quyen HOSE = security_trading_snapshot floor_code '10' + stock_tp_code '4', ban ghi cuoi phien
*									moi (trading_dt, ticker_symbol) theo trading_time DESC, sequence DESC.
*--------------------------------------------------------------------*
*/

WITH listed_share AS (
    SELECT
        ticker_symbol,
        transaction_dt,
        outstanding_share_quantity,
        src_stm_code
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND transaction_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

snapshot_raw AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        ROW_NUMBER() OVER (
            PARTITION BY trading_dt, ticker_symbol
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

trading_snapshot AS (
    SELECT
        ticker_symbol,
        trading_dt
    FROM snapshot_raw
    WHERE rn = 1
        AND floor_code = '10'
        AND stock_tp_code = '4'
),

snapshot_dim AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
)

SELECT
    date_format(listed_share.transaction_dt, 'yyyyMMdd')            AS snpst_dt_dim_id,
    CAST(snapshot_dim.security_trading_snpst_dim_id AS string)      AS security_trading_snpst_dim_id,
    CAST(listed_share.outstanding_share_quantity AS bigint)         AS outstanding_quantity,
    CAST(listed_share.src_stm_code AS string)                       AS src_stm_code
FROM listed_share
INNER JOIN trading_snapshot
    ON trading_snapshot.ticker_symbol = listed_share.ticker_symbol
    AND trading_snapshot.trading_dt = listed_share.transaction_dt
INNER JOIN snapshot_dim
    ON snapshot_dim.symbol = listed_share.ticker_symbol
