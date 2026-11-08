/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_category_index_trading_snpst
* Program name: Dtm Fct Investor Category Index Trading Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-23
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-25		tuan.nguyenvanb		[LLD moi tu Data Modeler, dung y het fct_investor_
*                                       category_trading_snpst] TU_DOANH/NUOC_NGOAI la 2
*                                       co doc lap co the chong lap; TO_CHUC_TRONG_NUOC =
*                                       [foreign='00' AND investor_tp<>'8000'] TRU [tu_doanh]
*                                       (khong phai phan du don gian nua). Xem changelog day
*                                       du tai dtm_fct_investor_category_trading_snpst.sql.
* 2026-09-23		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_investor_category_index_
*                                       trading_snpst.csv] Fact GD theo Phan loai NDT
*                                       (CA_NHAN/TO_CHUC_TRONG_NUOC/TU_DOANH/NUOC_NGOAI) CUA
*                                       CA RO CHI SO (khac dtm_fct_investor_category_trading_
*                                       snpst - grain theo TUNG MA). Driving: index_constituent_
*                                       snapshot (rổ mã thanh vien cua chi so trong ngay).
*                                       Logic phan loai buy/sell DUNG Y HET fct_investor_
*                                       category_trading_snpst (khong phan nhanh src_stm_code,
*                                       Tu doanh -> Nuoc ngoai <>'00' -> Ca nhan ='8000' -> con
*                                       lai To chuc trong nuoc). matched_/negotiated_ tach theo
*                                       board_tp_code, cung quy uoc voi cac Fact GSTT khac.
*                                       Them 3 cot diem chi so (market_index_val/index_change/
*                                       index_percent_change) tu atm_market_index_snapshot,
*                                       ban ghi cuoi phien (ROW_NUMBER theo index_time DESC) -
*                                       gia tri chung cua ca ro, lap lai tren ca 4 dong
*                                       investor_category_code.
* 2026-10-12		tuan.nguyenvanb		FIX NHAN DONG: index_constituent_symbols join atomic stockinfor (MOI ban tin trong ngay)
*                                       va csidxinfor (co the nhieu ban tin / thanh vien) khong dedupe -> moi lenh khop bi nhan
*                                       N lan, buy/sell_val cong thua va job first-time treo. Dedupe: ics DISTINCT (ro, ma, ngay);
*                                       sts 1 dong / (ma, ngay) theo trading_tms desc, sequence desc. Khong doi cot.
* 2026-10-15		tuan.nguyenvanb		[SUA, LLD v4.49 BA cap nhat phan loai NDT] Moi phia mua hoac ban phan loai DOC LAP theo
*                                       so tai khoan: TU_DOANH la ky tu thu 4 cua so TK thuoc P hoac E; NUOC_NGOAI la ky tu thu 4
*                                       thuoc F hoac E; CA_NHAN la investment_account (ban ghi moi nhat theo event_dt) co
*                                       investment_account_tp_code = 3; TO_CHUC_TRONG_NUOC = 5 (truc tiep, bo phep tru). Cac phan
*                                       loai khong loai tru nhau (TK loai E tinh ca TU_DOANH va NUOC_NGOAI). Thay quy tac cu
*                                       dung client_house, foreign_investor, investor_tp. Market ID doi thanh UPX, STX, STK, STO.
*                                       Nguon moi: atm_investment_account (VSDC open_investors). Cot khong doi.
* 2026-10-16		tuan.nguyenvanb		[LLD v4.5x - K_GSTT_376/377/378] Them 2 cot buy_vol, sell_vol (bigint) = KL mua/ban theo phan loai NDT
*                                       (khop lenh + thoa thuan), cung quy tac phan loai voi buy_val/sell_val (SUM execution_vol).
*                                       buy_vol chen SAU buy_val, sell_vol chen SAU sell_val -> ALTER ... AFTER (insert theo vi tri).
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[SUA, LLD v4.56-v4.57, O_GSTT_75] Phan loai LOAI TRU NHAU theo thu tu uu tien Nuoc ngoai (ky tu thu 4 IN F,E)
*                                       -> Tu doanh (chi con 'P', TK loai 'E' chi tinh Nuoc ngoai) -> Ca nhan (tp=3) -> To chuc (tp=5); Ca nhan/To chuc
*                                       chi khi ky tu thu 4 NOT IN (F,E,P). Nguon open_investor_account = atm_investment_account (khong doi). LLD index
*                                       van 4 phan loai (khong them KHONG_XAC_DINH). Khong doi cot/kieu -> khong ALTER.
*--------------------------------------------------------------------*
* 2026-10-22		tuan.nguyenvanb		[DOI THEO CAU TEST BA, thay quy tac loai tru 2026-10-22 truoc do] Phan loai NDT DOC LAP nhu BA: Tu doanh = ky tu thu 4 IN ('P','E'); Nuoc ngoai = IN ('F','E'); Ca nhan = loai NDT '3', To chuc = '5' (khong xet ky tu thu 4) - mot lenh co the tinh vao nhieu nhom (TK loai E vua Tu doanh vua Nuoc ngoai). Pham vi sua: ca nhan/to chuc theo loai NDT khong xet ky tu thu 4. Khong doi cot. CAN DONG BO LLD O_GSTT_75 (LLD dang ghi loai tru nhau).
* 2026-10-25		tuan.nguyenvanb		[DOI NGUON ATOMIC] Bo atm_investment_account (model tam), doc atm_open_investor_account (cung nguon VSDC open_investors).
*                                       Doi cot: investment_account_nbr -> investor_account_nbr, investment_account_tp_code (string) -> investor_tp_code (int, so sanh bang so),
*                                       event_dt -> open_dt. Cot output cua model khong doi -> khong ALTER mart/ClickHouse.
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
*/

