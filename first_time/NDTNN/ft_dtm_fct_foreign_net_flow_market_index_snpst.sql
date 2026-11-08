-- [FIRST-TIME] ft_dtm_fct_foreign_net_flow_market_index_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_foreign_net_flow_market_index_snpst (config ft_target='fct_foreign_net_flow_market_index_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_net_flow_market_index_snpst
* Program name: Fact Foreign Net Flow Market Index Snapshot
* Created by: tuan.nguyenvanb
* Created date: 2026-09-24
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-26		nghia.le			[FIX] Khoi phuc stock_tp_code IN ('1','2','3','6') theo dung etl_logic LLD,
*									dong bo voi daily (xem ghi chu 2026-10-26 o dtm_fct_foreign_net_flow_market_index_snpst.sql).
* 2026-10-17		nghia.le			[FIX] Bo gia tri '6' khoi filter stock_tp_code IN ('1','2','3','6') -> ('1','2','3')
*									khop dung LLD, dong bo voi daily. [REVERTED 2026-10-26 - xem ghi chu tren]
* 2026-10-05		tuan.nguyenvanb		Dong bo theo LLD: foreign_buy_val/foreign_sell_val dung
*                                       execution_val cho ca HOSE va HNX (bo execution_price *
*                                       execution_vol); 6 cot Currency Amount decimal(23,2);
*                                       them dieu kien sts.trading_dt = se_tr.trade_dt.
* 2026-10-05		tuan.nguyenvanb		Dong bo theo LLD: implement foreign_net_capital_flow_mtd_amt
*                                       tu Atomic FIMS bao cao dong (fir_value/fir_structure/
*                                       foreign_investor_report) thay cho CAST(NULL).
* 2026-10-12		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao - nap toan bo lich su trong 1 lan, moi
*                                       ngay 1 dong / 1 partition snpst_dt_dim_id nhu daily:
*                                       - Bo loc etl_date o securities_trade, security_trading_snapshot,
*                                         market_index_snapshot, cdr_dt_dim.
*                                       - atm_security_trading_snapshot: dung ds_snpst_dt (= ngay giao dich)
*                                         nhu ban daily da sua (atomic moi 2026-10-09 bo trading_dt).
*                                       - Gop truoc securities_trade theo (trade_dt, src_stm_code,
*                                         security_symbol_code); JOIN co OR tach thanh 2 JOIN bang theo
*                                         san (HOSE-symbol / HNX-isin_code, loai tru nhau) roi UNION ALL.
*                                         Ket qua SUM khong doi.
*                                       - foreign_net_capital_flow_mtd_amt tinh RIENG cho tung ngay D:
*                                         SUM IBOU9 co submission_dt tu dau thang cua D den D (daily
*                                         CROSS JOIN 1 dong cho dung etl_date).
*                                       - dtm_market_index_dim doc bang MAIN thay vi _hstr tai etl_date.
* 2026-10-16		nghia.le			[DONG BO DAILY 2026-10-14 — K_35 -> CLICKHOUSE] BO tinh foreign_net_capital_flow_mtd_amt o mart (cot giu lai, de NULL):
*                                       K_NDTNN_35 tinh tren ClickHouse tu flat bao cao (03_kpi_queries.sql, query net-flow-vn-index).
*                                       Bo cac CTE fi_va/fi_st/fo_in_re/ca_fl_day (khong con quet atm_fir_value).
*--------------------------------------------------------------------*
* Ghi chu:
* - Fact rieng Nhom 5 (NDTNN), doc thang Atomic securities_trade +
*   security_trading_snapshot + market_index_snapshot, khong phu thuoc
*   fct_securities_foreign_trading_snpst (Nhom 2) hay fct_market_index_snpst
*   (QLKD) - xem Datamart/hld/DTM_NDTNN_HLD.md Nhom 5.
* - foreign_buy_val/foreign_sell_val: dung execution_val cho ca HOSE va HNX
*   (Atomic securities_trade da tinh san execution_val cho HNX) - theo LLD
*   [SUA 2026-09-25]. NDTNN = buy/sell_foreign_investor_tp_code IN ('10','20')
*   ca 2 san.
* - JOIN security_trading_snapshot ban ghi trading_time moi nhat theo
*   symbol x trading_dt (HOSE noi symbol, HNX noi isin_code).
* - market_index_dim_id: lookup TINH theo market_id='10'/market_code='HOSE',
*   khong dieu kien ngay - dam bao FK not null ke ca khi feed MDDS thieu ban
*   ghi hom do.
* - foreign_net_capital_flow_mtd_amt: SUM fir_value.val_raw (ep so) bao cao
*   IBOU9, cot 'Gia tri dong von vao trong ky bao cao (+/-) (don vi USD)',
*   dong 'Tong= (1) + (2)', submission_dt tu dau thang den ngay snapshot. Don
*   vi USD (khac VND cua 2 series con lai).
*   TODO (O_NDTNN_33/38): quy tac 'uu tien ban ky nua thang, bo ban ngay co ky
*   nam trong ban nua thang cung thang' chua chot - chua ap dung.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','20') THEN execution_val ELSE 0 END)  AS foreign_buy_val
        , SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_val ELSE 0 END) AS foreign_sell_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    -- [FT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY trade_dt, src_stm_code, security_symbol_code
),

