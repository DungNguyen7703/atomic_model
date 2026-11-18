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
* 2026-10-15		tuan.nguyenvanb		[SUA, LLD v4.49 BA cap nhat phan loai NDT] Moi phia mua hoac ban phan loai DOC LAP theo
*                                       so tai khoan: TU_DOANH la ky tu thu 4 cua so TK thuoc P hoac E; NUOC_NGOAI la ky tu thu 4
*                                       thuoc F hoac E; CA_NHAN la investment_account (ban ghi moi nhat theo event_dt) co
*                                       investment_account_tp_code = 3; TO_CHUC_TRONG_NUOC = 5 (truc tiep, bo phep tru). Cac phan
*                                       loai khong loai tru nhau (TK loai E tinh ca TU_DOANH va NUOC_NGOAI). Thay quy tac cu
*                                       dung client_house, foreign_investor, investor_tp. Market ID doi thanh UPX, STX, STK, STO.
*                                       Nguon moi: atm_investment_account (VSDC open_investors). Cot khong doi.
* 2026-10-22		tuan.nguyenvanb		[SUA, LLD v4.56-v4.57, O_GSTT_75] Cac phan loai LOAI TRU NHAU theo thu tu uu tien Nuoc ngoai
*                                       (ky tu thu 4 IN F,E) -> Tu doanh (chi con 'P', TK loai 'E' tinh vao Nuoc ngoai) -> Ca nhan (open_investor_account
*                                       .investor_tp_code=3) -> To chuc (=5); Ca nhan/To chuc chi khi ky tu thu 4 NOT IN (F,E,P). THEM phan loai thu 5
*                                       KHONG_XAC_DINH (phia mua/ban khong thuoc 4 nhom tren, ke ca so TK khong co trong open_investor_account).
*                                       Nguon open_investor_account = atm_investment_account (VSDC open_investors) - da dung tu 2026-10-15, khong doi.
*                                       Khong doi cot/kieu -> khong ALTER; 4 dong -> 5 dong/ma CK/ngay.
* 2026-10-25		tuan.nguyenvanb		[DOI NGUON ATOMIC] Bo atm_investment_account (model tam), doc atm_open_investor_account (cung nguon VSDC open_investors).
*                                       Doi cot: investment_account_nbr -> investor_account_nbr, investment_account_tp_code (string) -> investor_tp_code (int, so sanh bang so),
*                                       event_dt -> open_dt. Cot output cua model khong doi -> khong ALTER mart/ClickHouse.
*--------------------------------------------------------------------*
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
* 2026-11-09		tuan.nguyenvanb		[LLD O_GSTT_80, BA STT 23 dong 559-562, K_GSTT_423-426] THEM 8 cot cuoi bang (sau negotiated_sell_val): round_lot_buy_vol/sell_vol/buy_val/sell_val (board G1,G2,G3,G6,G7,G8,T1,T2,T3,T6,R1)
*                                       va odd_lot_buy_vol/sell_vol/buy_val/sell_val (board G4,T4); cung quy tac phan loai NDT nhu buy_vol/buy_val. Bang vat ly can ALTER ADD COLUMN ... AFTER negotiated_sell_val (insert theo vi tri).
*/

