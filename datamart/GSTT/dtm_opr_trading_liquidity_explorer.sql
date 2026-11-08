/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_trading_liquidity_explorer
* Program name: Dtm Opr Trading Liquidity Explorer
* Created by: tuan.nguyenvanb
* Created date: 2026-10-16
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-16		tuan.nguyenvanb		[MOI, theo LLD HLD v4.53 DTM_GSTT_opr_trading_liquidity_explorer_MDDS_JAD_STOCKINFOR.csv, O_GSTT_72]
*                                       Bang phang Data Explorer Nhom 37 (Giao dich & thanh khoan). Grain: 1 dong / ma CK / chi so / ngay GD
*                                       + 1 dong 'khong theo ro' (index_code = '') cho moi ma CK. PK scd4a: trade_dt, symbol, index_code.
*                                       - Driving: atm_security_trading_snapshot, ban tin cuoi ngay moi ma (trading_time desc, sequence desc).
*                                       - [KHAC LLD, CAN DATA MODELER XAC NHAN] LLD ghi 'join_atomic' cho cac cot giao dich/tai chinh/ro chi so, nhung
*                                         model nay TAI SU DUNG cac Fact mart da co (cung quy tac, tranh tinh 2 noi lech so): fct_stock_portfolio_snpst
*                                         (total_*, tai chinh IDS+SCMS, prior_*), fct_investor_category_trading_snpst (pivot 4 nhom NDT theo ma CK),
*                                         fct_index_constituent_snpst (idx_*), fct_investor_category_index_trading_snpst (pivot 4 nhom NDT theo ro),
*                                         opr_security_ref (stock_tp_nm, nganh). Diem chi so/advances.. lay atomic market_index_snapshot (ban tin cuoi ngay).
*                                       - Cot cap chi so lap lai tren moi ma CK cua ro; BI tong hop cap thi truong PHAI loc index_code = '' (O_GSTT_72).
*                                       Model scd4a insert theo TEN cot. Cot ky thuat ds_rcrd_* do macro them.
* 2026-10-20		tuan.nguyenvanb		[SUA, LLD 2026-10-19] Bo sung cot index_nm (ten chi so) cuoi bang: LEFT JOIN market_index_snapshot ban tin cuoi ngay theo market_code = index_code
*                                       (cung CTE mi voi market_index_val); NULL o dong 'khong theo ro' (index_code = '') va khi khong co market_code tuong ung.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[SUA, LLD v4.56-v4.57, O_GSTT_75 + O_GSTT_77] (1) Market ID so lenh them DVX (phai sinh) va HCX (TPDN rieng le); san 06 (CorpBond) noi
*                                       theo isin_code nhu HNX 02/04 (trade_join_symbol trong st). (2) Do gioi han Market ID cua cac Fact (UPX,STX,STK,STO) cac cot total_*,
*                                       foreign_*, proprietary_*, domestic_* va idx_total_*, idx_foreign_*, idx_proprietary_*, idx_domestic_* nay TINH TRUC TIEP tu atm_securities_trade
*                                       (CTE se_tr/cat/idx_cat) dung etl_logic LLD, KHONG con doc dtm_fct_stock_portfolio_snpst / dtm_fct_investor_category_*_trading_snpst /
*                                       (dtm_fct_stock_portfolio_snpst + dtm_fct_index_constituent_snpst van dung cho tai chinh, von hoa, pe/pb, prior_*, idx_market_cap).
*                                       (3) Phan loai NDT loai tru nhau Nuoc ngoai -> Tu doanh (chi 'P') -> Ca nhan -> To chuc (O_GSTT_75); nguon open_investor_account =
*                                       atm_investment_account. BA danh so lai Nhom 37 -> 38 (khong anh huong code). Khong doi cot/kieu -> khong ALTER.
*--------------------------------------------------------------------*
* 2026-10-22		tuan.nguyenvanb		[DOI THEO CAU TEST BA, thay quy tac loai tru 2026-10-22 truoc do] Phan loai NDT DOC LAP nhu BA: Tu doanh = ky tu thu 4 IN ('P','E'); Nuoc ngoai = IN ('F','E'); Ca nhan = loai NDT '3', To chuc = '5' (khong xet ky tu thu 4) - mot lenh co the tinh vao nhieu nhom (TK loai E vua Tu doanh vua Nuoc ngoai). Pham vi sua: ca nhan/to chuc theo loai NDT khong xet ky tu thu 4. Khong doi cot. CAN DONG BO LLD O_GSTT_75 (LLD dang ghi loai tru nhau).
* 2026-10-25		tuan.nguyenvanb		[DOI NGUON ATOMIC] Bo atm_investment_account (model tam), doc atm_open_investor_account (cung nguon VSDC open_investors).
*                                       Doi cot: investment_account_nbr -> investor_account_nbr, investment_account_tp_code (string) -> investor_tp_code (int, so sanh bang so),
*                                       event_dt -> open_dt. Cot output cua model khong doi -> khong ALTER mart/ClickHouse.
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78] THEM 26 cot (scd4a insert theo TEN, dat cuoi bang): market_cap, free_float_market_cap, net_profit_after_tax, owner_equity_average_4_quarter,
*                                       4 cot WAOS (doc tu dtm_fct_stock_portfolio_snpst), first_trading_dt, listed_share_count (ban tin cuoi ngay), 8 cot lo chan/lo le cap ma (round_lot_*, odd_lot_*:
*                                       co phieu UPX,STX,STK,STO; board G1,G2,G3,G6,G7,G8 / T1,T2,T3,T6,R1 / G4 / T4) va 8 cot cap ro idx_round_lot_*, idx_odd_lot_* (SUM cac ma thanh vien ro).
*                                       idx_market_cap, idx_free_float_market_cap, idx_pe, idx_pb, prior_market_cap, net_profit_after_tax_ttm nay theo gia tinh von hoa moi va quy tac ky LNST nam/quy
*                                       (da nam trong Fact Stock Portfolio va Fact Index Constituent). Bang vat ly can ALTER ADD COLUMN (scd4a: khong can dung vi tri).
*/