sts_all AS (
    SELECT
        ticker_symbol
        , isin_code
        , ds_snpst_dt
        --, trading_dt
        , row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time DESC, sequence DESC) as rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    -- [FT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    --     AND stock_tp_code IN ('1','2','3','6')
    WHERE stock_tp_code IN ('1','2','3','6')   -- [FT-NEW]
),

sts AS (
    SELECT
        ticker_symbol
        , isin_code
        , ds_snpst_dt
    FROM sts_all
    WHERE rn = 1
),

-- [FT-ORIG] JOIN 1 lan voi dieu kien (HOSE AND symbol) OR (HNX AND isin_code). [FT-NEW] Tach thanh 2 JOIN bang roi
-- UNION ALL: 2 nhanh loai tru nhau theo src_stm_code nen tong khong doi, tranh JOIN OR tren nhieu nam du lieu.
trade_match AS (
    SELECT se_tr.trade_dt, se_tr.foreign_buy_val, se_tr.foreign_sell_val
    FROM se_tr
    INNER JOIN sts
        ON  sts.ds_snpst_dt = se_tr.trade_dt
        AND sts.ticker_symbol = se_tr.security_symbol_code
    WHERE se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'
    UNION ALL
    SELECT se_tr.trade_dt, se_tr.foreign_buy_val, se_tr.foreign_sell_val
    FROM se_tr
    INNER JOIN sts
        ON  sts.ds_snpst_dt = se_tr.trade_dt
        AND sts.isin_code = se_tr.security_symbol_code
    WHERE se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
),

trade_agg AS (
    SELECT
        trade_dt,
        SUM(foreign_buy_val)  AS foreign_buy_val,
        SUM(foreign_sell_val) AS foreign_sell_val
    FROM trade_match
    GROUP BY trade_dt
),

mi_snpst_all AS (
    SELECT
        market_id
        , market_code
        , trading_dt
        , market_index_val
        , row_number() over (partition by market_id, market_code, trading_dt order by index_time desc) as rn
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    WHERE market_id = '10'
        AND market_code = 'HOSE'
        -- [FT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

mi_snpst AS (
    SELECT
        trading_dt
        , market_index_val
    FROM mi_snpst_all
    WHERE rn = 1
),

ma_in_di AS (
    SELECT
        market_index_dim_id
    -- [FT-ORIG] FROM {{ ref('dtm_market_index_dim') }}_hstr
    FROM {{ ft_ref('ft_dtm_market_index_dim') }}   -- [FT-NEW] bang MAIN (trang thai hien tai)
    -- [FT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    --     AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [FT-NEW]
        AND market_id = '10'
        AND market_code = 'HOSE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id
        , cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
    -- [FT-ORIG] WHERE cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

net_flow AS (
    SELECT
        COALESCE(trade_agg.trade_dt, mi_snpst.trading_dt) AS snpst_dt,
        COALESCE(trade_agg.foreign_buy_val, 0)             AS foreign_buy_val,
        COALESCE(trade_agg.foreign_sell_val, 0)            AS foreign_sell_val,
        mi_snpst.market_index_val                          AS market_index_close_val
    FROM trade_agg
    FULL OUTER JOIN mi_snpst
        ON trade_agg.trade_dt = mi_snpst.trading_dt
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                             AS snpst_dt_dim_id,
    CAST(ma_in_di.market_index_dim_id AS string)                       AS market_index_dim_id,
    CAST(net_flow.foreign_buy_val AS decimal(23,2))                    AS foreign_buy_val,
    CAST(net_flow.foreign_sell_val AS decimal(23,2))                   AS foreign_sell_val,
    CAST(net_flow.foreign_buy_val - net_flow.foreign_sell_val AS decimal(23,2)) AS foreign_net_trading_val,
    CAST(net_flow.market_index_close_val AS decimal(23,2))             AS market_index_close_val,
    CAST(NULL AS decimal(23,2))                                        AS foreign_net_capital_flow_mtd_amt   -- K_35 tinh tren ClickHouse
FROM net_flow
INNER JOIN cd_dt_di
    ON cd_dt_di.cdr_dt = net_flow.snpst_dt
CROSS JOIN ma_in_di