WITH index_dim AS (
    SELECT
        index_constituent_dim_id,
        index_code
    FROM {{ ref('dtm_index_constituent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Ro ma thanh vien cua tung chi so trong ngay, kem floor_code/isin_code de map sang
-- khoa join securities_trade (quy uoc chung GSTT: floor 02/04/03 dung isin_code, floor 10
-- dung symbol thuong).
-- [2026-10-12] 1 dong / (ro, ma, ngay) - csidxinfor co the co nhieu ban tin cho cung 1 thanh vien
ics_dedup AS (
    SELECT DISTINCT
        index_code,
        trading_dt,
        ticker_symbol AS symbol
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- [2026-10-12] 1 dong / (ma, ngay): ban tin cuoi ngay - chi dung tra san / ISIN, khong duoc nhan dong
sts_dedup AS (
    SELECT symbol, trading_dt, floor_code, isin_code
    FROM (
        SELECT
            ticker_symbol AS symbol,
            ds_snpst_dt AS trading_dt,   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
            floor_code,
            isin_code,
            row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) AS rn
        FROM {{ ref('atm_security_trading_snapshot') }}
        WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
            AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ) x
    WHERE rn = 1
),

index_constituent_symbols AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        ics.symbol,
        CASE WHEN sts.floor_code IN ('02','04','03') THEN sts.isin_code ELSE ics.symbol END AS trade_join_symbol
    FROM ics_dedup ics
    INNER JOIN sts_dedup sts
        ON  sts.symbol = ics.symbol
        AND sts.trading_dt = ics.trading_dt
),

-- [SUA 2026-09-25, LLD moi tu Data Modeler, dung y het fct_investor_category_trading_snpst]
-- TU_DOANH/NUOC_NGOAI la 2 CO DOC LAP co the CHONG LAP nhau; CA_NHAN la phan du loai tru
-- ca 2; TO_CHUC_TRONG_NUOC = [foreign='00' AND investor_tp<>'8000'] TRU [tu_doanh] (khong
-- phai phan du don gian - xem changelog day du tai dtm_fct_investor_category_trading_snpst).
-- [SUA 2026-10-15, LLD v4.49] Ca nhan va To chuc trong nuoc phan loai theo atomic investment_account (VSDC open_investors):
-- lay ban ghi MOI NHAT theo event_dt cua tung so tai khoan (bang nguon bi trung).
inv_acc AS (
    SELECT investor_account_nbr, investor_tp_code
    FROM (
        SELECT
            investor_account_nbr,
            investor_tp_code,
            ROW_NUMBER() OVER (PARTITION BY investor_account_nbr ORDER BY open_dt DESC) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE investor_account_nbr IS NOT NULL
    ) x
    WHERE rn = 1
),

se_tr AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        st.execution_vol,
        st.execution_val,
        st.board_tp_code,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS buy_is_td,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS buy_is_nn,
        CASE WHEN ia_buy.investor_tp_code = 3 THEN 1 ELSE 0 END AS buy_is_cn,
        CASE WHEN ia_buy.investor_tp_code = 5 THEN 1 ELSE 0 END AS buy_is_tc,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS sell_is_td,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS sell_is_nn,
        CASE WHEN ia_sell.investor_tp_code = 3 THEN 1 ELSE 0 END AS sell_is_cn,
        CASE WHEN ia_sell.investor_tp_code = 5 THEN 1 ELSE 0 END AS sell_is_tc
    FROM index_constituent_symbols ics
    INNER JOIN {{ ref('atm_securities_trade') }} st
        ON  st.security_symbol_code = ics.trade_join_symbol
        AND st.trade_dt = ics.trading_dt
        AND st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    LEFT JOIN inv_acc ia_buy
        ON ia_buy.investor_account_nbr = st.buy_account_nbr
    LEFT JOIN inv_acc ia_sell
        ON ia_sell.investor_account_nbr = st.sell_account_nbr
),

-- 4 dong Phan loai NDT co dinh / chi so / ngay - dung CROSS JOIN VALUES nhu LLD.
investor_category AS (
    SELECT investor_category_code
    FROM (VALUES ('CA_NHAN'),('TO_CHUC_TRONG_NUOC'),('TU_DOANH'),('NUOC_NGOAI')) AS t(investor_category_code)
),

idx_cat AS (
    SELECT
        t.index_code,
        t.trading_dt,
        c.investor_category_code,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc ELSE 0 END) * t.execution_val) AS buy_val,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc ELSE 0 END) * t.execution_vol) AS buy_vol,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc ELSE 0 END) * t.execution_val) AS sell_val,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc ELSE 0 END) * t.execution_vol) AS sell_vol,
        SUM(CASE WHEN t.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc ELSE 0 END) * t.execution_val ELSE 0 END) AS matched_buy_val,
        SUM(CASE WHEN t.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc ELSE 0 END) * t.execution_val ELSE 0 END) AS matched_sell_val,
        SUM(CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc ELSE 0 END) * t.execution_val ELSE 0 END) AS negotiated_buy_val,
        SUM(CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc ELSE 0 END) * t.execution_val ELSE 0 END) AS negotiated_sell_val
    FROM se_tr t
    CROSS JOIN investor_category c
    GROUP BY t.index_code, t.trading_dt, c.investor_category_code
),

