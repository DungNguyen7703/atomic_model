-- [FIRST-TIME] ft_dtm_fct_index_constituent_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_index_constituent_snpst (config ft_target='fct_index_constituent_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_index_constituent_snpst
* Program name: Dtm Fct Index Constituent Snpst (Bridge)
* Created by: tuan.nguyenvanb
* Created date: 2026-09-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		tuan.nguyenvanb		[LLD v4.49] (1) Them 4 measure idx_foreign_buy_vol/
*                                       idx_foreign_sell_vol/idx_foreign_buy_val/idx_foreign_sell_val
*                                       (K_GSTT_370-373, khoi luong/gia tri NDT nuoc ngoai mua/ban
*                                       cua ca ro chi so) - nguon atm_securities_trade (buy/sell_
*                                       account_nbr, execution_vol/val), them cuoi SELECT theo thu tu
*                                       LLD. (2) Nuoc ngoai theo SO TAI KHOAN: ky tu thu 4 cua
*                                       buy/sell_account_nbr IN ('F','E') (thay foreign_investor_tp_
*                                       code IN ('10','20')), gop khop lenh + thoa thuan - ap dung
*                                       ca idx_foreign_net_vol/val. (3) Chuan hoa san: market_id_code
*                                       IN ('UPX','STX','STK','STO') cho idx_matched/idx_foreign/
*                                       idx_negotiated (them STO).
* 2026-09-25		tuan.nguyenvanb		[Doi chieu lai voi LLD DTM_GSTT_fct_index_
*                                       constituent_snpst.csv] Bo sung idx_market_index_val
*                                       (dong LLD #11, bi thieu khi build ban dau) - LEFT JOIN
*                                       atm_market_index_snapshot loc src_stm_code=
*                                       'MDDS_JAD_MARKETINFOR', dedupe ROW_NUMBER theo
*                                       (market_id, market_code, trading_dt) ORDER BY
*                                       index_time DESC, cung pattern voi dtm_fct_market_
*                                       index_snpst.sql (QLKD).
* 2026-09-19		tuan.nguyenvanb		[LLD de8cd57c, MOI] Them 3 measure idx_pe/idx_pb/
*                                       idx_eps (K_GSTT_149/150/151, P/E/P/B/EPS CUA CHI SO -
*                                       khac han K_GSTT_58/59/60 tinh theo TUNG MA) - tinh
*                                       sẵn tren Bridge nay, cung co che SUM/SUM GROUP BY
*                                       Index+Date nhu idx_market_cap. LNST TTM/VCSH REUSE
*                                       truc tiep tu dtm_fct_stock_portfolio_snpst (khong
*                                       viet lai chuoi join fr_value nhu LLD literal) de
*                                       tranh lech logic giua 2 Fact. idx_eps KHONG loc mau
*                                       so theo ma co LNST TTM (khac idx_pe/idx_pb co loc) -
*                                       xem O_GSTT_24, CAN BA xac nhan lai. Them
*                                       idx_prior_market_cap/idx_prior_free_float_market_cap
*                                       (O_GSTT_25) - LAG 1 phien theo Index Code, phuc vu
*                                       mau so K_GSTT_74/76 (von hoa RO CHI SO tai T-1,
*                                       cung fix bug voi prior_market_cap ben
*                                       dtm_fct_stock_portfolio_snpst) - implement bang
*                                       self-reference ve chinh bang dich.
* 2026-09-14		tuan.nguyenvanb		[MOI, theo HLD v4.13 + LLD DTM_GSTT_fct_index_
*                                       constituent_snpst.csv] Bridge factless (3 FK) -
*                                       thanh vien ro chi so theo ngay, 1 dong / ma CK /
*                                       ro chi so / ngay giao dich - tach khoi
*                                       dtm_fct_stock_portfolio_snpst de het fan-out theo
*                                       ro chi so (1 ma thuoc nhieu chi so truoc day nhan
*                                       dong ca o fact chinh). Bo sung 8 measure tinh san
*                                       theo Index+Date (idx_*) - GIA TRI LAP LAI tren moi
*                                       dong Symbol cung index_code+cdr_dt (denormalize co
*                                       chu dich, dung MAX()/DISTINCT khi truy van, KHONG
*                                       SUM lai). idx_market_cap/idx_free_float_market_cap
*                                       dung ROW_NUMBER dedupe (khong dung MAX(...) correlated
*                                       subquery nhu LLD viet literal) - dong bo voi
*                                       oss_val/free_float_val ben dtm_fct_stock_portfolio_
*                                       snpst, an toan hon truoc data nguon co the trung do
*                                       incremental_strategy=append o tang atomic/ods.
* 2026-09-16		tuan.nguyenvanb		[LLD b8868c9e] idx_market_cap: remap Outstanding
*                                       Share Quantity tu pc_share_statistics_hstr (IDS)
*                                       sang listed_share_information (VSDC outstanding_shares,
*                                       src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo
*                                       dung nguon voi Free Float Share Quantity va voi
*                                       dtm_fct_stock_portfolio_snpst. Bo CTE pc_fin (khong
*                                       con can atm_public_company_v1 cho measure nay).
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-16		tuan.nguyenvanb		[LLD v4.50, commit 1d908c6d] idx_pe/idx_pb: mau so COALESCE(IDS, SCMS CTCK) theo tung ma - cong gop LNST TTM / VCSH cua
*                                       CTCK (securities_company_net_profit_after_tax_ttm / securities_company_owner_equity doc tu
*                                       fct_stock_portfolio_snpst). idx_eps giu nguyen (chi LNST IDS). Khong doi cot.
* 2026-10-18		tuan.nguyenvanb		[FIX K_GSTT_47-54 chi so nen HOSE = 0] noi dim security_trading_snpst_dim / index_constituent_dim bang _hstr theo NGAY (ds_snpst_dt = trading_dt) thay vi MAIN ACTIVE
*                                       (ma 30/100/ALL/HOSE INACTIVE o MAIN -> index_constituent_dim_id NULL -> flat index_code rong).
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
*--------------------------------------------------------------------*
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78 muc a, b] idx_market_cap/idx_free_float_market_cap/idx_pe/idx_pb: SUM von hoa tu cot market_cap/free_float_market_cap cua
*                                       dtm_fct_stock_portfolio_snpst (gia tinh von hoa moi: UPCOM = VWAP phien ke tiep, HOSE/HNX = gia dong cua) thay close_price x so co phieu.
*                                       LNST TTM (idx_pe, idx_eps) doc net_profit_after_tax_ttm tu Fact Stock Portfolio da doi cach chon ky nam/quy. Khong doi cot/kieu -> khong ALTER.
*/

-- [BACKFILL-UAT-ORIG] WITH se_tr_sn_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] symbol,
        -- [BACKFILL-UAT-ORIG] trading_dt,
        -- [BACKFILL-UAT-ORIG] trading_tms,
        -- [BACKFILL-UAT-ORIG] close_price,
        -- [BACKFILL-UAT-ORIG] floor_code,
        -- [BACKFILL-UAT-ORIG] isin_code,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by symbol order by trading_tms desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT: bo loc etl_date, tra cuu theo tung ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH se_tr_sn_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        ds_snpst_dt AS trading_dt,   -- [BACKFILL-UAT-NEW] [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
        trading_time,   -- [BACKFILL-UAT-NEW]
        close_price,   -- [BACKFILL-UAT-NEW]
        floor_code,   -- [BACKFILL-UAT-NEW]
        isin_code,   -- [BACKFILL-UAT-NEW]
        row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) as rn   -- [BACKFILL-UAT-NEW] [DOI THEO ATOMIC MOI 2026-10-09]
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

se_tr_sn AS (
    SELECT
        symbol,
        trading_dt,
        close_price,
        floor_code,
        CASE WHEN floor_code IN ('02','04','03') THEN isin_code ELSE symbol END AS trade_join_symbol
    FROM se_tr_sn_all
    WHERE rn = 1
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY (dim da ft_hstr_by_day), khong doc MAIN (ma INACTIVE o MAIN -> dim_id NULL)
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- Bridge grain: 1 dong / symbol / index_code / trading_dt
-- [BACKFILL-UAT-ORIG] in_co_sn_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] symbol,
        -- [BACKFILL-UAT-ORIG] trading_dt,
        -- [BACKFILL-UAT-ORIG] index_code,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by symbol, index_code order by trading_dt desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_index_constituent_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),
