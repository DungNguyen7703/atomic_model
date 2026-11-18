/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_derivative_contract_snpst
* Program name: Dtm Fct Derivative Contract Snapshot
* Created by: huy.pham
* Created date: 2026-10-27
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-27      huy.pham        [MOI, theo LLD DTM_VP_fct_derivative_contract_snpst.csv]
*                                 Fact snapshot hop dong phai sinh cuoi ngay. Grain = 1 dong /
*                                 ma hop dong / ngay GD. Hai nguon FULL OUTER JOIN: (1) ban tin
*                                 cuoi ngay MDDS JAD_STOCKINFOR floor_code='03' — lay gia dong
*                                 cua (rn=1 theo trading_time DESC, sequence DESC); (2) bao cao
*                                 khoi luong mo VSDC END_OF_DAY_OPEN_INTEREST — SUM OI theo
*                                 (ticker_symbol, rpt_dt) TRUOC khi noi. FULL OUTER JOIN giu
*                                 hop dong co OI nhung chua co ban tin MDDS va nguoc lai.
*                                 FK security_trading_snpst_dim_id de trong khi chua co trong
*                                 dim. O_VP_12: atm end_of_day_open_interest chua co rpt_dt
*                                 trong khoa — loc bang WHERE truoc GROUP BY.
*--------------------------------------------------------------------*
*/

WITH sn_all AS (
    SELECT
        ticker_symbol,
        trading_dt,
        close_price,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code = '03'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sn AS (
    SELECT
        ticker_symbol,
        trading_dt,
        close_price
    FROM sn_all
    WHERE rn = 1
),

oi AS (
    SELECT
        ticker_symbol,
        rpt_dt,
        SUM(open_interest_quantity) AS open_interest_quantity
    FROM {{ ref('atm_end_of_day_open_interest') }}
    WHERE src_stm_code = 'VSDC_END_OF_DAY_OPEN_INTEREST'
        AND rpt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY ticker_symbol, rpt_dt
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

joined AS (
    SELECT
        COALESCE(sn.ticker_symbol, oi.ticker_symbol)   AS ticker_symbol,
        COALESCE(sn.trading_dt, oi.rpt_dt)             AS snpst_dt,
        sn.close_price,
        oi.open_interest_quantity
    FROM sn
    FULL OUTER JOIN oi
        ON oi.ticker_symbol = sn.ticker_symbol
       AND oi.rpt_dt        = sn.trading_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('fct_derivative_contract_snpst', "CONCAT(date_format(j.snpst_dt,'yyyyMMdd'), '|', j.ticker_symbol)") }} AS string) AS derivative_contract_snpst_id,
    CAST(date_format(j.snpst_dt, 'yyyyMMdd') AS string)    AS snpst_dt_dim_id,
    CAST(d.security_trading_snpst_dim_id AS string)        AS security_trading_snpst_dim_id,
    CAST(j.ticker_symbol AS string)                        AS ticker_symbol,
    CAST(j.open_interest_quantity AS decimal(23,2))         AS open_interest_quantity,
    CAST(j.close_price AS decimal(23,2))                   AS close_price
FROM joined j
LEFT JOIN se_tr_sn_di d
    ON d.symbol = j.ticker_symbol