WITH se_tr_sn_di_all AS (
    SELECT
        security_trading_snpst_dim_id,
        floor_code,
        isin_code,
        symbol,
        CASE WHEN floor_code IN ('02','04','03') THEN isin_code ELSE symbol END AS trade_join_symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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

se_tr AS (
    SELECT
        st.security_symbol_code,
        st.trade_dt,
        st.execution_vol,
        st.execution_val,
        st.board_tp_code,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS buy_is_nn,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) = 'P' THEN 1 ELSE 0 END AS buy_is_td,
        CASE WHEN COALESCE(SUBSTR(st.buy_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND ia_buy.investor_tp_code = 3 THEN 1 ELSE 0 END AS buy_is_cn,
        CASE WHEN COALESCE(SUBSTR(st.buy_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND ia_buy.investor_tp_code = 5 THEN 1 ELSE 0 END AS buy_is_tc,
        CASE WHEN COALESCE(SUBSTR(st.buy_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND COALESCE(ia_buy.investor_tp_code, -1) NOT IN (3,5) THEN 1 ELSE 0 END AS buy_is_kxd,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS sell_is_nn,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) = 'P' THEN 1 ELSE 0 END AS sell_is_td,
        CASE WHEN COALESCE(SUBSTR(st.sell_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND ia_sell.investor_tp_code = 3 THEN 1 ELSE 0 END AS sell_is_cn,
        CASE WHEN COALESCE(SUBSTR(st.sell_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND ia_sell.investor_tp_code = 5 THEN 1 ELSE 0 END AS sell_is_tc,
        CASE WHEN COALESCE(SUBSTR(st.sell_account_nbr, 4, 1), '') NOT IN ('F','E','P') AND COALESCE(ia_sell.investor_tp_code, -1) NOT IN (3,5) THEN 1 ELSE 0 END AS sell_is_kxd
    FROM {{ ref('atm_securities_trade') }} st
    LEFT JOIN inv_acc ia_buy
        ON ia_buy.investor_account_nbr = st.buy_account_nbr
    LEFT JOIN inv_acc ia_sell
        ON ia_sell.investor_account_nbr = st.sell_account_nbr
    WHERE st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND st.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- 5 dong Phan loai NDT co dinh (them KHONG_XAC_DINH 2026-10-22) / ma CK / ngay - dung CROSS JOIN VALUES nhu LLD, khong phai
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
        SUM(CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS negotiated_sell_val,
        SUM(CASE WHEN t.board_tp_code IN ('G1','G2','G3','G6','G7','G8','T1','T2','T3','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_vol ELSE 0 END) AS round_lot_buy_vol,
        SUM(CASE WHEN t.board_tp_code IN ('G1','G2','G3','G6','G7','G8','T1','T2','T3','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_vol ELSE 0 END) AS round_lot_sell_vol,
        SUM(CASE WHEN t.board_tp_code IN ('G1','G2','G3','G6','G7','G8','T1','T2','T3','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS round_lot_buy_val,
        SUM(CASE WHEN t.board_tp_code IN ('G1','G2','G3','G6','G7','G8','T1','T2','T3','T6','R1') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS round_lot_sell_val,
        SUM(CASE WHEN t.board_tp_code IN ('G4','T4') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_vol ELSE 0 END) AS odd_lot_buy_vol,
        SUM(CASE WHEN t.board_tp_code IN ('G4','T4') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_vol ELSE 0 END) AS odd_lot_sell_vol,
        SUM(CASE WHEN t.board_tp_code IN ('G4','T4') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.buy_is_td WHEN 'NUOC_NGOAI' THEN t.buy_is_nn WHEN 'CA_NHAN' THEN t.buy_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.buy_is_tc WHEN 'KHONG_XAC_DINH' THEN t.buy_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS odd_lot_buy_val,
        SUM(CASE WHEN t.board_tp_code IN ('G4','T4') THEN (CASE c.investor_category_code WHEN 'TU_DOANH' THEN t.sell_is_td WHEN 'NUOC_NGOAI' THEN t.sell_is_nn WHEN 'CA_NHAN' THEN t.sell_is_cn WHEN 'TO_CHUC_TRONG_NUOC' THEN t.sell_is_tc WHEN 'KHONG_XAC_DINH' THEN t.sell_is_kxd ELSE 0 END) * t.execution_val ELSE 0 END) AS odd_lot_sell_val
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
    CAST(se_tr_cat.negotiated_sell_val AS decimal(23,2))        AS negotiated_sell_val,
    CAST(se_tr_cat.round_lot_buy_vol AS bigint)          AS round_lot_buy_vol,
    CAST(se_tr_cat.round_lot_sell_vol AS bigint)         AS round_lot_sell_vol,
    CAST(se_tr_cat.round_lot_buy_val AS decimal(23,2))   AS round_lot_buy_val,
    CAST(se_tr_cat.round_lot_sell_val AS decimal(23,2))  AS round_lot_sell_val,
    CAST(se_tr_cat.odd_lot_buy_vol AS bigint)            AS odd_lot_buy_vol,
    CAST(se_tr_cat.odd_lot_sell_vol AS bigint)           AS odd_lot_sell_vol,
    CAST(se_tr_cat.odd_lot_buy_val AS decimal(23,2))     AS odd_lot_buy_val,
    CAST(se_tr_cat.odd_lot_sell_val AS decimal(23,2))    AS odd_lot_sell_val
FROM se_tr_cat
LEFT JOIN se_tr_sn_di_all se_tr_sn_di
    ON se_tr_sn_di.trade_join_symbol = se_tr_cat.security_symbol_code
