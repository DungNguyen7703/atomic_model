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
* 2026-10-16		tuan.nguyenvanb		[LLD v4.50, commit 1d908c6d] idx_pe/idx_pb: mau so COALESCE(IDS, SCMS CTCK) theo tung ma - cong gop LNST TTM / VCSH cua
*                                       CTCK (securities_company_net_profit_after_tax_ttm / securities_company_owner_equity doc tu
*                                       fct_stock_portfolio_snpst). idx_eps giu nguyen (chi LNST IDS). Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
*--------------------------------------------------------------------*
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78 muc a, b] idx_market_cap/idx_free_float_market_cap/idx_pe/idx_pb: SUM von hoa tu cot market_cap/free_float_market_cap cua
*                                       dtm_fct_stock_portfolio_snpst (gia tinh von hoa moi: UPCOM = VWAP phien ke tiep, HOSE/HNX = gia dong cua) thay close_price x so co phieu.
*                                       LNST TTM (idx_pe, idx_eps) doc net_profit_after_tax_ttm tu Fact Stock Portfolio da doi cach chon ky nam/quy. Khong doi cot/kieu -> khong ALTER.
*/

WITH se_tr_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        ds_snpst_dt AS trading_dt,   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
        trading_time,
        close_price,
        floor_code,
        isin_code,
        row_number() over (partition by ticker_symbol order by trading_time desc, sequence desc) as rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

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
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Bridge grain: 1 dong / symbol / index_code / trading_dt
in_co_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        trading_dt,
        index_code,
        row_number() over (partition by ticker_symbol, index_code order by trading_dt desc) as rn
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')   -- [2026-10-14 THEO LLD] trading_dt = :etl_date truoc khi chon rn
),

in_co_sn AS (
    SELECT symbol, trading_dt, index_code
    FROM in_co_sn_all
    WHERE rn = 1
),

-- [SUA 2026-09-14] Index Constituent Dimension gio 1 dong/index_code (khong con symbol)
in_co_di AS (
    SELECT
        index_constituent_dim_id,
        index_code
    FROM {{ ref('dtm_index_constituent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Outstanding Share Quantity - [SUA 2026-09-16 theo LLD] Remap tu pc_share_statistics_hstr
-- (IDS, khong co du lieu hang ngay tren HNX/UPCOM) sang listed_share_information (VSDC
-- outstanding_shares, src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo dung nguon/pattern
-- voi free_float_share_quantity ben duoi (lookback theo symbol) - khong con can pc_fin/
-- atm_public_company_v1 nua vi khong con join qua pc_id.
oss_val_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.outstanding_share_quantity,
        row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    FROM {{ ref('atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

oss_val AS (
    SELECT symbol, outstanding_share_quantity
    FROM oss_val_all
    WHERE rn = 1
),

-- Free Float Share Quantity - ROW_NUMBER dedupe, lookback <= trading_dt (nguon
-- VSDC_OUTSTANDING_SHARES qua atm_listed_share_information, giong fact chinh)
free_float_val_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.free_float_share_quantity,
        row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    FROM {{ ref('atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

free_float_val AS (
    SELECT symbol, free_float_share_quantity
    FROM free_float_val_all
    WHERE rn = 1
),

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
    FROM {{ ref('dtm_fct_stock_portfolio_snpst') }}
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
    LEFT JOIN oss_val oss
        ON  oss.symbol = s.symbol
    LEFT JOIN free_float_val ff
        ON  ff.symbol = s.symbol
    LEFT JOIN se_tr_sn_di std_di
        ON  std_di.symbol = s.symbol
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
    INNER JOIN {{ ref('atm_securities_trade') }} st
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
    INNER JOIN {{ ref('atm_securities_trade') }} st
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
    INNER JOIN {{ ref('atm_securities_trade') }} st
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
-- tai T-1, khong phai T). SELF-REFERENCE {{ this }} de doc lai gia tri da luu tren dong
-- T-1 - cung cach lam voi prior_market_cap ben dtm_fct_stock_portfolio_snpst.
idx_prior_val_all AS (
    SELECT
        idx_cons_dim.index_code,
        t.idx_market_cap             AS idx_prior_market_cap,
        t.idx_free_float_market_cap  AS idx_prior_free_float_market_cap,
        row_number() over (partition by idx_cons_dim.index_code order by t.snpst_dt_dim_id desc) as rn
    FROM {{ this }} t
    INNER JOIN {{ ref('dtm_index_constituent_dim') }}_hstr idx_cons_dim
        ON  idx_cons_dim.index_constituent_dim_id = t.index_constituent_dim_id
        AND idx_cons_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND idx_cons_dim.ds_rcrd_st = 'ACTIVE'
    WHERE t.snpst_dt_dim_id < date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

idx_prior_val AS (
    SELECT index_code, idx_prior_market_cap, idx_prior_free_float_market_cap
    FROM idx_prior_val_all
    WHERE rn = 1
),

-- Diem chi so cuoi phien theo Index+Date - phuc vu K_GSTT_53 (LLD dong #11)
mkt_idx_val_all AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val,
        row_number() over (partition by market_id, market_code, trading_dt order by index_time desc, sequence desc) as rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
LEFT JOIN in_co_di
    ON  in_co_di.index_code = in_co_sn.index_code
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
LEFT JOIN idx_prior_val
    ON  idx_prior_val.index_code = in_co_sn.index_code
LEFT JOIN mkt_idx_val
    ON  mkt_idx_val.market_code = in_co_sn.index_code
    AND mkt_idx_val.trading_dt = in_co_sn.trading_dt
WHERE in_co_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