-- Diem chi so ban ghi cuoi phien trong ngay - gia tri chung cua ca ro, lap lai tren
-- ca 4 dong investor_category_code (khong GROUP BY theo category).
market_index_last_all AS (
    SELECT
        market_id,
        market_code,
        trading_dt,
        market_index_val,
        index_change,
        index_percent_change,
        ROW_NUMBER() OVER (PARTITION BY market_id, market_code, trading_dt ORDER BY index_time DESC, sequence DESC) AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

market_index_last AS (
    SELECT market_code, trading_dt, market_index_val, index_change, index_percent_change
    FROM market_index_last_all
    WHERE rn = 1
)

SELECT
    CAST(index_dim.index_constituent_dim_id AS string)          AS index_constituent_dim_id,
    CAST(date_format(idx_cat.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(idx_cat.investor_category_code AS string)              AS investor_category_code,
    CAST(idx_cat.buy_val AS decimal(23,2))                      AS buy_val,
    CAST(idx_cat.buy_vol AS bigint)                             AS buy_vol,
    CAST(idx_cat.sell_val AS decimal(23,2))                     AS sell_val,
    CAST(idx_cat.sell_vol AS bigint)                            AS sell_vol,
    CAST(idx_cat.matched_buy_val AS decimal(23,2))              AS matched_buy_val,
    CAST(idx_cat.matched_sell_val AS decimal(23,2))             AS matched_sell_val,
    CAST(idx_cat.negotiated_buy_val AS decimal(23,2))           AS negotiated_buy_val,
    CAST(idx_cat.negotiated_sell_val AS decimal(23,2))          AS negotiated_sell_val,
    CAST(mil.market_index_val AS decimal(23,2))                 AS market_index_val,
    CAST(mil.index_change AS decimal(23,2))                     AS index_change,
    CAST(mil.index_percent_change AS decimal(5,2))              AS index_percent_change
FROM idx_cat
LEFT JOIN index_dim
    ON index_dim.index_code = idx_cat.index_code
LEFT JOIN market_index_last mil
    ON  mil.market_code = idx_cat.index_code
    AND mil.trading_dt = idx_cat.trading_dt
WHERE idx_cat.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
