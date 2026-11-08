-- [FIRST-TIME] ft_dtm_fct_investor_category_trading_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_investor_category_trading_snpst (config ft_target='fct_investor_category_trading_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_category_trading_snpst
* Program name: Dtm Fct Investor Category Trading Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-21
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-25		tuan.nguyenvanb		[LLD moi tu Data Modeler] Doi lai dung cong thuc
*                                       chinh thuc trong LLD (THAY THE ban 2026-09-25 truoc
*                                       do dung IN('10','20') theo cau test rieng cua BA -
*                                       BA_analyst_GSTT dong 402 CHUA duoc cap nhat, LLD la
*                                       nguon chuan). TU_DOANH (client_house_cl_code='30')
*                                       va NUOC_NGOAI (foreign_investor_tp_code<>'00') la 2
*                                       CO DOC LAP, co the CHONG LAP nhau (dung y het ban
*                                       truoc, chi doi lai dieu kien NN tu IN('10','20') ve
*                                       <>'00'). CA_NHAN = phan du loai tru ca 2 (client_
*                                       house<>'30' AND foreign='00' AND investor_tp='8000').
*                                       TO_CHUC_TRONG_NUOC MOI: khong con la phan du loai
*                                       tru don gian nua, ma la HIEU cua 2 SUM: [foreign='00'
*                                       AND investor_tp<>'8000'] TRU [tu_doanh] - vi tap
*                                       "foreign='00' AND investor_tp<>'8000'" VAN CHUA ca
*                                       cac lenh tu doanh (khong loai truoc), phai tru rieng
*                                       so hang tu doanh ra. Dung nguyen cau truc SQL tham
*                                       khao trong LLD (SUM(CASE investor_category_code
*                                       WHEN ... THEN (nested CASE) END)).
* 2026-09-22		tuan.nguyenvanb		[CHOT, BA don gian hoa STT 28] Bo phan nhanh theo
*                                       src_stm_code (HOSE/HNX) trong CASE phan loai buy/sell
*                                       - LLD sua lai dung 1 bo dieu kien duy nhat, ap dung
*                                       nhu nhau ca 2 san.
* 2026-09-21		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_investor_category_trading_
*                                       snpst.csv] Fact GD theo Phan loai NDT (CA_NHAN /
*                                       TO_CHUC_TRONG_NUOC / TU_DOANH / NUOC_NGOAI) - 1 dong /
*                                       ma CK / ngay / investor_category_code (4 dong co dinh,
*                                       sinh bang CROSS JOIN VALUES thay vi 4x cot rieng, dung
*                                       nguyen grain LLD). matched_/negotiated_ tach theo
*                                       board_tp_code (khop lenh = NOT IN T1-T4,T6,R1;
*                                       thoa thuan = IN T1-T4,T6,R1), dung quy uoc chung voi
*                                       se_tr_mt_matched/se_tr_ng cua stock_portfolio.
*                                       Join sang Security Trading Snapshot Dimension qua
*                                       trade_join_symbol (CASE floor_code IN ('02','04','03')
*                                       THEN isin_code ELSE symbol END) - quy uoc chung GSTT.
*                                       snpst_dt_dim_id format truc tiep tu trade_dt (khong
*                                       join dtm_cdr_dt_dim), dung quy uoc chung GSTT.
* 2026-09-30		tuan.nguyenvanb		[REVIEW LLD 2026-09-30] THEM buy_vol/sell_vol (KL mua/ban
*                                       theo Phan loai NDT, khop lenh + thoa thuan, cung quy
*                                       tac phan loai voi buy_val/sell_val, thay execution_val
*                                       bang execution_vol; se_tr them cot execution_vol). LLD
*                                       ghi int nhung dung BIGINT (tranh tran INT32 nhu fix
*                                       2026-09-28 o stock_portfolio) - can chot lai LLD.
*                                       Chen ngay sau buy_val / sell_val theo thu tu LLD.
*                                       CAN ALTER ADD COLUMN ... AFTER (xem scratch/deploy_gstt_ddl_20260930.sql).
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-15		tuan.nguyenvanb		[SUA, LLD v4.49 BA cap nhat phan loai NDT] Moi phia mua hoac ban phan loai DOC LAP theo
*                                       so tai khoan: TU_DOANH la ky tu thu 4 cua so TK thuoc P hoac E; NUOC_NGOAI la ky tu thu 4
*                                       thuoc F hoac E; CA_NHAN la investment_account (ban ghi moi nhat theo event_dt) co
*                                       investment_account_tp_code = 3; TO_CHUC_TRONG_NUOC = 5 (truc tiep, bo phep tru). Cac phan
*                                       loai khong loai tru nhau (TK loai E tinh ca TU_DOANH va NUOC_NGOAI). Thay quy tac cu
*                                       dung client_house, foreign_investor, investor_tp. Market ID doi thanh UPX, STX, STK, STO.
*                                       Nguon moi: atm_investment_account (VSDC open_investors). Cot khong doi.
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		[SUA, dong bo daily, LLD v4.56-v4.57, O_GSTT_75] Phan loai NDT loai tru nhau Nuoc ngoai -> Tu doanh ('P') -> Ca nhan -> To chuc; them KHONG_XAC_DINH (5 dong/ma/ngay). Khong doi cot.
*--------------------------------------------------------------------*
* 2026-10-22		tuan.nguyenvanb		[DOI THEO CAU TEST BA, thay quy tac loai tru 2026-10-22 truoc do] Phan loai NDT DOC LAP nhu BA: Tu doanh = ky tu thu 4 IN ('P','E'); Nuoc ngoai = IN ('F','E'); Ca nhan = loai NDT '3', To chuc = '5' (khong xet ky tu thu 4) - mot lenh co the tinh vao nhieu nhom (TK loai E vua Tu doanh vua Nuoc ngoai). Pham vi sua: ca nhan/to chuc theo loai NDT khong xet ky tu thu 4; KHONG_XAC_DINH giu nguyen. Khong doi cot. CAN DONG BO LLD O_GSTT_75 (LLD dang ghi loai tru nhau).
* 2026-10-25		tuan.nguyenvanb		[DOI NGUON ATOMIC] Bo atm_investment_account (model tam), doc atm_open_investor_account (cung nguon VSDC open_investors).
*                                       Doi cot: investment_account_nbr -> investor_account_nbr, investment_account_tp_code (string) -> investor_tp_code (int, so sanh bang so),
*                                       event_dt -> open_dt. Cot output cua model khong doi -> khong ALTER mart/ClickHouse.
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
*/