in_co_sn_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        trading_dt,   -- [BACKFILL-UAT-NEW]
        index_code,   -- [BACKFILL-UAT-NEW]
        row_number() over (partition by ticker_symbol, index_code, trading_dt order by trading_dt desc) as rn   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_index_constituent_snapshot') }}   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

in_co_sn AS (
    SELECT symbol, trading_dt, index_code
    FROM in_co_sn_all
    WHERE rn = 1
),

-- [SUA 2026-09-14] Index Constituent Dimension gio 1 dong/index_code (khong con symbol)
in_co_di AS (
    SELECT
        index_constituent_dim_id,
        index_code,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_index_constituent_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- Outstanding Share Quantity - [SUA 2026-09-16 theo LLD] Remap tu pc_share_statistics_hstr
-- (IDS, khong co du lieu hang ngay tren HNX/UPCOM) sang listed_share_information (VSDC
-- outstanding_shares, src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo dung nguon/pattern
-- voi free_float_share_quantity ben duoi (lookback theo symbol) - khong con can pc_fin/
-- atm_public_company_v1 nua vi khong con join qua pc_id.
-- [BACKFILL-UAT-ORIG] oss_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] lsis.ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] lsis.outstanding_share_quantity,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
    -- [BACKFILL-UAT-ORIG] WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        -- [BACKFILL-UAT-ORIG] AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] oss_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT symbol, outstanding_share_quantity
    -- [BACKFILL-UAT-ORIG] FROM oss_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] -- Free Float Share Quantity - ROW_NUMBER dedupe, lookback <= trading_dt (nguon
-- [BACKFILL-UAT-ORIG] -- VSDC_OUTSTANDING_SHARES qua atm_listed_share_information, giong fact chinh)
-- [BACKFILL-UAT-ORIG] free_float_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] lsis.ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] lsis.free_float_share_quantity,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
    -- [BACKFILL-UAT-ORIG] WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        -- [BACKFILL-UAT-ORIG] AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] free_float_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT symbol, free_float_share_quantity
    -- [BACKFILL-UAT-ORIG] FROM free_float_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS-GSTT] as-of theo tung trading_dt: ban ghi VSDC co ds_snpst_dt lon nhat <= trading_dt   -- [BACKFILL-UAT-NEW]
