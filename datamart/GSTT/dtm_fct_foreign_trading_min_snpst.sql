/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_trading_min_snpst
* Program name: Dtm Fct Foreign Trading Min Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-21
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-21		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_foreign_trading_min_
*                                       snpst.csv, O_GSTT_8] Fact GD NDTNN theo PHUT - 1
*                                       dong / ma CK / phut giao dich (Trade Minute =
*                                       DATE_TRUNC('minute', Trade Timestamp)). Nguon
*                                       atm_securities_trade DA CO SAN cot trade_tms (dong
*                                       nghiep bo sung 2026-09-04 - CANH BAO: dinh dang
*                                       TRADE_TIME cua HNX chua duoc Data Modeler/DBA xac
*                                       nhan 100% mau that, xem chi tiet o
*                                       atm_securities_trade_ordertrade_trade_book_hnx.sql).
*                                       Join sang Security Trading Snapshot Dimension qua
*                                       trade_join_symbol (CASE floor_code IN ('02','04','03')
*                                       THEN isin_code ELSE symbol END) - dung quy uoc chung
*                                       cua GSTT vi atm_securities_trade.security_symbol_code
*                                       da duoc chuan hoa theo dung khoa nay o tang atomic
*                                       (isin_code cho HNX/UPCOM/FDS, symbol cho HOSE).
*                                       snpst_dt_dim_id format truc tiep tu trade_dt (khong
*                                       join dtm_cdr_dt_dim), dung quy uoc chung GSTT.
*                                       foreign_buy_val_at_min/foreign_sell_val_at_min tinh
*                                       bang SUM(CASE WHEN ...) 1 lan quet thay vi 2 INNER
*                                       JOIN rieng nhu LLD viet literal - tuong duong ve mat
*                                       so hoc, tranh quet atm_securities_trade 2 lan.
*                                       LUU Y VAN HANH: bang nay grain rat min (per-minute),
*                                       khoi luong du lieu lon hon nhieu so cac Fact "_snpst"
*                                       theo-ngay khac - da duoc Design xac nhan van can
*                                       (truoc do danh gia khong dung, nay xac nhan lai can).
* 2026-10-12		tuan.nguyenvanb		[LLD GSTT d1e944ee, O_GSTT_41 muc 4] VIET LAI: nguon Security Trading Snapshot (MDDS
*                                       JAD_STOCKINFOR) thay Securities Trade. GT NDTNN mua/ban LUY KE cuoi phut (snapshot cuoi
*                                       phut theo trading_tms, sequence), carry-forward phut trong; lookup dim theo symbol.
*                                       Khong doi cot/kieu -> khong ALTER fact/flat. Can atomic co foreign_buy_val/foreign_sell_val.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[VIET LAI, LLD v4.56-v4.57, BA STT 25/26 'lay theo so lenh'] Nguon QUAY LAI Securities Trade (atm_securities_trade)
*                                       thay Security Trading Snapshot (2026-10-12). foreign_buy/sell_val_at_min = Σ execution_val PHAT SINH trong phut
*                                       (khong con LUY KE) -> cong duoc theo thoi gian; NDTNN = SUBSTR(buy/sell_account_nbr,4,1) IN ('F','E');
*                                       phut khong co lenh khop KHONG phat sinh dong (bo carry-forward/spine). Market ID UPX,STX,STK,STO;
*                                       src HOSE/HNX trade book. trade_minute_tms = DATE_TRUNC('minute', trade_tms) (atomic da noi trade_dt + trade_time;
*                                       CANH BAO dinh dang trade_time HNX 9 ky tu - xem atm_securities_trade_ordertrade_trade_book_hnx - O_GSTT_75).
*                                       Lookup dim: khop theo trade_join_symbol (floor 02/04/03 -> isin_code, con lai -> symbol) nhu cac Fact so lenh.
*                                       Khong doi cot/kieu -> khong ALTER fact/flat.
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78 muc c] BA STT 25/26 quay lai JAD_STOCKINFOR foreignBuyVal/foreignSellVal: DAO LAI sua doi 2026-10-22,
*                                       khoi phuc nguon atm_security_trading_snapshot (GT NDTNN LUY KE tai cuoi moi phut, carry-forward phut khong co snapshot),
*                                       khong con doc atm_securities_trade. Khop dim theo symbol. Khong doi cot/kieu -> khong ALTER.
*--------------------------------------------------------------------*
*/