WITH se_tr_sn_di_all AS (
    SELECT
        security_trading_snpst_dim_id,
        floor_code,
        isin_code,
        symbol,
        ds_snpst_dt,
        CASE WHEN floor_code IN ('02','04','03') THEN isin_code ELSE symbol END AS trade_join_symbol
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- [BACKFILL-UAT-NEW] moi dong dim -> toi da 2 khoa join (symbol, isin_code); UNION de khong nhan doi khi symbol = isin.
se_tr_sn_di_key AS (
    SELECT security_trading_snpst_dim_id, symbol AS join_key, ds_snpst_dt FROM se_tr_sn_di_all WHERE symbol IS NOT NULL
    UNION
    SELECT security_trading_snpst_dim_id, isin_code AS join_key, ds_snpst_dt FROM se_tr_sn_di_all WHERE isin_code IS NOT NULL
),

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

-- [BACKFILL-UAT-NEW] TOI UU TOC DO, KHONG DOI LOGIC: gop truoc cac lenh cung (ma, ngay, board, so TK mua, so TK ban) thanh 1 dong
-- voi SUM(execution_vol/val), sau do moi join investment_account va gop tiep theo cac co phan loai.
se_tr_grp AS (
    SELECT
        security_symbol_code,
        trade_dt,
        board_tp_code,
        buy_account_nbr,
        sell_account_nbr,
        SUM(execution_vol) AS execution_vol,
        SUM(execution_val) AS execution_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        --AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd') -- chạy 1 năm
    GROUP BY
        security_symbol_code,
        trade_dt,
        board_tp_code,
        buy_account_nbr,
        sell_account_nbr
),

se_tr_cls AS (
    SELECT
        g.security_symbol_code,
        g.trade_dt,
        g.board_tp_code,
        g.execution_vol,
        g.execution_val,
        CASE WHEN SUBSTR(g.buy_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS buy_is_nn,
        CASE WHEN SUBSTR(g.buy_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS buy_is_td,
        CASE WHEN ia_buy.investor_tp_code = 3 THEN 1 ELSE 0 END AS buy_is_cn,
        CASE WHEN ia_buy.investor_tp_code = 5 THEN 1 ELSE 0 END AS buy_is_tc,
        CASE WHEN COALESCE(SUBSTR(g.buy_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND COALESCE(ia_buy.investor_tp_code, -1) NOT IN (3,5) THEN 1 ELSE 0 END AS buy_is_kxd,
        CASE WHEN SUBSTR(g.sell_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS sell_is_nn,
        CASE WHEN SUBSTR(g.sell_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS sell_is_td,
        CASE WHEN ia_sell.investor_tp_code = 3 THEN 1 ELSE 0 END AS sell_is_cn,
        CASE WHEN ia_sell.investor_tp_code = 5 THEN 1 ELSE 0 END AS sell_is_tc,
        CASE WHEN COALESCE(SUBSTR(g.sell_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND COALESCE(ia_sell.investor_tp_code, -1) NOT IN (3,5) THEN 1 ELSE 0 END AS sell_is_kxd
    FROM se_tr_grp g
    LEFT JOIN inv_acc ia_buy
        ON ia_buy.investor_account_nbr = g.buy_account_nbr
    LEFT JOIN inv_acc ia_sell
        ON ia_sell.investor_account_nbr = g.sell_account_nbr
),

se_tr AS (
    SELECT
        security_symbol_code,
        trade_dt,
        board_tp_code,
        buy_is_td, buy_is_nn, buy_is_cn, buy_is_tc, buy_is_kxd, sell_is_td, sell_is_nn, sell_is_cn, sell_is_tc, sell_is_kxd,
        SUM(execution_vol) AS execution_vol,
        SUM(execution_val) AS execution_val
    FROM se_tr_cls
    GROUP BY
        security_symbol_code,
        trade_dt,
        board_tp_code,
        buy_is_td,
        buy_is_nn,
        buy_is_cn,
        buy_is_tc,
        buy_is_kxd,
        sell_is_td,
        sell_is_nn,
        sell_is_cn,
        sell_is_tc,
        sell_is_kxd
),

-- 4 dong Phan loai NDT co dinh / ma CK / ngay - dung CROSS JOIN VALUES nhu LLD, khong phai
-- FK sang Dimension rieng (Classification Value chuan).
investor_category AS (
    SELECT investor_category_code
    FROM (VALUES ('CA_NHAN'),('TO_CHUC_TRONG_NUOC'),('TU_DOANH'),('NUOC_NGOAI'),('KHONG_XAC_DINH')) AS t(investor_category_code)
),

se_tr_cat AS (
    SELECT
        t.security_symbol_code,
        t.trade_dt,
        c.investor_category_code,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_val) AS buy_val,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_vol) AS buy_vol,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val) AS sell_val,
        SUM((CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_vol) AS sell_vol,
        SUM(CASE WHEN t.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS matched_buy_val,
        SUM(CASE WHEN t.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS matched_sell_val,
        SUM(CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS negotiated_buy_val,
        SUM(CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS negotiated_sell_val
    FROM se_tr t
    CROSS JOIN investor_category c
    GROUP BY t.security_symbol_code, t.trade_dt, c.investor_category_code
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)   AS security_trading_snpst_dim_id,
    CAST(date_format(se_tr_cat.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(se_tr_cat.investor_category_code AS string)            AS investor_category_code,
    CAST(se_tr_cat.buy_val AS decimal(23,2))                    AS buy_val,
    CAST(se_tr_cat.buy_vol AS bigint)                           AS buy_vol,
    CAST(se_tr_cat.sell_val AS decimal(23,2))                   AS sell_val,
    CAST(se_tr_cat.sell_vol AS bigint)                          AS sell_vol,
    CAST(se_tr_cat.matched_buy_val AS decimal(23,2))            AS matched_buy_val,
    CAST(se_tr_cat.matched_sell_val AS decimal(23,2))           AS matched_sell_val,
    CAST(se_tr_cat.negotiated_buy_val AS decimal(23,2))         AS negotiated_buy_val,
    CAST(se_tr_cat.negotiated_sell_val AS decimal(23,2))        AS negotiated_sell_val
FROM se_tr_cat
LEFT JOIN se_tr_sn_di_key se_tr_sn_di   -- [BACKFILL-UAT-NEW]
    -- 2026-10-10 tuan.nguyenvanb: [BACKFILL-UAT-NEW] dim MAIN chi giu san moi nhat (vd VNE: floor 04 -> key isin) nen ma doi san ra dim_id NULL; join them theo symbol.
    -- [BACKFILL-UAT-ORIG] ON se_tr_sn_di.trade_join_symbol = se_tr_cat.security_symbol_code
    -- (equi-join qua se_tr_sn_di_key; dung OR/IN trong ON se thanh nested loop join, rat cham)
    ON se_tr_sn_di.join_key = se_tr_cat.security_symbol_code   -- [BACKFILL-UAT-NEW]
    AND se_tr_sn_di.ds_snpst_dt = CAST(se_tr_cat.trade_dt AS date)   -- [FIRST-TIME 2026-10-18] dim theo NGAY