-- (giong daily: ds_snpst_dt <= etl_date, order by ds_snpst_dt desc). Khoang hieu luc [ds_snpst_dt, ds_snpst_dt ke tiep).   -- [BACKFILL-UAT-NEW]
oss_val_dedup AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        lsis.ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        lsis.ds_snpst_dt,   -- [BACKFILL-UAT-NEW]
        MAX(lsis.outstanding_share_quantity) AS outstanding_share_quantity,   -- [BACKFILL-UAT-NEW]
        MAX(lsis.free_float_share_quantity)  AS free_float_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis   -- [BACKFILL-UAT-NEW]
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'   -- [BACKFILL-UAT-NEW]
    GROUP BY lsis.ticker_symbol, lsis.ds_snpst_dt   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
lsis_val_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        symbol,   -- [BACKFILL-UAT-NEW]
        outstanding_share_quantity,   -- [BACKFILL-UAT-NEW]
        free_float_share_quantity,   -- [BACKFILL-UAT-NEW]
        ds_snpst_dt AS from_dt,   -- [BACKFILL-UAT-NEW]
        LEAD(ds_snpst_dt) OVER (PARTITION BY symbol ORDER BY ds_snpst_dt) AS to_dt   -- [BACKFILL-UAT-NEW]
    FROM oss_val_dedup   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