-- [LLD GSTT d1e944ee 2026-10-12, O_GSTT_41 muc 4] Nguon doi tu Securities Trade sang Security Trading Snapshot
-- (MDDS JAD_STOCKINFOR): GT NDTNN mua/ban LUY KE trong ngay tai CUOI moi phut, carry-forward phut khong co snapshot.
-- Moi ma sinh du cac phut tu snapshot dau tien cua ma den snapshot cuoi cung trong ngay cua cung floor_code.
WITH sts_raw AS (
    SELECT
        ticker_symbol AS symbol,
        floor_code,
        ds_snpst_dt AS trading_dt,
        date_trunc('minute', to_timestamp(concat(CAST(ds_snpst_dt AS string), ' ', trading_time))) AS trade_minute_tms,
        foreign_buy_val,
        foreign_sell_val,
        trading_time,
        sequence
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code IN ('10','02','04')
        AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- Snapshot cuoi cung trong phut (LLD: MAX_BY(..., trading_time); thu tu phu sequence giong BA)
min_snap AS (
    SELECT symbol, floor_code, trading_dt, trade_minute_tms, foreign_buy_val, foreign_sell_val
    FROM (
        SELECT
            sts_raw.*,
            row_number() over (
                partition by symbol, trading_dt, trade_minute_tms
                order by trading_time desc, sequence desc
            ) AS rn
        FROM sts_raw
        WHERE trade_minute_tms IS NOT NULL
    ) x
    WHERE rn = 1
),

-- Pham vi phut: dau = phut snapshot dau tien cua ma, cuoi = phut snapshot cuoi cung cua san trong ngay
sym_rng AS (
    SELECT symbol, trading_dt, MAX(floor_code) AS floor_code, MIN(trade_minute_tms) AS first_min
    FROM min_snap
    GROUP BY symbol, trading_dt
),

floor_rng AS (
    SELECT floor_code, trading_dt, MAX(trade_minute_tms) AS last_min
    FROM min_snap
    GROUP BY floor_code, trading_dt
),

spine AS (
    SELECT /*+ BROADCAST(f) */
        s.symbol,
        s.trading_dt,
        m.trade_minute_tms
    FROM sym_rng s
    JOIN floor_rng f
        ON  f.floor_code = s.floor_code
        AND f.trading_dt = s.trading_dt
    LATERAL VIEW explode(sequence(s.first_min, f.last_min, interval 1 minute)) m AS trade_minute_tms
),

-- Carry-forward: phut khong co snapshot lay gia tri gan nhat truoc do
filled AS (
    SELECT
        sp.symbol,
        sp.trading_dt,
        sp.trade_minute_tms,
        last(ms.foreign_buy_val, true) OVER (
            PARTITION BY sp.symbol, sp.trading_dt ORDER BY sp.trade_minute_tms
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS foreign_buy_val_at_min,
        last(ms.foreign_sell_val, true) OVER (
            PARTITION BY sp.symbol, sp.trading_dt ORDER BY sp.trade_minute_tms
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS foreign_sell_val_at_min
    FROM spine sp
    LEFT JOIN min_snap ms
        ON  ms.symbol = sp.symbol
        AND ms.trading_dt = sp.trading_dt
        AND ms.trade_minute_tms = sp.trade_minute_tms
),

-- LLD moi: LOOKUP dim theo symbol (bo quy tac khop ISIN cua nguon Securities Trade)
se_tr_sn_di AS (
    SELECT security_trading_snpst_dim_id, symbol
    FROM (
        SELECT security_trading_snpst_dim_id, symbol,
               row_number() over (partition by symbol order by security_trading_snpst_dim_id) AS rn
        FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
    ) x
    WHERE rn = 1
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)       AS security_trading_snpst_dim_id,
    CAST(date_format(filled.trading_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(filled.trade_minute_tms AS timestamp)                       AS trade_minute_tms,
    CAST(filled.foreign_buy_val_at_min AS decimal(23,2))             AS foreign_buy_val_at_min,
    CAST(filled.foreign_sell_val_at_min AS decimal(23,2))            AS foreign_sell_val_at_min
FROM filled
LEFT JOIN se_tr_sn_di
    ON se_tr_sn_di.symbol = filled.symbol
