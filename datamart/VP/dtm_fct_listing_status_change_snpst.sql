/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_listing_status_change_snpst
* Program name: Dtm Fct Listing Status Change Snapshot
* Created by: huy.pham
* Created date: 2026-11-02
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-02      huy.pham        [MOI, theo LLD DTM_VP_fct_listing_status_change_snpst]
*                                 Fact lịch sử thay đổi niêm yết / đăng ký GD.
*                                 Grain = 1 quyết định × 1 mã CK × 1 Sở (HNX/HOSE).
*                                 ETL nạp đủ LỊCH SỬ (decision_date <= etl_date),
*                                 không lọc daily — dùng MERGE (upsert) theo PK.
*                                 snpst_dt_dim_id = LOOKUP cdr_dt_dim(effective_date).
*                                 security_trading_snpst_dim lookup theo symbol
*                                 (không lọc ngày — BA: loại CK không đổi, O_VP_44).
*                                 Cột mới vs snapshot facts: new_listed_share_quantity,
*                                 additional_listed_share_quantity, listed_share_val,
*                                 additional_listed_share_val (O_VP_45).
* 2026-11-02      huy.pham        [BS] Thêm listing_floor_code: mã sàn tại thời điểm
*                                 quyết định — niêm yết mới lấy tại first_trading_date,
*                                 bổ sung/hủy lấy tại phiên gần nhất <= effective_date
*                                 (LEAD trick, không giới hạn dưới — O_VP_53).
*                                 Nguồn: atm_security_trading_snapshot (stock_tp_code='2',
*                                 MDDS_JAD_STOCKINFOR), dedup trading_time DESC, sequence DESC.
* 2026-11-18      claude          [O_VP_74, O_VP_86] Them listing_stock_tp_code,
*                                 listing_fund_tp_code, par_val. Them stock_tp_code/
*                                 fund_tp_code/reference_price vao stock_eod_dedup/stock_eod.
*                                 Them CTE stock_pf (ban tin moi nhat theo ticker) lam
*                                 fallback reference_price khi tinh par_val TPDN niem yet.
* 2026-11-10      huy.pham        [SUA, O_VP_74] Bỏ filter stock_tp_code='2' trong
*                                 stock_eod_dedup để listing_floor_code đúng với TPDN NY,
*                                 CCQ/ETF, CW. Thêm 2 cột listing_stock_tp_code,
*                                 listing_fund_tp_code (bản tin MDDS mới nhất của mã đến
*                                 etl_date, floor_code <> '03'). Thêm filter
*                                 decision_date <= etl_date vào WHERE.
*--------------------------------------------------------------------*
*/

WITH stock_eod_dedup AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        reference_price,
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
        reference_price,
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
)

SELECT
    -- PK: dùng thẳng listing_status_change_id từ Atomic (đã hash sẵn)
    CAST(lsc.listing_status_change_id           AS string)           AS listing_status_change_snpst_id,

    -- snpst_dt_dim_id = etl_date (ngày chạy job, partition kỹ thuật)
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string) AS snpst_dt_dim_id,

    -- cdr_dt_dim_id = effective_date (ngày hiệu lực, dùng cho calendar JOIN ở flat layer)
    CAST(cdr.cdr_dt_dim_id                      AS string)           AS cdr_dt_dim_id,

    -- FK: Security Trading Snapshot Dim — generate inline theo symbol (không lọc ngày, O_VP_44)
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

    -- Mã sàn tại thời điểm quyết định (O_VP_53, bỏ filter stock_tp_code='2' theo O_VP_74):
    --   niêm yết mới  → s_new: bản tin tại first_trading_date
    --   bổ sung / hủy → s_add: bản tin phiên gần nhất <= effective_date
    CAST(
        CASE WHEN lsc.new_listed_share_quantity > 0
             THEN s_new.floor_code
             ELSE s_add.floor_code
        END AS string
    )                                                                AS listing_floor_code,
    CAST(
        CASE WHEN lsc.new_listed_share_quantity > 0
             THEN s_new.stock_tp_code
             ELSE s_add.stock_tp_code
        END AS string
    )                                                                AS listing_stock_tp_code,
    CAST(
        CASE WHEN lsc.new_listed_share_quantity > 0
             THEN s_new.fund_tp_code
             ELSE s_add.fund_tp_code
        END AS string
    )                                                                AS listing_fund_tp_code,
    CAST(
        CASE
            WHEN (CASE WHEN lsc.new_listed_share_quantity > 0 THEN s_new.stock_tp_code ELSE s_add.stock_tp_code END) = '1'
            THEN 100000 * POWER(10, ROUND(LOG10(
                NULLIF(COALESCE(
                    CASE WHEN lsc.new_listed_share_quantity > 0 THEN s_new.reference_price ELSE s_add.reference_price END,
                    spf.reference_price
                ), 0) / 100000
            )))
            WHEN (CASE WHEN lsc.new_listed_share_quantity > 0 THEN s_new.stock_tp_code ELSE s_add.stock_tp_code END) IN ('2', '3', '6')
            THEN 10000
            ELSE NULL
        END AS decimal(23,2)
    )                                                                AS par_val

FROM {{ ref('atm_listing_status_change') }} lsc
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cdr
    ON  cdr.cdr_dt = lsc.effective_date
LEFT JOIN stock_eod s_new
    ON  s_new.ticker_symbol = lsc.ticker_symbol
    AND s_new.trading_dt    = lsc.first_trading_date
LEFT JOIN stock_eod s_add
    ON  s_add.ticker_symbol = lsc.ticker_symbol
    AND s_add.trading_dt   <= lsc.effective_date
    AND (lsc.effective_date  < s_add.next_trading_dt OR s_add.next_trading_dt IS NULL)
LEFT JOIN stock_pf spf
    ON  spf.ticker_symbol   = lsc.ticker_symbol
WHERE lsc.src_stm_code IN ('HNX_LISTING_STATUS_CHANGE', 'HOSE_LISTING_STATUS_CHANGE')
    AND lsc.decision_date  <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    --and lsc.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