oss_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT s.symbol, s.trading_dt, l.outstanding_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM se_tr_sn s   -- [BACKFILL-UAT-NEW]
    INNER JOIN lsis_val_all l   -- [BACKFILL-UAT-NEW]
        ON  l.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND CAST(s.trading_dt AS date) >= l.from_dt   -- [BACKFILL-UAT-NEW]
        AND (l.to_dt IS NULL OR CAST(s.trading_dt AS date) < l.to_dt)   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
free_float_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT s.symbol, s.trading_dt, l.free_float_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM se_tr_sn s   -- [BACKFILL-UAT-NEW]
    INNER JOIN lsis_val_all l   -- [BACKFILL-UAT-NEW]
        ON  l.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND CAST(s.trading_dt AS date) >= l.from_dt   -- [BACKFILL-UAT-NEW]
        AND (l.to_dt IS NULL OR CAST(s.trading_dt AS date) < l.to_dt)   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

-- [MOI 2026-09-19, LLD review Nhom 6] LNST TTM / VCSH cho idx_pe/idx_pb/idx_eps - REUSE
-- truc tiep tu dtm_fct_stock_portfolio_snpst (da tinh dung/fix day du logic theo BA test
-- 2026-09-17: doc _hstr, bo EXISTS violation_report, dedupe truoc khi xep hang...) THAY VI
-- viet lai toan bo chuoi join fr_value/fr_catalog/fr_row_template/fr_column_template mot
-- lan nua nhu LLD viet literal - tranh 2 noi tinh trung 1 chi tieu de lech nhau khi co fix
-- sau nay. Join theo security_trading_snpst_dim_id + snpst_dt_dim_id (cung 2 dim voi Fact
-- chinh, dam bao dung dong/dung ngay).
fin_val AS (
    SELECT
        security_trading_snpst_dim_id,
        snpst_dt_dim_id,
        net_profit_after_tax_ttm,
        owner_equity,
        securities_company_net_profit_after_tax_ttm,   -- [2026-10-16 LLD v4.50]
        securities_company_owner_equity,
        market_cap,
        free_float_market_cap
    FROM {{ ft_ref('ft_dtm_fct_stock_portfolio_snpst') }}
),

-- Ghep du lieu per-symbol can cho cac measure tong hop theo index (close_price, KLLH, free float, LNST TTM, VCSH)
sym_measures AS (
    SELECT
        s.symbol,
        s.trading_dt,
        s.close_price,
        oss.outstanding_share_quantity,
        ff.free_float_share_quantity,
        fin.net_profit_after_tax_ttm,
        fin.owner_equity,
        fin.securities_company_net_profit_after_tax_ttm,   -- [2026-10-16 LLD v4.50]
        fin.securities_company_owner_equity,
        fin.market_cap,
        fin.free_float_market_cap
    FROM se_tr_sn s
    -- [BACKFILL-UAT-ORIG] LEFT JOIN oss_val oss
        -- [BACKFILL-UAT-ORIG] ON  oss.symbol = s.symbol
    -- [BACKFILL-UAT-ORIG] LEFT JOIN free_float_val ff
        -- [BACKFILL-UAT-ORIG] ON  ff.symbol = s.symbol
    LEFT JOIN oss_val oss   -- [BACKFILL-UAT-NEW]
        ON  oss.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND oss.trading_dt = s.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN free_float_val ff   -- [BACKFILL-UAT-NEW]
        ON  ff.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND ff.trading_dt = s.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN se_tr_sn_di std_di
        ON  std_di.symbol = s.symbol
        AND std_di.ds_snpst_dt = s.trading_dt   -- [FIRST-TIME 2026-10-18]
    LEFT JOIN fin_val fin
        ON  fin.security_trading_snpst_dim_id = std_di.security_trading_snpst_dim_id
        AND fin.snpst_dt_dim_id = date_format(s.trading_dt, 'yyyyMMdd')
),

