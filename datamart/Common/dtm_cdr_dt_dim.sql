/*
*--------------------------------------------------------------------*
* Program code: dtm_cdr_dt_dim
* Program name: Dtm Cdr Dt Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-09		tuan.nguyenvanb		[MOI theo LLD 2026-10-09, BA doi rule] Them cot is_trading_date (Y/N): Y neu ngay lich co ban ghi
*                                       o CA HAI Market Index Snapshot (MDDS.JAD_MARKETINFOR) VA Security Trading Snapshot
*                                       (MDDS.JAD_STOCKINFOR); ngay chi co o 1 trong 2 nguon -> N. Thay rule 2026-09-05 (chi dua
*                                       tren Market Index Snapshot, tinh o cdr_dt_flat qua dtm_fct_market_index_snpst).
*                                       Luu y: model nay gio DOC atomic atm_market_index_snapshot + atm_security_trading_snapshot
*                                       nen phai chay SAU 2 atomic nay.
* 2026-10-12		tuan.nguyenvanb		[LLD v4.46, O_GSTT_62 - BA doi rule lan 2] is_trading_date = Y neu ngay lich co
*                                       ban ghi o IT NHAT MOT trong 4 nguon (UNION): Market Index Snapshot
*                                       (MDDS.JAD_MARKETINFOR), Security Trading Snapshot (MDDS.JAD_STOCKINFOR), Securities
*                                       Trade nhanh ORDERTRADE_TRADE_BOOK_HOSE va ORDERTRADE_TRADE_BOOK_HNX (so lenh khop).
*                                       Thay rule 2026-10-09 (phai co o CA HAI nguon MDDS). Khong doi cot. Model phai chay
*                                       SAU 3 atomic: atm_market_index_snapshot, atm_security_trading_snapshot, atm_securities_trade.
* 2026-10-12		tuan.nguyenvanb		[Theo LLD Common DTM_NHNCK_cdr_dt_dim - user chot] BO doc thang
*                                       oracle_src.UAT_ECAT.WORKING_SCHEDULE (LLD khong dung bang nay; LLD dung atomic cdr_dt
*                                       nhung bang nay chua ton tai). Model chi doc 3 atomic giao dich. Dai ngay: lich dense co
*                                       dinh 2000-01-01 -> 31/12 (nam hien tai + 5). holiday_flag tam gan 'N' cho moi ngay
*                                       (chua co nguon ngay nghi le). Khong doi cot. Strategy merge theo cdr_dt_dim_id nen
*                                       ngay cu ngoai dai van giu nguyen trong bang, khong bi xoa.
*--------------------------------------------------------------------*
*/

WITH spine AS (

    -- [2026-10-12] Lich dense co dinh: 2000-01-01 -> 31/12 cua (nam hien tai + 5). Khong phu thuoc nguon.
    SELECT explode(sequence(DATE '2000-01-01', make_date(YEAR(current_date()) + 5, 12, 31), interval 1 day)) AS cdr_dt

),

-- Ngay co du lieu o tung nguon (LLD v4.46 2026-10-12: is_trading_date = ngay co o IT NHAT MOT trong 4 nguon - UNION)
market_index_days AS (

    SELECT DISTINCT CAST(trading_dt AS date) AS trading_dt
    FROM {{ ref('atm_market_index_snapshot') }}

),

security_trading_days AS (

    SELECT DISTINCT CAST(ds_snpst_dt AS date) AS trading_dt   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
    FROM {{ ref('atm_security_trading_snapshot') }}

),

-- So lenh khop HOSE/HNX (Securities Trade), loc dung 2 nhanh theo LLD v4.46 - khong gom securities_order
securities_trade_days AS (

    SELECT DISTINCT CAST(trade_dt AS date) AS trading_dt
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE', 'ORDERTRADE_TRADE_BOOK_HNX')

),

trading_days AS (

    SELECT trading_dt FROM market_index_days
    UNION
    SELECT trading_dt FROM security_trading_days
    UNION
    SELECT trading_dt FROM securities_trade_days

)

SELECT
    CAST(date_format(spine.cdr_dt, 'yyyyMMdd') AS STRING) AS cdr_dt_dim_id,
    CAST(spine.cdr_dt AS date)                                          AS cdr_dt,
    CAST(YEAR(spine.cdr_dt) AS int)                                     AS year,
    CAST(QUARTER(spine.cdr_dt) AS int)                                  AS quarter,
    CAST(MONTH(spine.cdr_dt) AS int)                                    AS month,
    CAST(DAYOFWEEK(spine.cdr_dt) AS int)                                AS day_of_week,
    CASE WHEN DAYOFWEEK(spine.cdr_dt) IN (1, 7) THEN 'Y' ELSE 'N' END   AS is_weekend,
    CAST('N' AS string)                                                 AS holiday_flag,   -- [2026-10-12] chua co nguon ngay nghi le (atomic cdr_dt.hol_f chua ton tai)
    -- [LLD 2026-10-09, thay the 2026-10-12] CASE WHEN mid.trading_dt IS NOT NULL AND std.trading_dt IS NOT NULL THEN 'Y' ELSE 'N' END AS is_trading_date
    CASE WHEN td.trading_dt IS NOT NULL THEN 'Y' ELSE 'N' END AS is_trading_date
FROM spine
LEFT JOIN trading_days td
    ON td.trading_dt = spine.cdr_dt
