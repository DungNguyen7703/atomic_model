/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_net_flow_market_index_snpst
* Program name: Fact Foreign Net Flow Market Index Snapshot
* Created by: tuan.nguyenvanb
* Created date: 2026-09-24
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-26		nghia.le			[FIX] Khoi phuc stock_tp_code IN ('1','2','3','6') theo dung cau lenh etl_logic
*									trong LLD (DTM_NDTNN_fct_foreign_net_flow_market_index_snpst.csv) - doi lai thay
*									doi 2026-10-17 (da bo '6' theo mo ta text, nhung mau thuan voi etl_logic SQL cua
*									chinh LLD; BA xac nhan etl_logic la chuan).
* 2026-10-17		nghia.le			[FIX] Bo gia tri '6' khoi filter stock_tp_code IN ('1','2','3','6') -> ('1','2','3')
*									khop dung LLD (DTM_NDTNN_fct_foreign_net_flow_market_index_snpst.csv khong co '6').
*									[REVERTED 2026-10-26 - xem ghi chu tren]
* 2026-10-05		tuan.nguyenvanb		Dong bo theo LLD: foreign_buy_val/foreign_sell_val dung
*                                       execution_val cho ca HOSE va HNX (bo execution_price *
*                                       execution_vol); 6 cot Currency Amount decimal(23,2);
*                                       them dieu kien sts.trading_dt = se_tr.trade_dt.
* 2026-10-05		tuan.nguyenvanb		Dong bo theo LLD: implement foreign_net_capital_flow_mtd_amt
*                                       tu Atomic FIMS bao cao dong (fir_value/fir_structure/
*                                       foreign_investor_report) thay cho CAST(NULL).
* 2026-10-13		nghia.le			[RULE BAO CAO DINH KY / BAT THUONG] K_NDTNN_35 (foreign_net_capital_flow_mtd_amt) tinh theo NGAY CHOT SO LIEU: bao cao dinh ky IBOU9 co ngay chot <= moc nua thang
*                                       (macro ndtnn_half_month_cutoff) + bao cao bat thuong EPW5C/V2YZM/22ZBE co ngay chot sau moc, tu dau thang den etl_date.
*                                       Thay cho SUM theo ngay nop va TODO O_NDTNN_33/38 (uu tien ky nua thang).
* 2026-10-14		nghia.le			[K_35 -> CLICKHOUSE] BO tinh foreign_net_capital_flow_mtd_amt (dong tien rong luy ke thang, K_NDTNN_35) o mart:
*                                       rule bao cao dinh ky/bat thuong phu thuoc to_date nen tinh tren ClickHouse tu flat bao cao (03_kpi_queries.sql,
*                                       query net-flow-vn-index). Cot van giu trong bang (de NULL) de khong doi cau truc.
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
* - snpst_dt_dim_id: LOOKUP dtm_cdr_dt_dim ON cdr_dt_dim.cdr_dt = COALESCE(
*   securities_trade.trade_dt, market_index_snapshot.trading_dt) AND
*   cdr_dt_dim.cdr_dt = :etl_date - dung theo LLD goc (Datamart/lld/NDTNN/
*   DTM_NDTNN_fct_foreign_net_flow_market_index_snpst.csv).
* - market_index_dim_id: lookup theo market_id='10'/market_code='HOSE' tren
*   dtm_market_index_dim_hstr VOI dieu kien ds_snpst_dt = etl_date AND
*   ds_rcrd_st = 'ACTIVE' (CTE ma_in_di) - [2026-10-17] sua lai comment cho
*   khop code: neu feed MDDS thieu ban ghi hom do, ma_in_di rong va CROSS
*   JOIN se loai toan bo dong ket qua ngay do (khong con "dam bao FK not
*   null" nhu ghi chu truoc).
* - foreign_net_capital_flow_mtd_amt: SUM fir_value.val_raw (ep so) bao cao
*   IBOU9, cot 'Gia tri dong von vao trong ky bao cao (+/-) (don vi USD)',
*   dong 'Tong= (1) + (2)', submission_dt tu dau thang den etl_date. Don vi
*   USD (khac VND cua 2 series con lai). Atomic fir_structure /
*   foreign_investor_report la SCD2: ban ghi hien hanh ds_rcrd_st = 'ACTIVE'
*   AND ds_rcrd_end_dt = to_date('2400-01-01').
*   TODO (O_NDTNN_33/38): quy tac 'uu tien ban ky nua thang, bo ban ngay co ky
*   nam trong ban nua thang cung thang' chua chot - chua ap dung, hien SUM
*   nguyen van theo cong thuc LLD.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt
        , security_symbol_code
        , src_stm_code
        , execution_val
        , buy_foreign_investor_tp_code
        , sell_foreign_investor_tp_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sts_all AS (
    SELECT
        ticker_symbol
        , isin_code
        , ds_snpst_dt
        --, trading_dt
        , row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time DESC, sequence DESC) as rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND stock_tp_code IN ('1','2','3','6')
),

sts AS (
    SELECT
        ticker_symbol
        , isin_code
        , ds_snpst_dt
    FROM sts_all
    WHERE rn = 1
),

trade_agg AS (
    SELECT
        se_tr.trade_dt,
        SUM(CASE
            WHEN se_tr.buy_foreign_investor_tp_code IN ('10','20')
                THEN se_tr.execution_val
                ELSE 0
        END) AS foreign_buy_val,
        SUM(CASE
            WHEN se_tr.sell_foreign_investor_tp_code IN ('10','20')
                THEN se_tr.execution_val
                ELSE 0
        END) AS foreign_sell_val
    FROM se_tr
    INNER JOIN sts
        ON  sts.ds_snpst_dt = se_tr.trade_dt
        AND ((se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.ticker_symbol = se_tr.security_symbol_code)
        OR   (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = se_tr.security_symbol_code))
    GROUP BY se_tr.trade_dt
),

mi_snpst_all AS (
    SELECT
        market_id
        , market_code
        , trading_dt
        , market_index_val
        , row_number() over (partition by market_id, market_code, trading_dt order by index_time desc) as rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE market_id = '10'
        AND market_code = 'HOSE'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    FROM {{ ref('dtm_market_index_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND market_id = '10'
        AND market_code = 'HOSE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id
        , cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
    WHERE cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