-- Tong KLGD/GTGD khop lenh THUAN toan ro chi so (loai thoa thuan) - phuc vu K_GSTT_47/48
idx_matched_agg AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        SUM(st.execution_vol) AS idx_total_matched_vol,
        SUM(st.execution_val) AS idx_total_matched_val
    FROM in_co_sn ics
    INNER JOIN se_tr_sn std
        ON  std.symbol = ics.symbol
        AND std.trading_dt = ics.trading_dt
    INNER JOIN {{ ft_ref('ft_atm_securities_trade') }} st
        ON  st.security_symbol_code = std.trade_join_symbol
        AND st.trade_dt = ics.trading_dt
        AND st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY ics.index_code, ics.trading_dt
),

-- KLNN/GTNN toan ro chi so (gop khop lenh + thoa thuan, khong loc board) - phuc vu K_GSTT_49/50/370-373
-- [SUA 2026-10-15 LLD v4.49] Nuoc ngoai theo SO TAI KHOAN: ky tu thu 4 IN ('F','E')
idx_foreign_agg AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        SUM(CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('F','E') THEN st.execution_vol ELSE 0 END) AS idx_foreign_buy_vol,
        SUM(CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN st.execution_vol ELSE 0 END) AS idx_foreign_sell_vol,
        SUM(CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1) IN ('F','E') THEN st.execution_val ELSE 0 END) AS idx_foreign_buy_val,
        SUM(CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN st.execution_val ELSE 0 END) AS idx_foreign_sell_val
    FROM in_co_sn ics
    INNER JOIN se_tr_sn std
        ON  std.symbol = ics.symbol
        AND std.trading_dt = ics.trading_dt
    INNER JOIN {{ ft_ref('ft_atm_securities_trade') }} st
        ON  st.security_symbol_code = std.trade_join_symbol
        AND st.trade_dt = ics.trading_dt
        AND st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY ics.index_code, ics.trading_dt
),

-- Tong KLGD/GTGD thoa thuan toan ro chi so - phuc vu K_GSTT_51/52
idx_negotiated_agg AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        SUM(st.execution_vol) AS idx_total_negotiated_vol,
        SUM(st.execution_val) AS idx_total_negotiated_val
    FROM in_co_sn ics
    INNER JOIN se_tr_sn std
        ON  std.symbol = ics.symbol
        AND std.trading_dt = ics.trading_dt
    INNER JOIN {{ ft_ref('ft_atm_securities_trade') }} st
        ON  st.security_symbol_code = std.trade_join_symbol
        AND st.trade_dt = ics.trading_dt
        AND st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY ics.index_code, ics.trading_dt
),

-- Von hoa + Von hoa free float toan ro chi so - phuc vu K_GSTT_54/61/74/76
idx_cap_agg AS (
    SELECT
        ics.index_code,
        ics.trading_dt,
        SUM(sm.market_cap) AS idx_market_cap,   -- [SUA 2026-11-02, LLD v4.58 muc a] von hoa theo gia tinh von hoa moi
        SUM(sm.free_float_market_cap) AS idx_free_float_market_cap,
        -- [SUA 2026-09-19, doi chieu voi cau test BA thuc te cho HNX30 20260826] LLD viet
        -- literal loc CA TU SO (chi cong von hoa cua ma CO LNST TTM) - nhung cau test BA
        -- (Von_hoa_chi_so/LN_theo_chi_so) tinh tu so la TONG von hoa TOAN BO ma trong ro
        -- (KHONG loc), chi mau so SUM(lnst_ttm) tu nhien bo qua NULL do SUM. Da xac nhan
        -- qua so lieu that: idx_market_cap/net_profit_after_tax_ttm(SUM) khop dung 100%
        -- voi test (von_hoa=128684514800100, lnst_ttm=9867067861612) nhung PE loc-tu-so
        -- ra 9.45 lech han PE_test=13.04 (=128684514800100/9867067861612, dung von hoa
        -- KHONG loc). => Sua theo dung test: tu so = idx_market_cap/idx_free_float_market_cap
        -- (da tinh san o tren, KHONG loc), chi mau so moi loai NULL qua SUM. CAN RAISE
        -- DESIGN vi LLD dang mo ta sai so voi test.
        ROUND(SUM(sm.market_cap) / NULLIF(SUM(COALESCE(sm.net_profit_after_tax_ttm, sm.securities_company_net_profit_after_tax_ttm)), 0), 2) AS idx_pe,
        ROUND(SUM(sm.market_cap) / NULLIF(SUM(COALESCE(sm.owner_equity, sm.securities_company_owner_equity)), 0), 2) AS idx_pb,
        -- [MOI 2026-09-19, xem O_GSTT_24] EPS cua CHI SO - SUM(LNST TTM)/SUM(So CP luu
        -- hanh) TOAN BO ma thanh vien, KHONG loc mau so theo ma co LNST TTM (khac P/E/P/B -
        -- theo dung nghia den mo ta BA, CAN BA xac nhan lai neu phai loc giong P/E/P/B).
        SUM(sm.net_profit_after_tax_ttm) / NULLIF(SUM(sm.outstanding_share_quantity), 0) AS idx_eps
    FROM in_co_sn ics
    INNER JOIN sym_measures sm
        ON  sm.symbol = ics.symbol
        AND sm.trading_dt = ics.trading_dt
    GROUP BY ics.index_code, ics.trading_dt
),