WITH st_all AS (
    SELECT
        ticker_symbol AS symbol,
        ds_snpst_dt AS trade_dt,
        floor_code,
        isin_code,
        reference_price,
        close_price,
        open_price,
        high_price,
        low_price,
        price_change,
        first_trading_dt,
        listed_share_count,
        src_stm_code,
        row_number() over (partition by ticker_symbol order by trading_time desc, sequence desc) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

st AS (
    SELECT
        symbol,
        trade_dt,
        CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'symbol') }} AS string) AS se_dim_id,
        floor_code,
        -- [O_GSTT_77] Khoa noi so lenh: san 02/04/03/06 (HNX/UPCOM/FDS/CorpBond) theo isin_code, san 10 (HOSE) theo ticker
        CASE WHEN floor_code IN ('02','04','03','06') THEN isin_code WHEN floor_code = '10' THEN symbol END AS trade_join_symbol,
        reference_price,
        close_price,
        open_price,
        high_price,
        low_price,
        price_change,
        first_trading_dt,
        listed_share_count,
        src_stm_code
    FROM st_all
    WHERE rn = 1
),

-- Loai CK + nganh: tai su dung opr_security_ref (cung cong thuc LLD: stock_tp_nm = security_class_nm; nganh theo K_GSTT_2)
sref AS (
    SELECT symbol, ds_snpst_dt AS dt, security_class_nm AS stock_tp_nm, industry_code, industry_nm
    FROM {{ ref('dtm_opr_security_ref') }}_hstr
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- Cap ma CK (1 dong / ma / ngay): tong GD, tai chinh IDS + SCMS, von hoa phien truoc
sp AS (
    SELECT
        security_trading_snpst_dim_id AS se_dim_id,
        to_date(snpst_dt_dim_id, 'yyyyMMdd') AS dt,
        outstanding_share_quantity,
        net_profit_after_tax_ttm,
        securities_company_net_profit_after_tax_ttm,
        owner_equity,
        securities_company_owner_equity,
        prior_market_cap,
        prior_free_float_market_cap,
        market_cap,
        free_float_market_cap,
        net_profit_after_tax,
        owner_equity_average_4_quarter,
        weighted_average_outstanding_share_quantity,
        weighted_average_outstanding_share_quantity_ttm,
        owner_equity_weighted_average_outstanding_share_quantity,
        owner_equity_weighted_average_outstanding_share_quantity_ttm
    FROM {{ ref('dtm_fct_stock_portfolio_snpst') }}
    WHERE snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

-- [SUA 2026-10-22, LLD v4.56-v4.57, O_GSTT_75/77] Tai khoan Ca nhan/To chuc: ban ghi MOI NHAT theo event_dt cua tung so TK (atm_open_investor_account = VSDC open_investors).
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

-- [SUA 2026-10-22, O_GSTT_77] Tong hop so lenh theo ma (security_symbol_code) trong ngay, TINH TRUC TIEP tu securities_trade (khong tai su dung Fact
-- vi Fact chi gom Market ID UPX,STX,STK,STO): them DVX (phai sinh) va HCX (TPDN rieng le). Phan loai NDT loai tru nhau theo thu tu uu tien
-- Nuoc ngoai (F,E) -> Tu doanh (P) -> Ca nhan (tp=3) -> To chuc (tp=5); Ca nhan/To chuc chi khi ky tu thu 4 NOT IN (F,E,P) (O_GSTT_75).
se_tr AS (
    SELECT
        st.security_symbol_code,
        st.market_id_code,
        st.board_tp_code,
        st.execution_vol,
        st.execution_val,
        CASE WHEN st.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN 1 ELSE 0 END AS is_matched,
        CASE WHEN st.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN 1 ELSE 0 END AS is_negotiated,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS buy_is_nn,
        CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS buy_is_td,
        CASE WHEN ia_buy.investor_tp_code = 3 THEN 1 ELSE 0 END AS buy_is_cn,
        CASE WHEN ia_buy.investor_tp_code = 5 THEN 1 ELSE 0 END AS buy_is_tc,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN 1 ELSE 0 END AS sell_is_nn,
        CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('P','E') THEN 1 ELSE 0 END AS sell_is_td,
        CASE WHEN ia_sell.investor_tp_code = 3 THEN 1 ELSE 0 END AS sell_is_cn,
        CASE WHEN ia_sell.investor_tp_code = 5 THEN 1 ELSE 0 END AS sell_is_tc
    FROM {{ ref('atm_securities_trade') }} st
    LEFT JOIN inv_acc ia_buy
        ON ia_buy.investor_account_nbr = st.buy_account_nbr
    LEFT JOIN inv_acc ia_sell
        ON ia_sell.investor_account_nbr = st.sell_account_nbr
    WHERE st.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND st.market_id_code IN ('UPX','STX','STK','STO','DVX','HCX')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
),

cat AS (
    SELECT
        security_symbol_code,
        SUM(execution_vol) AS total_vol,
        SUM(execution_val) AS total_val,
        SUM(is_matched * execution_vol) AS total_matched_vol,
        SUM(is_matched * execution_val) AS total_matched_val,
        SUM(is_negotiated * execution_vol) AS total_negotiated_vol,
        SUM(is_negotiated * execution_val) AS total_negotiated_val,
        SUM(buy_is_nn * execution_vol) AS foreign_buy_vol,
        SUM(buy_is_nn * execution_val) AS foreign_buy_val,
        SUM(sell_is_nn * execution_vol) AS foreign_sell_vol,
        SUM(sell_is_nn * execution_val) AS foreign_sell_val,
        SUM(buy_is_td * execution_vol) AS proprietary_buy_vol,
        SUM(buy_is_td * execution_val) AS proprietary_buy_val,
        SUM(sell_is_td * execution_vol) AS proprietary_sell_vol,
        SUM(sell_is_td * execution_val) AS proprietary_sell_val,
        SUM(buy_is_cn * execution_val) AS domestic_individual_buy_val,
        SUM(buy_is_cn * execution_vol) AS domestic_individual_buy_vol,
        SUM(sell_is_cn * execution_val) AS domestic_individual_sell_val,
        SUM(sell_is_cn * execution_vol) AS domestic_individual_sell_vol,
        SUM(buy_is_tc * execution_val) AS domestic_institution_buy_val,
        SUM(buy_is_tc * execution_vol) AS domestic_institution_buy_vol,
        SUM(sell_is_tc * execution_val) AS domestic_institution_sell_val,
        SUM(sell_is_tc * execution_vol) AS domestic_institution_sell_vol,
        -- [MOI 2026-11-02, LLD v4.58, O_GSTT_78] Lo chan / lo le cap ma (co phieu/CCQ), NULL neu khong co giao dich thuoc nhom do
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS round_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS round_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_vol END) AS odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_val END) AS odd_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_vol END) AS odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_val END) AS odd_lot_negotiated_val
    FROM se_tr
    GROUP BY security_symbol_code
),

