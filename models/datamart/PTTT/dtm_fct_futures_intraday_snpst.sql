/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_futures_intraday_snpst
* Program name: Fact Futures Intraday Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Grain: 1 row / ma HDTL (hop dong tuong lai) / ngay (moc thoi gian
*   giam luoc ve grain ngay, giong cac fact khac trong PTTT).
* - atm_security_trading_snapshot duoc materialize theo strategy
*   incremental_rebase/snapshot, partition_by trading_dt. KHONG phai
*   SCD4A nen KHONG co bang phu _hstr va KHONG co cot ds_rcrd_st ->
*   loc truc tiep theo cot trading_dt.
* - atm_securities_trade duoc materialize theo incremental_rebase/append,
*   partition_by trade_dt, KHONG co bang phu _hstr -> loc truc tiep theo
*   trade_dt.
* - HDTL duoc xac dinh bang dieu kien stock_tp_code = '4' AND floor_code='03'
*   tren atm_security_trading_snapshot; giao dich khop lenh HDTL duoc loc
*   theo market_id_code='DVX' tren atm_securities_trade.
* - Cac cot underlying_symbol va maturity_month_year DA TON TAI san tren
*   atm_security_trading_snapshot (khong can PENDING nhu gia dinh ban dau
*   trong yeu cau — da xac nhan lai qua doc file atomic that).
* - reference_price cung DA TON TAI san (cot 'reference' cua nguon
*   MDDS_JAD_STOCKINFOR, alias reference_price) -> khong PENDING.
* - total_trading_vol_matched_average_50_days can du lich su 50 ngay giao
*   dich gan nhat de tinh rolling window, nen 2 CTE trung gian
*   (se_tr_snpst_hist, tr_hist) KHONG loc chi 1 ngay etl_date ma loc
*   trading_dt/trade_dt <= etl_date; chi loc dung etl_date o buoc cuoi
*   cung (final) khi gan nhan data_dt.
* - snpst_dt_dim_id tinh truc tiep bang date_format(trading_dt,'yyyyMMdd')
*   thay vi JOIN vat ly toi dtm_cdr_dt_dim, giong convention da dung o
*   dtm_fct_order_size_snpst.sql.
* - [2026-09-23 doi chieu LLD] Bo sung cot open_interest_quantity (LLD
*   dong 12) - truoc day BI THIEU trong model. Nguon atm_end_of_day_open_
*   interest DA XAC NHAN TON TAI (models/atomic/arrangement). Atomic nay
*   tu loc san theo ds_snpst_dt = etl_date va KHONG xuat cot ds_snpst_dt
*   o output nen chi LEFT JOIN truc tiep theo ticker_symbol = symbol (khong
*   can dieu kien ngay o ngoai, atomic da dam bao chi co dung 1 ngay).
*--------------------------------------------------------------------*
* 2026-10-09			tuan.nguyenvanb		Ap dung LLD 2026-10-09 (commit d39ed114): chi lay ban ghi trading_time
*									moi nhat moi ma/ngay (dung grain 1 dong/ma HDTL/ngay); total_trading_vol_matched
*									= snapshot.total_trading_vol (KL khop cong don) thay SUM(execution_vol) tu
*									atm_securities_trade (market_id_code DVX) - BO nguon securities_trade.
*									MA50 tinh tren total_trading_vol_matched moi (LLD khong doi cong thuc).
* 2026-10-10			tuan.nguyenvanb		LOI UNRESOLVED_COLUMN trading_dt: bang atomic atm_security_trading_snapshot hien
*									KHONG con cot trading_dt (file atomic sua 2026-10-09 19:32) -> doc ngay giao dich
*									tu ds_snpst_dt (= tradingdate vi ODS loc TRADINGDATE = etl_date), dat alias
*									trading_dt de cac CTE phia sau khong doi.
* 2026-10-16			tuan.nguyenvanb		Ap dung LLD 2026-10-16 (commit 6d70c62a, O_PTTT_50, BA chot): total_trading_vol_matched
*									quay lai so lenh HNX: COALESCE(SUM(securities_trade.execution_vol), 0) voi
*									market_id_code = 'DVX', src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' (gom khop lenh va
*									thoa thuan), ma HDTL khong co giao dich = 0. Ma/thang dao han/tai san co so/gia van lay
*									tu ban ghi cuoi ngay cua security_trading_snapshot. Khoa noi ho tro symbol va isin_code
*									(A17) bang bang khoa phu fut_key (UNION) + equi-join thay cho OR. MA50 va
*									liquidity_spike_ratio tu dong tinh tren KLGD moi. Cot sequence/isin_code lay tu atomic.
* 2026-10-17			tuan.nguyenvanb		Ap dung LLD commit e1a975c2 (O_PTTT_50, chot noi bang ISIN): so lenh DVX noi voi hop
*									dong CHI bang security_symbol_code = security_trading_snapshot.isin_code (Issue Code cua
*									so lenh = ISIN cua MDDS), BO noi bang ma giao dich (symbol) va BO bang khoa phu fut_key.
* 2026-10-19			tuan.nguyenvanb		Ap dung LLD commit 85518333 (ACT-P1-07): open_interest_quantity noi end_of_day_open_interest theo
*									ticker_symbol = symbol AND rpt_dt = trading_dt (truoc day noi chi theo ticker, khong loc ngay -> nhan dong theo
*									so snapshot). Them dedupe (ticker, rpt_dt) theo ds_snpst_dt DESC. Khong doi cot output nen khong can ALTER.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*/