-- [MOI 2026-09-19, LLD review Nhom 24/O_GSTT_25] Idx Prior Market Cap / Idx Prior Free
-- Float Market Cap - LAG(idx_market_cap)/LAG(idx_free_float_market_cap) 1 phien theo
-- Index Code, dung lam MAU SO cua K_GSTT_74/76 (w_i/w_ff_i phai dung von hoa RO CHI SO
-- tai T-1, khong phai T). SELF-REFERENCE {{ ft_this() }} de doc lai gia tri da luu tren dong
-- T-1 - cung cach lam voi prior_market_cap ben dtm_fct_stock_portfolio_snpst.
-- [BACKFILL-UAT-ORIG] idx_prior_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] idx_cons_dim.index_code,
        -- [BACKFILL-UAT-ORIG] t.idx_market_cap             AS idx_prior_market_cap,
        -- [BACKFILL-UAT-ORIG] t.idx_free_float_market_cap  AS idx_prior_free_float_market_cap,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by idx_cons_dim.index_code order by t.snpst_dt_dim_id desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_this() }} t
    -- [BACKFILL-UAT-ORIG] -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ft_ref('ft_dtm_index_constituent_dim') }}_hstr idx_cons_dim
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ft_ref('ft_dtm_index_constituent_dim') }} idx_cons_dim   -- [BACKFILL-UAT-NEW]
        -- [BACKFILL-UAT-ORIG] ON  idx_cons_dim.index_constituent_dim_id = t.index_constituent_dim_id
        -- [BACKFILL-UAT-ORIG] -- [BACKFILL-UAT-ORIG] AND idx_cons_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND idx_cons_dim.ds_rcrd_st = 'ACTIVE'
    -- [BACKFILL-UAT-ORIG] WHERE t.snpst_dt_dim_id < date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] idx_prior_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT index_code, idx_prior_market_cap, idx_prior_free_float_market_cap
    -- [BACKFILL-UAT-ORIG] FROM idx_prior_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS-GSTT] T-1 cua chi so = gia tri phien lien truoc CUA CHINH CHI SO trong cung lan chay (LAG theo trading_dt).   -- [BACKFILL-UAT-NEW]
