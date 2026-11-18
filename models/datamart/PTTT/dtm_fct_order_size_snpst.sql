/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_order_size_snpst
* Program name: Fact Order Size Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_securities_trade duoc materialize theo strategy incremental_rebase
*   / append, partition_by trade_dt, KHONG co bang phu _hstr va KHONG co
*   cot ds_snpst_dt/ds_rcrd_st/src_stm_code kieu SCD4A -> loc truc tiep
*   theo cot trade_dt.
* - execution_val da duoc tinh san o tang atomic (= execution_price *
*   execution_vol) nen dung lai, khong tinh lai tu dau.
* - snpst_dt_dim_id tinh truc tiep bang date_format(trade_dt,'yyyyMMdd')
*   giong convention da dung o dtm_fct_penalty_decision.sql (cdr_dt_dim_id
*   cua dtm_cdr_dt_dim cung sinh ra tu cong thuc nay) thay vi JOIN vat ly
*   toi dtm_cdr_dt_dim.
*--------------------------------------------------------------------*
* 2026-10-07			tuan.nguyenvanb		Doi chieu LLD: board_tp_code doi tu G1,G2,G3 sang G1,G2,G3,G4,G7,G8
*									(LLD tu 2026-09-30) cho total_trading_val_matched/vol_matched va order_size_band.
* 2026-10-09			tuan.nguyenvanb		Ap dung LLD 2026-10-09 (O_PTTT_44, commit d39ed114): nguon chuyen tu
*									atm_securities_trade sang atm_security_trading_snapshot (ban ghi trading_time
*									moi nhat moi ma/ngay): security_symbol_code = snapshot.symbol,
*									total_trading_val_matched = snapshot.total_trading_val, total_trading_vol_matched
*									= snapshot.total_trading_vol, loc floor_code IN ('02','04','10'), BO loc board
*									G1..G8 va market_id_code (thay doi 2026-10-07 ve board khong con ap dung).
*									order_size_band giu nguyen (GTGD >= 1 ty).
* 2026-10-10			tuan.nguyenvanb		LOI UNRESOLVED_COLUMN trading_dt: bang atomic atm_security_trading_snapshot hien
*									KHONG con cot trading_dt (file atomic sua 2026-10-09 19:32) -> doc ngay giao dich
*									tu ds_snpst_dt (= tradingdate vi ODS loc TRADINGDATE = etl_date), dat alias
*									trading_dt de cac CTE phia sau khong doi.
* 2026-10-13			tuan.nguyenvanb		Chon ban tin cuoi ngay cua atm_security_trading_snapshot theo
*									ORDER BY trading_time DESC, sequence DESC (giong cau BA: tradingtime desc, sequence
*									desc) thay cho trading_tms DESC. Cot sequence moi bo sung o atomic 2026-10-12.
* 2026-10-14			tuan.nguyenvanb		Ap dung LLD commit 23f0c8aa (O_PTTT_49, issue QA): quy mo lenh phan loai TUNG GIAO DICH
*									khop tu atm_securities_trade (execution_val >= 1 ty) thay cho GTGD ca ngay cua ma
*									(snapshot.total_trading_val). total_trading_val_matched/total_trading_vol_matched = SUM(execution_val/
*									execution_vol) GROUP BY ma, band, ngay; chi loc market_id_code IN ('STK','STX','UPX') (khong loc board,
*									SQL BA Nhom 11). security_symbol_code = COALESCE(snapshot.symbol, securities_trade.security_symbol_code):
*									HOSE noi theo symbol, HNX noi theo isin_code (A17), LEFT JOIN de khong roi giao dich khong co trong snapshot.
*									Join 1 equi-key (src_stm_code, join_key) thay cho OR de tranh nested loop join. Grain moi: 1 dong / (ma, band,
*									ngay). Khong doi cot/kieu du lieu nen khong can ALTER. A19: moi nguon deu bi chan theo trade_dt/trading_dt = etl_date.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*/

WITH sts_raw AS (
    SELECT
        ticker_symbol AS symbol
        , isin_code
        , ds_snpst_dt AS trading_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- A17: HOSE noi theo symbol, HNX noi theo isin_code -> khoa phu join_key (equi-join, khong dung OR)
sts_key AS (
    SELECT
        trading_dt
        , symbol
        , CAST('ORDERTRADE_TRADE_BOOK_HOSE' AS string) AS src_stm_code
        , symbol                                       AS join_key
    FROM sts_raw
    WHERE rn = 1
    UNION ALL
    SELECT
        trading_dt
        , symbol
        , CAST('ORDERTRADE_TRADE_BOOK_HNX' AS string)  AS src_stm_code
        , isin_code                                    AS join_key
    FROM sts_raw
    WHERE rn = 1
        AND isin_code IS NOT NULL
),

se_tr AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , execution_val
        , execution_vol
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code IN ('STK','STX','UPX')
),

agg AS (
    SELECT
        se_tr.trade_dt                                                          AS trading_dt
        , COALESCE(sts_key.symbol, se_tr.security_symbol_code)                  AS symbol
        , CASE
            WHEN se_tr.execution_val >= 1000000000 THEN 'GTGD >= 1 ty'
            ELSE 'GTGD < 1 ty'
          END                                                                   AS order_size_band
        , SUM(se_tr.execution_val)                                              AS total_trading_val_matched
        , SUM(se_tr.execution_vol)                                              AS total_trading_vol_matched
    FROM se_tr
    LEFT JOIN sts_key
        ON sts_key.src_stm_code = se_tr.src_stm_code
        AND sts_key.join_key = se_tr.security_symbol_code
        AND sts_key.trading_dt = se_tr.trade_dt
    GROUP BY
        se_tr.trade_dt
        , COALESCE(sts_key.symbol, se_tr.security_symbol_code)
        , CASE
            WHEN se_tr.execution_val >= 1000000000 THEN 'GTGD >= 1 ty'
            ELSE 'GTGD < 1 ty'
          END
)

SELECT
    CAST(date_format(agg.trading_dt, 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(agg.symbol AS string)                                     AS security_symbol_code,
    CAST(agg.total_trading_val_matched AS decimal(23,2))           AS total_trading_val_matched,
    CAST(agg.order_size_band AS string)                            AS order_size_band,
    CAST(agg.total_trading_vol_matched AS decimal(23,2))           AS total_trading_vol_matched
FROM agg
