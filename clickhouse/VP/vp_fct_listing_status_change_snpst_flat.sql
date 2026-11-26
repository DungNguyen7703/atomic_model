/*
*--------------------------------------------------------------------*
* Program code: vp_fct_listing_status_change_snpst_flat
* Program name: VP Fct Listing Status Change Snapshot Flat
* Created by: huy.pham
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-03      huy.pham        [MOI] Flat table ClickHouse: Fact Listing Status Change
*                                 Snapshot x Calendar Date Dim x Security Trading Snapshot
*                                 Dim. Grain = 1 quyet dinh x 1 ma CK x 1 So (HNX/HOSE).
*                                 CAST tuong minh cho tung cot de khop kieu CK DDL.
* 2026-11-04      huy.pham        [SUA] Bo qua datamart layer — keo thang tu Atomic.
*                                 Giu lai approach cu (comment) de de dang switch lai.
* 2026-11-18      claude          [O_VP_86] Them par_val. Them CTE stock_pf (ban tin MDDS
*                                 moi nhat theo ticker) lam fallback reference_price khi tinh
*                                 par_val TPDN niem yet khi khong co ban tin tai ngay su kien.
* 2026-11-10      huy.pham        [SUA, O_VP_74] Bo filter stock_tp_code='2'. Them fund_tp_code
*                                 vao stock_eod_dedup/stock_eod. Them 2 cot listing_stock_tp_code,
*                                 listing_fund_tp_code. Them filter decision_date <= etl_date.
*                                 Refactor: them CTE event_trading_dt de resolve dung phien GD
*                                 cua su kien (thay vi 2 alias s_new/s_add lap CASE moi cot).
*                                 Lay trang thai ma CK tai dung thoi diem su kien, khong dung
*                                 latest toan thoi gian.
*--------------------------------------------------------------------*
*/

-- ============================================================
-- APPROACH 1 [CU - DATAMART]: uncomment khoi nay, comment khoi ATOMIC
-- ============================================================
-- WITH stock_eod_dedup AS (
--     SELECT
--         ticker_symbol,
--         trading_dt,
--         floor_code,
--         ROW_NUMBER() OVER (
--             PARTITION BY ticker_symbol, trading_dt
--             ORDER BY trading_time DESC, sequence DESC
--         ) AS rn
--     FROM {{ ref('atm_security_trading_snapshot') }}
--     WHERE stock_tp_code  = '2'
--         AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
-- ),
--
-- stock_eod AS (
--     SELECT
--         ticker_symbol,
--         trading_dt,
--         floor_code,
--         LEAD(trading_dt) OVER (
--             PARTITION BY ticker_symbol
--             ORDER BY trading_dt
--         )                   AS next_trading_dt
--     FROM stock_eod_dedup
--     WHERE rn = 1
-- )
--
-- SELECT /*+ BROADCAST(cal) */
-- ...
-- FROM {{ ref('dtm_fct_listing_status_change_snpst') }} f
-- LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
--     ON  cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- LEFT JOIN {{ ref('dtm_security_trading_snpst_dim') }}_hstr sts
--     ON  sts.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id
--     AND sts.ds_snpst_dt                   = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--     AND sts.ds_rcrd_st                    = 'ACTIVE'
-- WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')


-- ============================================================
-- APPROACH 2 [MOI - ATOMIC]: uncomment khoi nay, comment khoi DATAMART
-- ============================================================
WITH stock_eod_dedup AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        full_nm,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
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
        product_id,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

stock_eod AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        full_nm,
        underlying_symbol,
        isin_code,
        issuer_nm,
        listed_share_count,
        first_trading_dt,
        last_trading_dt,
        issue_dt,
        maturity_dt,
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
        product_id,
        src_stm_code,
        LEAD(trading_dt) OVER (
            PARTITION BY ticker_symbol
            ORDER BY trading_dt
        )                   AS next_trading_dt
    FROM stock_eod_dedup
    WHERE rn = 1
),

stock_pf AS (
    SELECT ticker_symbol, reference_price
    FROM (
        SELECT
            ticker_symbol,
            reference_price,
            ROW_NUMBER() OVER (PARTITION BY ticker_symbol ORDER BY trading_dt DESC) AS rn_pf
        FROM stock_eod
    ) t
    WHERE rn_pf = 1
),