-- Ngay dau cua moi chi so trong lan chay lay tu {{ ft_this() }} (dong luu gan nhat co snpst_dt_dim_id < ngay dau lan chay), giong daily.   -- [BACKFILL-UAT-NEW]
idx_days AS (   -- [BACKFILL-UAT-NEW]
    SELECT DISTINCT ics.index_code, ics.trading_dt   -- [BACKFILL-UAT-NEW]
    FROM in_co_sn ics   -- [BACKFILL-UAT-NEW]
    INNER JOIN in_co_di   -- [BACKFILL-UAT-NEW]
        ON  in_co_di.index_code = ics.index_code   -- [BACKFILL-UAT-NEW]
        AND in_co_di.ds_snpst_dt = ics.trading_dt   -- [FIRST-TIME 2026-10-18]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
idx_prior_base AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        d.index_code,   -- [BACKFILL-UAT-NEW]
        d.trading_dt,   -- [BACKFILL-UAT-NEW]
        CAST(a.idx_market_cap AS decimal(23,2))            AS idx_market_cap,   -- [BACKFILL-UAT-NEW]
        CAST(a.idx_free_float_market_cap AS decimal(23,2)) AS idx_free_float_market_cap   -- [BACKFILL-UAT-NEW]
    FROM idx_days d   -- [BACKFILL-UAT-NEW]
    LEFT JOIN idx_cap_agg a   -- [BACKFILL-UAT-NEW]
        ON  a.index_code = d.index_code   -- [BACKFILL-UAT-NEW]
        AND a.trading_dt = d.trading_dt   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
idx_prior_this_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        idx_cons_dim.index_code,   -- [BACKFILL-UAT-NEW]
        t.idx_market_cap             AS idx_prior_market_cap,   -- [BACKFILL-UAT-NEW]
        t.idx_free_float_market_cap  AS idx_prior_free_float_market_cap,   -- [BACKFILL-UAT-NEW]
        row_number() over (partition by idx_cons_dim.index_code order by t.snpst_dt_dim_id desc) as rn   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_this() }} t   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ft_ref('ft_dtm_index_constituent_dim') }}_hstr idx_cons_dim   -- [FIRST-TIME 2026-10-18] doc _hstr theo ngay cua dong da luu
        ON  idx_cons_dim.index_constituent_dim_id = t.index_constituent_dim_id
        AND idx_cons_dim.ds_snpst_dt = to_date(t.snpst_dt_dim_id, 'yyyyMMdd')
        AND idx_cons_dim.ds_rcrd_st = 'ACTIVE'
    WHERE t.snpst_dt_dim_id < (SELECT date_format(MIN(trading_dt), 'yyyyMMdd') FROM idx_days)   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
idx_prior_this AS (   -- [BACKFILL-UAT-NEW]
    SELECT index_code, idx_prior_market_cap, idx_prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
    FROM idx_prior_this_all   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
idx_prior_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        b.index_code,   -- [BACKFILL-UAT-NEW]
        b.trading_dt,   -- [BACKFILL-UAT-NEW]
        CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.index_code ORDER BY b.trading_dt) = 1   -- [BACKFILL-UAT-NEW]
             THEN pt.idx_prior_market_cap   -- [BACKFILL-UAT-NEW]
             ELSE LAG(b.idx_market_cap) OVER (PARTITION BY b.index_code ORDER BY b.trading_dt)   -- [BACKFILL-UAT-NEW]
        END AS idx_prior_market_cap,   -- [BACKFILL-UAT-NEW]
        CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.index_code ORDER BY b.trading_dt) = 1   -- [BACKFILL-UAT-NEW]
             THEN pt.idx_prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
             ELSE LAG(b.idx_free_float_market_cap) OVER (PARTITION BY b.index_code ORDER BY b.trading_dt)   -- [BACKFILL-UAT-NEW]
        END AS idx_prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
    FROM idx_prior_base b   -- [BACKFILL-UAT-NEW]
    LEFT JOIN idx_prior_this pt   -- [BACKFILL-UAT-NEW]
        ON  pt.index_code = b.index_code   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