WITH se_tr_snpst_hist_raw AS (
    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , underlying_symbol
        , maturity_month_year
        , close_price
        , reference_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND stock_tp_code = '4'
        AND floor_code = '03'
),

-- [LLD 2026-10-16, O_PTTT_50] Driving = ban ghi cuoi ngay (trading_time moi nhat) cua ma HDTL
-- trong security_trading_snapshot: ma, thang dao han, tai san co so, gia
fut_snpst AS (
    SELECT trading_dt, symbol, isin_code, underlying_symbol, maturity_month_year, close_price, reference_price
    FROM se_tr_snpst_hist_raw
    WHERE rn = 1
),

-- KLGD HDTL theo so lenh HNX (thi truong phai sinh, Market ID DVX), gom khop lenh va thoa thuan
tr_hist AS (
    SELECT
        trade_dt
        , security_symbol_code
        , SUM(execution_vol) AS vol
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code = 'DVX'
        AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
    GROUP BY trade_dt, security_symbol_code
),

-- [LLD 2026-10-17, O_PTTT_50] noi so lenh voi hop dong CHI BANG ISIN: Issue Code cua so lenh
-- (securities_trade.security_symbol_code) = security_trading_snapshot.isin_code, KHONG noi bang ma giao dich
tr_by_contract AS (
    SELECT
        fut_snpst.trading_dt
        , fut_snpst.symbol
        , SUM(tr_hist.vol) AS total_trading_vol_matched
    FROM fut_snpst
    INNER JOIN tr_hist
        ON tr_hist.trade_dt = fut_snpst.trading_dt
        AND tr_hist.security_symbol_code = fut_snpst.isin_code
    GROUP BY fut_snpst.trading_dt, fut_snpst.symbol
),

joined_hist AS (
    SELECT
        fut_snpst.trading_dt
        , fut_snpst.symbol
        , fut_snpst.underlying_symbol
        , fut_snpst.maturity_month_year
        , fut_snpst.close_price
        , fut_snpst.reference_price
        , COALESCE(tr_by_contract.total_trading_vol_matched, 0) AS total_trading_vol_matched
    FROM fut_snpst
    LEFT JOIN tr_by_contract
        ON tr_by_contract.trading_dt = fut_snpst.trading_dt
        AND tr_by_contract.symbol = fut_snpst.symbol
),

windowed AS (
    SELECT
        joined_hist.*
        , AVG(joined_hist.total_trading_vol_matched) OVER (
            PARTITION BY joined_hist.symbol
            ORDER BY joined_hist.trading_dt
            ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS total_trading_vol_matched_average_50_days
    FROM joined_hist
),

-- [LLD 85518333, ACT-P1-07] noi OI theo ngay NGHIEP VU rpt_dt (khong dung cot ky thuat ds_snpst_dt); ROW_NUMBER
-- chong nhan dong neu (ticker, rpt_dt) co o nhieu snapshot.
eo_oi_all AS (
    SELECT
        ticker_symbol
        , rpt_dt
        , open_interest_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, rpt_dt ORDER BY ds_snpst_dt DESC) AS rn
    FROM {{ ref('atm_end_of_day_open_interest') }}
    WHERE rpt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

eo_oi AS (
    SELECT ticker_symbol, rpt_dt, open_interest_quantity
    FROM eo_oi_all
    WHERE rn = 1
)

SELECT
    CAST(date_format(windowed.trading_dt, 'yyyyMMdd') AS string)                     AS snpst_dt_dim_id,
    CAST(windowed.symbol AS string)                                                   AS security_symbol_code,
    CAST(windowed.underlying_symbol AS string)                                        AS underlying_symbol,
    CAST(windowed.maturity_month_year AS string)                                      AS maturity_month_year,
    CAST(windowed.close_price AS decimal(23,2))                                       AS close_price,
    CAST(windowed.reference_price AS decimal(23,2))                                   AS reference_price,
    CAST(
        (windowed.close_price - windowed.reference_price)
        / NULLIF(windowed.reference_price, 0) * 100
    AS decimal(5,2))                                                                  AS price_change_percentage,
    CAST(windowed.total_trading_vol_matched AS decimal(23,2))                         AS total_trading_vol_matched,
    CAST(windowed.total_trading_vol_matched_average_50_days AS decimal(23,2))         AS total_trading_vol_matched_average_50_days,
    CAST(
        windowed.total_trading_vol_matched
        / NULLIF(windowed.total_trading_vol_matched_average_50_days, 0) * 100
    AS decimal(5,2))                                                                  AS liquidity_spike_ratio,
    CAST(eo_oi.open_interest_quantity AS bigint)                                      AS open_interest_quantity
FROM windowed
LEFT JOIN eo_oi
    ON eo_oi.ticker_symbol = windowed.symbol
    AND eo_oi.rpt_dt = windowed.trading_dt
WHERE windowed.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