-- Dedup niem yet bo sung / huy co cung (ticker, effective_date) nhung khac first_trading_date:
--   niem yet moi: giu nguyen
--   bo sung / huy: GROUP BY tat ca tru first_trading_date (NULL) va cac cot so (SUM)
lsc_dedup AS (
    SELECT
        listing_status_change_id,
        ticker_symbol,
        decision_no,
        decision_date,
        effective_date,
        first_trading_date,
        last_trading_date,
        delisted_share_quantity,
        delisted_share_value,
        new_listed_share_quantity,
        additional_listed_share_quantity,
        listed_share_value,
        additional_listed_share_value,
        exchange_transfer,
        delist_transfer_reason,
        src_stm_code
    FROM {{ ref('atm_listing_status_change') }}
    WHERE new_listed_share_quantity > 0
        AND src_stm_code IN ('HNX_LISTING_STATUS_CHANGE', 'HOSE_LISTING_STATUS_CHANGE')
        AND decision_date <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

    UNION ALL

    SELECT
        CAST(md5(concat_ws('|',
            ticker_symbol,
            CAST(effective_date            AS string),
            COALESCE(decision_no,          ''),
            CAST(decision_date             AS string),
            COALESCE(CAST(last_trading_date AS string), ''),
            COALESCE(exchange_transfer,    ''),
            COALESCE(delist_transfer_reason,''),
            src_stm_code
        )) AS string)                                   AS listing_status_change_id,
        ticker_symbol,
        decision_no,
        decision_date,
        effective_date,
        NULL                                            AS first_trading_date,
        last_trading_date,
        SUM(delisted_share_quantity)                    AS delisted_share_quantity,
        SUM(delisted_share_value)                       AS delisted_share_value,
        SUM(new_listed_share_quantity)                  AS new_listed_share_quantity,
        SUM(additional_listed_share_quantity)           AS additional_listed_share_quantity,
        SUM(listed_share_value)                         AS listed_share_value,
        SUM(additional_listed_share_value)              AS additional_listed_share_value,
        exchange_transfer,
        delist_transfer_reason,
        src_stm_code
    FROM {{ ref('atm_listing_status_change') }}
    WHERE (new_listed_share_quantity IS NULL OR new_listed_share_quantity = 0)
        AND src_stm_code IN ('HNX_LISTING_STATUS_CHANGE', 'HOSE_LISTING_STATUS_CHANGE')
        AND decision_date <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    GROUP BY
        ticker_symbol,
        decision_no,
        decision_date,
        effective_date,
        last_trading_date,
        exchange_transfer,
        delist_transfer_reason,
        src_stm_code
),

-- Resolve dung phien GD cua tung su kien:
--   niem yet moi (new_listed_share_quantity > 0) → first_trading_date
--   bo sung / huy                                → phien gan nhat <= effective_date
event_trading_dt AS (
    SELECT
        lsc.listing_status_change_id,
        lsc.ticker_symbol,
        CASE
            WHEN lsc.new_listed_share_quantity > 0 THEN s_new.trading_dt
            ELSE s_add.trading_dt
        END AS event_trading_dt
    FROM lsc_dedup lsc
    LEFT JOIN stock_eod s_new
        ON  s_new.ticker_symbol = lsc.ticker_symbol
        AND s_new.trading_dt    = lsc.first_trading_date
    LEFT JOIN stock_eod s_add
        ON  s_add.ticker_symbol  = lsc.ticker_symbol
        AND s_add.trading_dt    <= lsc.effective_date
        AND (lsc.effective_date  < s_add.next_trading_dt OR s_add.next_trading_dt IS NULL)
)