-- 1 dong / (ro, ma, ngay) - csidxinfor co the co nhieu ban tin cho cung 1 thanh vien
ics AS (
    SELECT DISTINCT
        index_code,
        ticker_symbol AS symbol,
        trading_dt AS dt,
        CAST({{ generate_surrogate_key_bigint('MDDS_JAD_CSIDXINFOR', 'index_code') }} AS string) AS idx_dim_id
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- Cap (ma CK x chi so): idx_* tu fct_index_constituent_snpst
ic AS (
    SELECT
        security_trading_snpst_dim_id AS se_dim_id,
        index_constituent_dim_id AS idx_dim_id,
        to_date(snpst_dt_dim_id, 'yyyyMMdd') AS dt,
        idx_market_cap, idx_free_float_market_cap,
        idx_pe, idx_pb,
        idx_prior_market_cap, idx_prior_free_float_market_cap
    FROM {{ ref('dtm_fct_index_constituent_snpst') }}
    WHERE snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

-- [SUA 2026-10-22, O_GSTT_77] idx_total_*, idx_foreign_*, idx_proprietary_*, idx_domestic_* = tong so lenh cua toan bo ma CK thanh vien ro (cong cac cat theo ma;
-- khong tai su dung fct_index_constituent_snpst / fct_investor_category_index_trading_snpst vi gioi han Market ID). 1 dong / ro (trong ngay etl).
idx_cat AS (
    SELECT
        ics.index_code,
        SUM(cat.total_matched_vol) AS idx_total_matched_vol,
        SUM(cat.total_matched_val) AS idx_total_matched_val,
        SUM(cat.total_negotiated_vol) AS idx_total_negotiated_vol,
        SUM(cat.total_negotiated_val) AS idx_total_negotiated_val,
        SUM(cat.foreign_buy_val) AS idx_foreign_buy_val,
        SUM(cat.foreign_buy_vol) AS idx_foreign_buy_vol,
        SUM(cat.foreign_sell_val) AS idx_foreign_sell_val,
        SUM(cat.foreign_sell_vol) AS idx_foreign_sell_vol,
        SUM(cat.proprietary_buy_val) AS idx_proprietary_buy_val,
        SUM(cat.proprietary_buy_vol) AS idx_proprietary_buy_vol,
        SUM(cat.proprietary_sell_val) AS idx_proprietary_sell_val,
        SUM(cat.proprietary_sell_vol) AS idx_proprietary_sell_vol,
        SUM(cat.domestic_individual_buy_val) AS idx_domestic_individual_buy_val,
        SUM(cat.domestic_individual_buy_vol) AS idx_domestic_individual_buy_vol,
        SUM(cat.domestic_individual_sell_val) AS idx_domestic_individual_sell_val,
        SUM(cat.domestic_individual_sell_vol) AS idx_domestic_individual_sell_vol,
        SUM(cat.domestic_institution_buy_val) AS idx_domestic_institution_buy_val,
        SUM(cat.domestic_institution_buy_vol) AS idx_domestic_institution_buy_vol,
        SUM(cat.domestic_institution_sell_val) AS idx_domestic_institution_sell_val,
        SUM(cat.domestic_institution_sell_vol) AS idx_domestic_institution_sell_vol,
        SUM(cat.round_lot_matched_vol) AS idx_round_lot_matched_vol,
        SUM(cat.round_lot_matched_val) AS idx_round_lot_matched_val,
        SUM(cat.round_lot_negotiated_vol) AS idx_round_lot_negotiated_vol,
        SUM(cat.round_lot_negotiated_val) AS idx_round_lot_negotiated_val,
        SUM(cat.odd_lot_matched_vol) AS idx_odd_lot_matched_vol,
        SUM(cat.odd_lot_matched_val) AS idx_odd_lot_matched_val,
        SUM(cat.odd_lot_negotiated_vol) AS idx_odd_lot_negotiated_vol,
        SUM(cat.odd_lot_negotiated_val) AS idx_odd_lot_negotiated_val
    FROM ics
    INNER JOIN st
        ON  st.symbol = ics.symbol
        AND st.trade_dt = ics.dt
    INNER JOIN cat
        ON  cat.security_symbol_code = st.trade_join_symbol
    GROUP BY ics.index_code
),

-- Diem chi so ban tin cuoi ngay (cap chi so x ngay)
mi_all AS (
    SELECT
        market_code,
        trading_dt AS dt,
        market_index_val,
        index_change,
        index_percent_change,
        prior_index,
        advances_count,
        declines_count,
        no_change_count,
        ceiling_count,
        floor_count,
        index_nm,
        row_number() over (partition by market_code, trading_dt order by index_time desc, sequence desc) AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

mi AS (
    SELECT * FROM mi_all WHERE rn = 1
),

-- Cap ma CK: cac cot cap chi so de NULL o nhanh 1
sym_row AS (
    SELECT
        st.symbol, st.trade_dt, st.se_dim_id,
        st.floor_code,
        sref.stock_tp_nm,
        sref.industry_code AS business_line_level_1_code,
        sref.industry_nm   AS classification_business_line_nm,
        st.reference_price, st.close_price, st.open_price, st.high_price, st.low_price, st.price_change,
        cat.total_vol, cat.total_val,
        cat.total_matched_vol, cat.total_matched_val,
        cat.total_negotiated_vol, cat.total_negotiated_val,
        cat.foreign_buy_vol, cat.foreign_sell_vol, cat.foreign_buy_val, cat.foreign_sell_val,
        cat.proprietary_buy_vol, cat.proprietary_sell_vol, cat.proprietary_buy_val, cat.proprietary_sell_val,
        cat.domestic_individual_buy_val, cat.domestic_individual_buy_vol,
        cat.domestic_individual_sell_val, cat.domestic_individual_sell_vol,
        cat.domestic_institution_buy_val, cat.domestic_institution_buy_vol,
        cat.domestic_institution_sell_val, cat.domestic_institution_sell_vol,
        cat.round_lot_matched_vol, cat.round_lot_matched_val, cat.round_lot_negotiated_vol, cat.round_lot_negotiated_val, cat.odd_lot_matched_vol, cat.odd_lot_matched_val, cat.odd_lot_negotiated_vol, cat.odd_lot_negotiated_val,
        sp.outstanding_share_quantity,
        sp.net_profit_after_tax_ttm,
        sp.securities_company_net_profit_after_tax_ttm,
        sp.owner_equity,
        sp.securities_company_owner_equity,
        sp.prior_market_cap,
        sp.prior_free_float_market_cap,
        sp.market_cap, sp.free_float_market_cap, sp.net_profit_after_tax, sp.owner_equity_average_4_quarter, sp.weighted_average_outstanding_share_quantity, sp.weighted_average_outstanding_share_quantity_ttm, sp.owner_equity_weighted_average_outstanding_share_quantity, sp.owner_equity_weighted_average_outstanding_share_quantity_ttm,
        st.first_trading_dt, st.listed_share_count,
        st.src_stm_code
    FROM st
    LEFT JOIN sref
        ON  sref.symbol = st.symbol
        AND sref.dt = st.trade_dt
    LEFT JOIN sp
        ON  sp.se_dim_id = st.se_dim_id
        AND sp.dt = st.trade_dt
    LEFT JOIN cat
        ON  cat.security_symbol_code = st.trade_join_symbol
),

u AS (
    -- Nhanh 1: dong 'khong theo ro' (index_code = ''), cot cap chi so NULL
    SELECT
        s.*,
        CAST('' AS string) AS index_code,
        CAST(NULL AS decimal(23,2)) AS market_index_val,
        CAST(NULL AS decimal(23,2)) AS index_change,
        CAST(NULL AS decimal(5,2)) AS index_percent_change,
        CAST(NULL AS decimal(23,2)) AS prior_index,
        CAST(NULL AS int) AS advances_count,
        CAST(NULL AS int) AS declines_count,
        CAST(NULL AS int) AS no_change_count,
        CAST(NULL AS int) AS ceiling_count,
        CAST(NULL AS int) AS floor_count,
        CAST(NULL AS bigint) AS idx_total_matched_vol,
        CAST(NULL AS decimal(23,2)) AS idx_total_matched_val,
        CAST(NULL AS bigint) AS idx_total_negotiated_vol,
        CAST(NULL AS decimal(23,2)) AS idx_total_negotiated_val,
        CAST(NULL AS decimal(23,2)) AS idx_market_cap,
        CAST(NULL AS decimal(23,2)) AS idx_free_float_market_cap,
        CAST(NULL AS decimal(10,2)) AS idx_pe,
        CAST(NULL AS decimal(10,2)) AS idx_pb,
        CAST(NULL AS decimal(23,2)) AS idx_prior_market_cap,
        CAST(NULL AS decimal(23,2)) AS idx_prior_free_float_market_cap,
        CAST(NULL AS decimal(23,2)) AS idx_foreign_buy_val,
        CAST(NULL AS bigint) AS idx_foreign_buy_vol,
        CAST(NULL AS decimal(23,2)) AS idx_foreign_sell_val,
        CAST(NULL AS bigint) AS idx_foreign_sell_vol,
        CAST(NULL AS decimal(23,2)) AS idx_proprietary_buy_val,
        CAST(NULL AS bigint) AS idx_proprietary_buy_vol,
        CAST(NULL AS decimal(23,2)) AS idx_proprietary_sell_val,
        CAST(NULL AS bigint) AS idx_proprietary_sell_vol,
        CAST(NULL AS decimal(23,2)) AS idx_domestic_individual_buy_val,
        CAST(NULL AS bigint) AS idx_domestic_individual_buy_vol,
        CAST(NULL AS decimal(23,2)) AS idx_domestic_individual_sell_val,
        CAST(NULL AS bigint) AS idx_domestic_individual_sell_vol,
        CAST(NULL AS decimal(23,2)) AS idx_domestic_institution_buy_val,
        CAST(NULL AS bigint) AS idx_domestic_institution_buy_vol,
        CAST(NULL AS decimal(23,2)) AS idx_domestic_institution_sell_val,
        CAST(NULL AS bigint) AS idx_domestic_institution_sell_vol,
        CAST(NULL AS string) AS index_nm,
        CAST(NULL AS bigint) AS idx_round_lot_matched_vol,
        CAST(NULL AS decimal(23,2)) AS idx_round_lot_matched_val,
        CAST(NULL AS bigint) AS idx_round_lot_negotiated_vol,
        CAST(NULL AS decimal(23,2)) AS idx_round_lot_negotiated_val,
        CAST(NULL AS bigint) AS idx_odd_lot_matched_vol,
        CAST(NULL AS decimal(23,2)) AS idx_odd_lot_matched_val,
        CAST(NULL AS bigint) AS idx_odd_lot_negotiated_vol,
        CAST(NULL AS decimal(23,2)) AS idx_odd_lot_negotiated_val
    FROM sym_row s

    UNION ALL

    -- Nhanh 2: moi ro chi so ma ma CK thuoc ve
    SELECT
        s.*,
        CAST(ics.index_code AS string) AS index_code,
        mi.market_index_val, mi.index_change, mi.index_percent_change, mi.prior_index,
        mi.advances_count, mi.declines_count, mi.no_change_count, mi.ceiling_count, mi.floor_count,
        ix.idx_total_matched_vol, ix.idx_total_matched_val,
        ix.idx_total_negotiated_vol, ix.idx_total_negotiated_val,
        ic.idx_market_cap, ic.idx_free_float_market_cap,
        ic.idx_pe, ic.idx_pb,
        ic.idx_prior_market_cap, ic.idx_prior_free_float_market_cap,
        ix.idx_foreign_buy_val, ix.idx_foreign_buy_vol,
        ix.idx_foreign_sell_val, ix.idx_foreign_sell_vol,
        ix.idx_proprietary_buy_val, ix.idx_proprietary_buy_vol,
        ix.idx_proprietary_sell_val, ix.idx_proprietary_sell_vol,
        ix.idx_domestic_individual_buy_val, ix.idx_domestic_individual_buy_vol,
        ix.idx_domestic_individual_sell_val, ix.idx_domestic_individual_sell_vol,
        ix.idx_domestic_institution_buy_val, ix.idx_domestic_institution_buy_vol,
        ix.idx_domestic_institution_sell_val, ix.idx_domestic_institution_sell_vol,
        mi.index_nm,
        ix.idx_round_lot_matched_vol, ix.idx_round_lot_matched_val, ix.idx_round_lot_negotiated_vol, ix.idx_round_lot_negotiated_val, ix.idx_odd_lot_matched_vol, ix.idx_odd_lot_matched_val, ix.idx_odd_lot_negotiated_vol, ix.idx_odd_lot_negotiated_val
    FROM sym_row s
    INNER JOIN ics
        ON  ics.symbol = s.symbol
        AND ics.dt = s.trade_dt
    LEFT JOIN ic
        ON  ic.se_dim_id = s.se_dim_id
        AND ic.idx_dim_id = ics.idx_dim_id
        AND ic.dt = s.trade_dt
    LEFT JOIN idx_cat ix
        ON  ix.index_code = ics.index_code
    LEFT JOIN mi
        ON  mi.market_code = ics.index_code
        AND mi.dt = s.trade_dt
)

SELECT
    CAST(u.trade_dt AS date) AS trade_dt,
    CAST(u.symbol AS string) AS symbol,
    CAST(u.index_code AS string) AS index_code,
    CAST(u.floor_code AS string) AS floor_code,
    CAST(u.stock_tp_nm AS string) AS stock_tp_nm,
    CAST(u.business_line_level_1_code AS string) AS business_line_level_1_code,
    CAST(u.classification_business_line_nm AS string) AS classification_business_line_nm,
    CAST(u.reference_price AS decimal(23,2)) AS reference_price,
    CAST(u.close_price AS decimal(23,2)) AS close_price,
    CAST(u.open_price AS decimal(23,2)) AS open_price,
    CAST(u.high_price AS decimal(23,2)) AS high_price,
    CAST(u.low_price AS decimal(23,2)) AS low_price,
    CAST(u.price_change AS decimal(23,2)) AS price_change,
    CAST(u.total_vol AS bigint) AS total_vol,
    CAST(u.total_val AS decimal(23,2)) AS total_val,
    CAST(u.total_matched_vol AS bigint) AS total_matched_vol,
    CAST(u.total_matched_val AS decimal(23,2)) AS total_matched_val,
    CAST(u.total_negotiated_vol AS bigint) AS total_negotiated_vol,
    CAST(u.total_negotiated_val AS decimal(23,2)) AS total_negotiated_val,
    CAST(u.foreign_buy_vol AS bigint) AS foreign_buy_vol,
    CAST(u.foreign_sell_vol AS bigint) AS foreign_sell_vol,
    CAST(u.foreign_buy_val AS decimal(23,2)) AS foreign_buy_val,
    CAST(u.foreign_sell_val AS decimal(23,2)) AS foreign_sell_val,
    CAST(u.proprietary_buy_vol AS bigint) AS proprietary_buy_vol,
    CAST(u.proprietary_sell_vol AS bigint) AS proprietary_sell_vol,
    CAST(u.proprietary_buy_val AS decimal(23,2)) AS proprietary_buy_val,
    CAST(u.proprietary_sell_val AS decimal(23,2)) AS proprietary_sell_val,
    CAST(u.domestic_individual_buy_val AS decimal(23,2)) AS domestic_individual_buy_val,
    CAST(u.domestic_individual_buy_vol AS bigint) AS domestic_individual_buy_vol,
    CAST(u.domestic_individual_sell_val AS decimal(23,2)) AS domestic_individual_sell_val,
    CAST(u.domestic_individual_sell_vol AS bigint) AS domestic_individual_sell_vol,
    CAST(u.domestic_institution_buy_val AS decimal(23,2)) AS domestic_institution_buy_val,
    CAST(u.domestic_institution_buy_vol AS bigint) AS domestic_institution_buy_vol,
    CAST(u.domestic_institution_sell_val AS decimal(23,2)) AS domestic_institution_sell_val,
    CAST(u.domestic_institution_sell_vol AS bigint) AS domestic_institution_sell_vol,
    CAST(u.outstanding_share_quantity AS bigint) AS outstanding_share_quantity,
    CAST(u.net_profit_after_tax_ttm AS decimal(23,2)) AS net_profit_after_tax_ttm,
    CAST(u.securities_company_net_profit_after_tax_ttm AS decimal(23,2)) AS securities_company_net_profit_after_tax_ttm,
    CAST(u.owner_equity AS decimal(23,2)) AS owner_equity,
    CAST(u.securities_company_owner_equity AS decimal(23,2)) AS securities_company_owner_equity,
    CAST(u.prior_market_cap AS decimal(23,2)) AS prior_market_cap,
    CAST(u.prior_free_float_market_cap AS decimal(23,2)) AS prior_free_float_market_cap,
    CAST(u.market_index_val AS decimal(23,2)) AS market_index_val,
    CAST(u.index_change AS decimal(23,2)) AS index_change,
    CAST(u.index_percent_change AS decimal(5,2)) AS index_percent_change,
    CAST(u.prior_index AS decimal(23,2)) AS prior_index,
    CAST(u.advances_count AS int) AS advances_count,
    CAST(u.declines_count AS int) AS declines_count,
    CAST(u.no_change_count AS int) AS no_change_count,
    CAST(u.ceiling_count AS int) AS ceiling_count,
    CAST(u.floor_count AS int) AS floor_count,
    CAST(u.idx_total_matched_vol AS bigint) AS idx_total_matched_vol,
    CAST(u.idx_total_matched_val AS decimal(23,2)) AS idx_total_matched_val,
    CAST(u.idx_total_negotiated_vol AS bigint) AS idx_total_negotiated_vol,
    CAST(u.idx_total_negotiated_val AS decimal(23,2)) AS idx_total_negotiated_val,
    CAST(u.idx_market_cap AS decimal(23,2)) AS idx_market_cap,
    CAST(u.idx_free_float_market_cap AS decimal(23,2)) AS idx_free_float_market_cap,
    CAST(u.idx_pe AS decimal(10,2)) AS idx_pe,
    CAST(u.idx_pb AS decimal(10,2)) AS idx_pb,
    CAST(u.idx_prior_market_cap AS decimal(23,2)) AS idx_prior_market_cap,
    CAST(u.idx_prior_free_float_market_cap AS decimal(23,2)) AS idx_prior_free_float_market_cap,
    CAST(u.idx_foreign_buy_val AS decimal(23,2)) AS idx_foreign_buy_val,
    CAST(u.idx_foreign_buy_vol AS bigint) AS idx_foreign_buy_vol,
    CAST(u.idx_foreign_sell_val AS decimal(23,2)) AS idx_foreign_sell_val,
    CAST(u.idx_foreign_sell_vol AS bigint) AS idx_foreign_sell_vol,
    CAST(u.idx_proprietary_buy_val AS decimal(23,2)) AS idx_proprietary_buy_val,
    CAST(u.idx_proprietary_buy_vol AS bigint) AS idx_proprietary_buy_vol,
    CAST(u.idx_proprietary_sell_val AS decimal(23,2)) AS idx_proprietary_sell_val,
    CAST(u.idx_proprietary_sell_vol AS bigint) AS idx_proprietary_sell_vol,
    CAST(u.idx_domestic_individual_buy_val AS decimal(23,2)) AS idx_domestic_individual_buy_val,
    CAST(u.idx_domestic_individual_buy_vol AS bigint) AS idx_domestic_individual_buy_vol,
    CAST(u.idx_domestic_individual_sell_val AS decimal(23,2)) AS idx_domestic_individual_sell_val,
    CAST(u.idx_domestic_individual_sell_vol AS bigint) AS idx_domestic_individual_sell_vol,
    CAST(u.idx_domestic_institution_buy_val AS decimal(23,2)) AS idx_domestic_institution_buy_val,
    CAST(u.idx_domestic_institution_buy_vol AS bigint) AS idx_domestic_institution_buy_vol,
    CAST(u.idx_domestic_institution_sell_val AS decimal(23,2)) AS idx_domestic_institution_sell_val,
    CAST(u.idx_domestic_institution_sell_vol AS bigint) AS idx_domestic_institution_sell_vol,
    CAST(u.src_stm_code AS string) AS src_stm_code,
    CAST(u.index_nm AS string) AS index_nm,   -- [MOI 2026-10-20] ten chi so, dat CUOI sau src_stm_code
    CAST(u.market_cap AS decimal(23,2)) AS market_cap,
    CAST(u.free_float_market_cap AS decimal(23,2)) AS free_float_market_cap,
    CAST(u.first_trading_dt AS date) AS first_trading_dt,
    CAST(u.listed_share_count AS bigint) AS listed_share_count,
    CAST(u.net_profit_after_tax AS decimal(23,2)) AS net_profit_after_tax,
    CAST(u.owner_equity_average_4_quarter AS decimal(23,2)) AS owner_equity_average_4_quarter,
    CAST(u.owner_equity_weighted_average_outstanding_share_quantity AS decimal(23,4)) AS owner_equity_weighted_average_outstanding_share_quantity,
    CAST(u.owner_equity_weighted_average_outstanding_share_quantity_ttm AS decimal(23,4)) AS owner_equity_weighted_average_outstanding_share_quantity_ttm,
    CAST(u.weighted_average_outstanding_share_quantity AS decimal(23,4)) AS weighted_average_outstanding_share_quantity,
    CAST(u.weighted_average_outstanding_share_quantity_ttm AS decimal(23,4)) AS weighted_average_outstanding_share_quantity_ttm,
    CAST(u.round_lot_matched_vol AS bigint) AS round_lot_matched_vol,
    CAST(u.round_lot_matched_val AS decimal(23,2)) AS round_lot_matched_val,
    CAST(u.round_lot_negotiated_vol AS bigint) AS round_lot_negotiated_vol,
    CAST(u.round_lot_negotiated_val AS decimal(23,2)) AS round_lot_negotiated_val,
    CAST(u.odd_lot_matched_vol AS bigint) AS odd_lot_matched_vol,
    CAST(u.odd_lot_matched_val AS decimal(23,2)) AS odd_lot_matched_val,
    CAST(u.odd_lot_negotiated_vol AS bigint) AS odd_lot_negotiated_vol,
    CAST(u.odd_lot_negotiated_val AS decimal(23,2)) AS odd_lot_negotiated_val,
    CAST(u.idx_round_lot_matched_vol AS bigint) AS idx_round_lot_matched_vol,
    CAST(u.idx_round_lot_matched_val AS decimal(23,2)) AS idx_round_lot_matched_val,
    CAST(u.idx_round_lot_negotiated_vol AS bigint) AS idx_round_lot_negotiated_vol,
    CAST(u.idx_round_lot_negotiated_val AS decimal(23,2)) AS idx_round_lot_negotiated_val,
    CAST(u.idx_odd_lot_matched_vol AS bigint) AS idx_odd_lot_matched_vol,
    CAST(u.idx_odd_lot_matched_val AS decimal(23,2)) AS idx_odd_lot_matched_val,
    CAST(u.idx_odd_lot_negotiated_vol AS bigint) AS idx_odd_lot_negotiated_vol,
    CAST(u.idx_odd_lot_negotiated_val AS decimal(23,2)) AS idx_odd_lot_negotiated_val
FROM u