-- Diem chi so cuoi phien theo Index+Date - phuc vu K_GSTT_53 (LLD dong #11)
mkt_idx_val_all AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val,
        row_number() over (partition by market_id, market_code, trading_dt order by index_time desc, sequence desc) as rn
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        -- [BACKFILL-UAT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'   -- [BACKFILL-UAT-NEW]
),

mkt_idx_val AS (
    SELECT market_code, trading_dt, market_index_val
    FROM mkt_idx_val_all
    WHERE rn = 1
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string) AS security_trading_snpst_dim_id,
    CAST(in_co_di.index_constituent_dim_id AS string)         AS index_constituent_dim_id,
    CAST(date_format(in_co_sn.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(idx_matched_agg.idx_total_matched_vol AS bigint)          AS idx_total_matched_vol,
    CAST(idx_matched_agg.idx_total_matched_val AS decimal(23,2)) AS idx_total_matched_val,
    CAST(idx_foreign_agg.idx_foreign_buy_vol - idx_foreign_agg.idx_foreign_sell_vol AS bigint)            AS idx_foreign_net_vol,
    CAST(idx_foreign_agg.idx_foreign_buy_val - idx_foreign_agg.idx_foreign_sell_val AS decimal(23,2))  AS idx_foreign_net_val,
    CAST(idx_negotiated_agg.idx_total_negotiated_vol AS bigint)          AS idx_total_negotiated_vol,
    CAST(idx_negotiated_agg.idx_total_negotiated_val AS decimal(23,2)) AS idx_total_negotiated_val,
    CAST(mkt_idx_val.market_index_val AS decimal(23,4))          AS idx_market_index_val,
    CAST(idx_cap_agg.idx_market_cap AS decimal(23,2))            AS idx_market_cap,
    CAST(idx_cap_agg.idx_free_float_market_cap AS decimal(23,2)) AS idx_free_float_market_cap,
    CAST(idx_cap_agg.idx_pe AS decimal(10,2))                    AS idx_pe,
    CAST(idx_cap_agg.idx_pb AS decimal(10,2))                    AS idx_pb,
    CAST(idx_cap_agg.idx_eps AS decimal(23,2))                   AS idx_eps,
    CAST(idx_prior_val.idx_prior_market_cap AS decimal(23,2))            AS idx_prior_market_cap,
    CAST(idx_prior_val.idx_prior_free_float_market_cap AS decimal(23,2)) AS idx_prior_free_float_market_cap,
    CAST(idx_foreign_agg.idx_foreign_buy_vol AS bigint)                  AS idx_foreign_buy_vol,
    CAST(idx_foreign_agg.idx_foreign_sell_vol AS bigint)                 AS idx_foreign_sell_vol,
    CAST(idx_foreign_agg.idx_foreign_buy_val AS decimal(23,2))           AS idx_foreign_buy_val,
    CAST(idx_foreign_agg.idx_foreign_sell_val AS decimal(23,2))          AS idx_foreign_sell_val
FROM in_co_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = in_co_sn.symbol
    AND se_tr_sn_di.ds_snpst_dt = in_co_sn.trading_dt   -- [FIRST-TIME 2026-10-18]
LEFT JOIN in_co_di
    ON  in_co_di.index_code = in_co_sn.index_code
    AND in_co_di.ds_snpst_dt = in_co_sn.trading_dt   -- [FIRST-TIME 2026-10-18]
LEFT JOIN idx_matched_agg
    ON  idx_matched_agg.index_code = in_co_sn.index_code
    AND idx_matched_agg.trading_dt = in_co_sn.trading_dt
LEFT JOIN idx_foreign_agg
    ON  idx_foreign_agg.index_code = in_co_sn.index_code
    AND idx_foreign_agg.trading_dt = in_co_sn.trading_dt
LEFT JOIN idx_negotiated_agg
    ON  idx_negotiated_agg.index_code = in_co_sn.index_code
    AND idx_negotiated_agg.trading_dt = in_co_sn.trading_dt
LEFT JOIN idx_cap_agg
    ON  idx_cap_agg.index_code = in_co_sn.index_code
    AND idx_cap_agg.trading_dt = in_co_sn.trading_dt
-- [BACKFILL-UAT-ORIG] LEFT JOIN idx_prior_val
    -- [BACKFILL-UAT-ORIG] ON  idx_prior_val.index_code = in_co_sn.index_code
LEFT JOIN idx_prior_val   -- [BACKFILL-UAT-NEW]
    ON  idx_prior_val.index_code = in_co_sn.index_code   -- [BACKFILL-UAT-NEW]
    AND idx_prior_val.trading_dt = in_co_sn.trading_dt   -- [BACKFILL-UAT-NEW]
LEFT JOIN mkt_idx_val
    ON  mkt_idx_val.market_code = in_co_sn.index_code
    AND mkt_idx_val.trading_dt = in_co_sn.trading_dt
-- [BACKFILL-UAT-ORIG] WHERE in_co_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