SELECT /*+ BROADCAST(cal) */
    CAST(lsc.listing_status_change_id           AS string)           AS listing_status_change_snpst_id,
    CAST(date_format(lsc.effective_date, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'lsc.ticker_symbol') }} AS string) AS security_trading_snpst_dim_id,
    CAST(lsc.ticker_symbol                      AS string)           AS ticker_symbol,
    CAST(lsc.decision_no                        AS string)           AS decision_nbr,
    CAST(lsc.decision_date                      AS date)             AS decision_dt,
    CAST(lsc.effective_date                     AS date)             AS effective_dt,
    CAST(lsc.last_trading_date                  AS date)             AS listing_last_trading_dt,
    CAST(lsc.delisted_share_quantity            AS bigint)           AS delisted_share_quantity,
    CAST(lsc.delisted_share_value               AS decimal(23,2))    AS delisted_share_val,
    CAST(lsc.new_listed_share_quantity          AS bigint)           AS new_listed_share_quantity,
    CAST(lsc.additional_listed_share_quantity   AS bigint)           AS additional_listed_share_quantity,
    CAST(lsc.listed_share_value                 AS decimal(23,2))    AS listed_share_val,
    CAST(lsc.additional_listed_share_value      AS decimal(23,2))    AS additional_listed_share_val,
    CAST(lsc.exchange_transfer                  AS string)           AS exchange_transfer,
    CAST(lsc.delist_transfer_reason             AS string)           AS delist_transfer_reason,
    CAST(lsc.src_stm_code                       AS string)           AS src_stm_code,
    CAST(sts.floor_code                         AS string)           AS listing_floor_code,
    CAST(sts.stock_tp_code                      AS string)           AS listing_stock_tp_code,
    CAST(sts.fund_tp_code                       AS string)           AS listing_fund_tp_code,
    CAST(
        CASE
            WHEN sts.stock_tp_code = '1'
            THEN 100000 * POWER(10, ROUND(LOG10(
                NULLIF(COALESCE(sts.reference_price, spf.reference_price), 0) / 100000
            )))
            WHEN sts.stock_tp_code IN ('2', '3', '6') THEN 10000
            ELSE NULL
        END AS decimal(23,2)
    )                                                                AS par_val,

    CAST(cal.cdr_dt                             AS date)             AS cdr_dt,
    CAST(cal.year                               AS bigint)           AS year,
    CAST(cal.quarter                            AS bigint)           AS quarter,
    CAST(cal.month                              AS bigint)           AS month,
    CAST(cal.day_of_week                        AS bigint)           AS day_of_week,
    CAST(cal.is_weekend                         AS string)           AS is_weekend,
    CAST(cal.holiday_flag                       AS string)           AS holiday_flag,
    CAST(cal.is_trading_date                    AS string)           AS is_trading_date,

    CAST(lsc.ticker_symbol                      AS string)           AS symbol,
    CAST(sts.full_nm                            AS string)           AS security_full_nm,
    CAST(sts.floor_code                         AS string)           AS floor_code,
    CAST(sts.stock_tp_code                      AS string)           AS stock_tp_code,
    CAST(
        CASE
            WHEN sts.floor_code = '10' THEN
                CASE
                    WHEN sts.stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN sts.stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN sts.stock_tp_code = '3' AND sts.fund_tp_code = 'E' THEN 'ETF'
                    WHEN sts.stock_tp_code = '3' AND sts.fund_tp_code = 'M' THEN 'Chứng chỉ quỹ'
                    WHEN sts.stock_tp_code = '4' THEN 'Chứng quyền'
                    ELSE 'Khác'
                END
            WHEN sts.floor_code IN ('02', '04') THEN
                CASE
                    WHEN sts.stock_tp_code = '1' THEN 'Trái phiếu'
                    WHEN sts.stock_tp_code = '2' THEN 'Cổ phiếu'
                    WHEN sts.stock_tp_code = '3' THEN 'Chứng chỉ quỹ'
                    WHEN sts.stock_tp_code = '4' THEN 'Phái sinh'
                    WHEN sts.stock_tp_code = '5' THEN 'Chứng quyền'
                    WHEN sts.stock_tp_code = '6' THEN 'ETF'
                    ELSE 'Khác'
                END
            ELSE 'Khác'
        END
    AS string)                                                       AS stock_tp_nm,
    CAST(sts.underlying_symbol                  AS string)           AS underlying_symbol,
    CAST(sts.isin_code                          AS string)           AS isin_code,
    CAST(sts.issuer_nm                          AS string)           AS issuer_nm,
    CAST(sts.listed_share_count                 AS bigint)           AS listed_share_count,
    CAST(sts.first_trading_dt                   AS date)             AS first_trading_dt,
    CAST(sts.last_trading_dt                    AS date)             AS last_trading_dt,
    CAST(sts.issue_dt                           AS date)             AS issue_dt,
    CAST(sts.maturity_dt                        AS date)             AS maturity_dt,
    CAST(sts.fund_tp_code                       AS string)           AS fund_tp_code,
    CAST(sts.covered_warrant_tp_code            AS string)           AS covered_warrant_tp_code,
    CAST(sts.exercise_price                     AS decimal(23,2))    AS exercise_price,
    CAST(sts.exercise_ratio                     AS string)           AS exercise_ratio,
    CAST(sts.exercise_style_code                AS string)           AS exercise_style_code,
    CAST(sts.put_or_call_code                   AS string)           AS put_or_call_code,
    CAST(sts.contract_multiplier                AS string)           AS contract_multiplier,
    CAST(sts.maturity_month_year                AS string)           AS maturity_month_year,
    CAST(sts.coupon_rate                        AS decimal(8,5))     AS coupon_rate,
    CAST(sts.yield                              AS decimal(8,5))     AS yield,
    CAST(sts.open_price                         AS decimal(23,2))    AS open_price,
    CAST(sts.high_price                         AS decimal(23,2))    AS high_price,
    CAST(sts.low_price                          AS decimal(23,2))    AS low_price,
    CAST(sts.ceiling_price                      AS decimal(23,2))    AS ceiling_price,
    CAST(sts.floor_price                        AS decimal(23,2))    AS floor_price,
    CAST(sts.reference_price                    AS decimal(23,2))    AS reference_price,
    CAST(sts.close_price                        AS decimal(23,2))    AS close_price,
    CAST(sts.price_change                       AS decimal(23,2))    AS price_change,
    CAST(sts.product_group_id                   AS string)           AS product_group_id,
    CAST(sts.product_id                         AS string)           AS product_id,
    CAST(sts.src_stm_code                       AS string)           AS sts_dim_src_stm_code

FROM lsc_dedup lsc
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON  cal.cdr_dt = lsc.effective_date
LEFT JOIN event_trading_dt evt
    ON  evt.listing_status_change_id = lsc.listing_status_change_id
LEFT JOIN stock_eod sts
    ON  sts.ticker_symbol = evt.ticker_symbol
    AND sts.trading_dt    = evt.event_trading_dt
LEFT JOIN stock_pf spf
    ON  spf.ticker_symbol = lsc.ticker_symbol
