-- [FIRST-TIME] ft_gstt_fct_stock_portfolio_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_stock_portfolio_snpst_flat (config ft_target='gstt_fct_stock_portfolio_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_stock_portfolio_snpst_flat
-- Type  : FACT
-- 2026-11-02 tuan.nguyenvanb: [LLD v4.58, O_GSTT_78] Them 30 cot moi cua mart (24 cot lo chan/lo le, open_interest_quantity, fct_ceiling_price, fct_floor_price, fct_open_price,
-- free_float_market_cap, market_cap) chen ngay sau f.securities_company_owner_equity, dung thu tu mart (ck_snapshot insert theo VI TRI cot): ALTER ... ADD COLUMN ... AFTER chuoi bat dau tu securities_company_owner_equity.
-- 2026-10-15 tuan.nguyenvanb: [LLD v4.49] Them f.foreign_buy_derivative_vol/f.foreign_sell_derivative_vol (K_GSTT_374/375, mart moi) - chen ngay sau f.foreign_net_derivative_vol, dung vi tri nguon mart (model ck_snapshot insert theo VI TRI cot): ALTER ... ADD COLUMN ... AFTER foreign_net_derivative_vol.
-- 2026-10-08 tuan.nguyenvanb: [LLD v4.38, BA cap nhat Mo ta 'Nganh' ngay 2026-10-07, O_GSTT_37]
-- Fallback Nganh cua CTCK dai chung (sc_dim_ctck.securities_company_dim_id IS NOT NULL) doi tu
-- literal 'Tai chinh - Ngan hang' (Code NULL) sang NGANH IDS MA 07000 tra tu dtm_industry_dim
-- (industry_code = '07000'): classification_business_line_nm = industry_nm, business_line_level_1_code
-- = industry_code. Ten/Code rong (TRIM = '') coi nhu NULL (NULLIF(TRIM(...),'')). Dung scalar subquery
-- hang so (industry_dim 1 dong / nganh, khong nhan dong). Co them ds_rcrd_st = 'ACTIVE' (scd4a giu
-- ban ghi da xoa mem). KHONG doi so cot / vi tri cot -> khong can ALTER.
-- 2026-09-22 tuan.nguyenvanb: [DONG BO theo mart/dim] Them f.foreign_net_derivative_vol
-- (KPI moi ben mart) va sec_dim.ceiling_price/sec_dim.floor_price (cot moi ben Dimension,
-- BA bo sung gap STT 23). Vi tri chen dung theo dung thu tu nguon, khong doi cot khac.
-- 2026-10-22 tuan.nguyenvanb: Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. Khong doi cot/kieu.
-- 2026-09-19 tuan.nguyenvanb: nguon dtm_fct_stock_portfolio_snpst rename cot
-- cdr_dt_dim_id -> snpst_dt_dim_id (dong bo convention cac Fact "_snpst" khac).
-- Sua lai tat ca cho doc f.cdr_dt_dim_id -> f.snpst_dt_dim_id; VAN GIU alias
-- "AS cdr_dt_dim_id" o cot dau ra cua flat nay de khong pha vo dashboard/BI
-- dang query truc tiep ClickHouse theo ten cot cu.
-- 2026-09-19 tuan.nguyenvanb: [LLD de8cd57c] Them f.high_price/f.low_price (alias
-- fct_high_price/fct_low_price - tranh trung ten voi sec_dim.high_price/low_price da co
-- san tren Dimension) va f.prior_market_cap/f.prior_free_float_market_cap.
-- 2026-09-07 tuan.nguyenvanb: them hint REPARTITION(20) - ket qua model nay chi
-- ~1-2 nghin dong/ngay (khong co window function), nghi ngo diem nghen thuc su
-- nam o buoc ghi ClickHouse (ck_snapshot: DROP PARTITION + INSERT INTO) chay
-- qua qua it task song song. Test thu, doi/bo neu khong cai thien.
-- 2026-09-14 tuan.nguyenvanb: [SUA THEO HLD v4.13] Bo cot/join Index Constituent
-- Dimension - tach rieng sang gstt_fct_index_constituent_snpst_flat (Bridge). Rename
-- f.close_price -> fct_close_price (giu ca 2 gia tri, khac nguon voi sec_dim.close_price -
-- truoc day xoa nham gay mat du lieu, gio sua dung theo LLD). Them total_matched_vol/
-- total_matched_val (khop lenh thuan, loai thoa thuan).
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi, O_GSTT_21] Them cot
-- fct_reference_price (gia tham chieu luu tren Fact, cung pattern fct_close_price -
-- san da tinh dung theo quy tac rieng tung san, khong can self-join/CASE floor).
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi] Them cot is_trading_date -
-- BAT BUOC phai JOIN dtm_cdr_dt_dim (khac quy uoc cu la khong join). Dim nay da duoc
-- rebuild lai KHONG PARTITION + ANALYZE TABLE (chi ~4400 dong, 2016-2027) va ep
-- BROADCAST(cal) - join khong lam cham query vi Spark broadcast toan bo dim vao memory,
-- khong shuffle/sort. Van giu to_date(cdr_dt_dim_id) de tinh cdr_dt (khong doi, tranh
-- phu thuoc thu tu join).
-- 2026-09-30b tuan.nguyenvanb: [REVIEW LLD] Them total_derivative_negotiated_vol/val (sau total_derivative_val) va bond_negotiated_vol/val (sau bond_trading_val).
-- 2026-09-30 tuan.nguyenvanb: [LLD 2026-09-30] Bo 10 cot individual_* / domestic_institution_*
-- (net/buy/sell val/vol) - mart khong con cac cot nay (chuyen sang investor_category_trading).
-- 2026-09-29 tuan.nguyenvanb: [LLD 38edf44, redesign Nhom 34] Them 5 cot moi tu mart
-- (weighted_average_outstanding_share_quantity(_ttm), owner_equity_weighted_average_
-- outstanding_share_quantity(_ttm), owner_equity_average_4_quarter) - chen ngay sau
-- f.owner_equity dung vi tri nguon (model la ck_snapshot, insert theo VI TRI cot).
-- 2026-09-29b tuan.nguyenvanb: [LLD a27bc1b, fallback Nganh CTCK, O_GSTT_37] Them
-- f.securities_company_dim_id (chen ngay sau f.public_company_dim_id, dung vi tri nguon).
-- classification_business_line_nm doi sang COALESCE voi fallback 'Tai chinh - Ngan hang'
-- khi mã CK la CTCK dai chung (sec_dim_ctck.securities_company_dim_id IS NOT NULL).
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
-- Dong goc giu o dang comment BACKFILL-UAT-ORIG. Revert: bo comment BACKFILL-UAT-ORIG va xoa dong BACKFILL-UAT-NEW (hoac chuyen che do daily bang first_time_mode.py). [BACKFILL-UAT-NEW]
-- ────────────────────────────────────────────────────────────

SELECT /*+ REPARTITION(120), BROADCAST(cal) */
    -- FACT Stock Portfolio Snapshot
    f.security_trading_snpst_dim_id,
    f.public_company_dim_id,
    f.securities_company_dim_id,
    f.snpst_dt_dim_id                              AS cdr_dt_dim_id, -- giu ten cot cu o tang flat de khong pha vo dashboard/BI dang query truc tiep ClickHouse; chi doi ten o nguon mart
    f.total_vol,
    f.total_val,
    f.total_matched_vol,
    f.total_matched_val,
    f.total_derivative_vol,
    f.total_derivative_val,
    f.total_derivative_negotiated_vol,
    f.total_derivative_negotiated_val,
    f.total_negotiated_vol,
    f.total_negotiated_val,
    f.foreign_net_vol,
    f.outstanding_share_quantity,
    f.revenue,
    f.net_profit_after_tax,
    f.net_profit_after_tax_ttm,
    f.owner_equity,
    f.weighted_average_outstanding_share_quantity,
    f.weighted_average_outstanding_share_quantity_ttm,
    f.owner_equity_weighted_average_outstanding_share_quantity,
    f.owner_equity_weighted_average_outstanding_share_quantity_ttm,
    f.owner_equity_average_4_quarter,
    f.foreign_buy_vol,
    f.foreign_sell_vol,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.proprietary_buy_val,
    f.proprietary_sell_val,
    f.proprietary_buy_vol,
    f.proprietary_sell_vol,
    f.bond_trading_vol,
    f.bond_trading_val,
    f.bond_negotiated_vol,
    f.bond_negotiated_val,
    f.close_price                                  AS fct_close_price,
    f.reference_price                              AS fct_reference_price,
    f.free_float_share_quantity,
    f.foreign_net_negotiated_vol,
    f.foreign_net_derivative_vol,
    f.foreign_buy_derivative_vol,
    f.foreign_sell_derivative_vol,
    f.fr_period_end_dt_dim_id,
    f.high_price                                   AS fct_high_price,
    f.low_price                                    AS fct_low_price,
    f.prior_market_cap,
    f.prior_free_float_market_cap,
    f.securities_company_net_profit_after_tax_ttm,   -- [2026-10-16 LLD v4.50] ALTER ... AFTER prior_free_float_market_cap
    f.securities_company_owner_equity,
    f.round_lot_matched_vol,
    f.round_lot_matched_val,
    f.round_lot_negotiated_vol,
    f.round_lot_negotiated_val,
    f.odd_lot_matched_vol,
    f.odd_lot_matched_val,
    f.odd_lot_negotiated_vol,
    f.odd_lot_negotiated_val,
    f.derivative_round_lot_matched_vol,
    f.derivative_round_lot_matched_val,
    f.derivative_round_lot_negotiated_vol,
    f.derivative_round_lot_negotiated_val,
    f.derivative_odd_lot_matched_vol,
    f.derivative_odd_lot_matched_val,
    f.derivative_odd_lot_negotiated_vol,
    f.derivative_odd_lot_negotiated_val,
    f.open_interest_quantity,
    f.bond_round_lot_matched_vol,
    f.bond_round_lot_matched_val,
    f.bond_round_lot_negotiated_vol,
    f.bond_round_lot_negotiated_val,
    f.bond_odd_lot_matched_vol,
    f.bond_odd_lot_matched_val,
    f.bond_odd_lot_negotiated_vol,
    f.bond_odd_lot_negotiated_val,
    f.ceiling_price                                AS fct_ceiling_price,
    f.floor_price                                  AS fct_floor_price,
    f.open_price                                   AS fct_open_price,
    f.free_float_market_cap,
    f.market_cap,
    -- CALENDAR DATE
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')         AS cdr_dt,
    cal.is_trading_date                            AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    sec_dim.symbol                                 AS symbol,
    sec_dim.security_full_nm                       AS security_full_nm,
    -- [BACKFILL-UAT-ORIG] sec_dim.floor_code                             AS floor_code,
    COALESCE(sts.floor_code, sec_dim.floor_code)   AS floor_code,   -- [BACKFILL-UAT-NEW] san theo NGAY (dim MAIN chi giu san moi nhat, vd BVB UPCOM -> HOSE)
    -- [BACKFILL-UAT-ORIG] sec_dim.stock_tp_code                          AS stock_tp_code,
    COALESCE(sts.stock_tp_code, sec_dim.stock_tp_code) AS stock_tp_code,   -- [BACKFILL-UAT-NEW] theo NGAY
    -- [BACKFILL-UAT-ORIG] sec_dim.stock_tp_nm                            AS stock_tp_nm,
    CASE WHEN sts.symbol IS NULL THEN sec_dim.stock_tp_nm ELSE {{ ft_stock_tp_nm('sts.floor_code', 'sts.stock_tp_code', 'sts.fund_tp_code') }} END AS stock_tp_nm,   -- [BACKFILL-UAT-NEW] theo NGAY
    sec_dim.underlying_symbol                      AS underlying_symbol,
    sec_dim.isin_code                              AS isin_code,
    sec_dim.issuer_nm                              AS issuer_nm,
    -- [BACKFILL-UAT-ORIG] sec_dim.listed_share_count                     AS listed_share_count,
    sts.listed_share_count                     AS listed_share_count,   -- [BACKFILL-UAT-NEW]
    sec_dim.first_trading_dt                       AS first_trading_dt,
    sec_dim.last_trading_dt                        AS last_trading_dt,
    sec_dim.issue_dt                               AS issue_dt,
    sec_dim.maturity_dt                            AS maturity_dt,
    sec_dim.fund_tp_code                           AS fund_tp_code,
    sec_dim.covered_warrant_tp_code                AS covered_warrant_tp_code,
    sec_dim.exercise_price                         AS exercise_price,
    sec_dim.exercise_ratio                         AS exercise_ratio,
    sec_dim.exercise_style_code                    AS exercise_style_code,
    sec_dim.put_or_call_code                       AS put_or_call_code,
    sec_dim.contract_multiplier                    AS contract_multiplier,
    sec_dim.maturity_month_year                    AS maturity_month_year,
    -- [BACKFILL-UAT-ORIG] sec_dim.coupon_rate                            AS coupon_rate,
    sts.coupon_rate                            AS coupon_rate,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.yield                                  AS yield,
    sts.yield                                  AS yield,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.open_price                             AS open_price,
    sts.open_price                             AS open_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.high_price                             AS high_price,
    sts.high_price                             AS high_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.low_price                              AS low_price,
    sts.low_price                              AS low_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.ceiling_price                          AS ceiling_price,
    sts.ceiling_price                          AS ceiling_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.floor_price                            AS floor_price,
    sts.floor_price                            AS floor_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.reference_price                        AS reference_price,
    sts.reference_price                        AS reference_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.close_price                            AS close_price,
    sts.close_price                            AS close_price,   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] sec_dim.price_change                           AS price_change,
    sts.price_change                           AS price_change,   -- [BACKFILL-UAT-NEW]
    sec_dim.src_stm_code                           AS security_trading_snpst_src_stm_code,
    -- PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code                     AS public_company_code,
    pc_dim.equity_ticker_symbol                    AS equity_ticker_symbol,
    pc_dim.public_company_nm                       AS public_company_nm,
    pc_dim.equity_listing_exchange_code            AS equity_listing_exchange_code,
    COALESCE(NULLIF(TRIM(pc_dim.business_line_level_1_code), ''), CASE WHEN sc_dim_ctck.securities_company_dim_id IS NOT NULL THEN (SELECT industry_code FROM {{ ref('dtm_industry_dim') }} WHERE industry_code = '07000' AND ds_rcrd_st = 'ACTIVE' LIMIT 1) END) AS business_line_level_1_code,
    pc_dim.ids_registration_dt                     AS ids_registration_dt,
    pc_dim.public_company_status_code              AS public_company_status_code,
    COALESCE(NULLIF(TRIM(pc_dim.classification_business_line_nm), ''), CASE WHEN sc_dim_ctck.securities_company_dim_id IS NOT NULL THEN (SELECT industry_nm FROM {{ ref('dtm_industry_dim') }} WHERE industry_code = '07000' AND ds_rcrd_st = 'ACTIVE' LIMIT 1) END) AS classification_business_line_nm,
    pc_dim.public_company_english_nm               AS public_company_english_nm,
    pc_dim.enterprise_tp_code                      AS enterprise_tp_code,
    pc_dim.public_company_tp_code                  AS public_company_tp_code,
    pc_dim.head_office_province_nm                 AS head_office_province_nm,
    pc_dim.operating_status_code                   AS operating_status_code,
    pc_dim.has_state_ownership_indicator           AS has_state_ownership_indicator,
    pc_dim.charter_capital_amt                     AS charter_capital_amt,
    pc_dim.first_registration_dt                   AS first_registration_dt,
    pc_dim.latest_registration_dt                  AS latest_registration_dt,
    pc_dim.latest_registration_province_nm         AS latest_registration_province_nm,
    pc_dim.ids_registration_indicator              AS ids_registration_indicator,
    pc_dim.public_company_form_code                AS public_company_form_code,
    pc_dim.former_state_owned_indicator             AS former_state_owned_indicator,
    pc_dim.foreign_direct_investment_indicator     AS foreign_direct_investment_indicator,
    pc_dim.has_parent_company_indicator            AS has_parent_company_indicator,
    pc_dim.has_subsidiary_indicator                AS has_subsidiary_indicator,
    pc_dim.has_joint_venture_indicator              AS has_joint_venture_indicator,
    pc_dim.ipo_company_indicator                   AS ipo_company_indicator,
    pc_dim.src_stm_code                            AS public_company_src_stm_code

FROM {{ ft_ref('ft_dtm_fct_stock_portfolio_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr sec_dim
LEFT JOIN {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr sec_dim   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN (ma INACTIVE o MAIN -> rong)
    -- [BACKFILL-UAT-ORIG] ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND sec_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ON sec_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id   -- [BACKFILL-UAT-NEW]
    AND sec_dim.ds_snpst_dt = to_date(f.snpst_dt_dim_id, 'yyyyMMdd')   -- [FIRST-TIME 2026-10-18]
    AND sec_dim.ds_rcrd_st = 'ACTIVE'
-- 2026-10-09 tuan.nguyenvanb: gia/KLNY theo NGAY lay tu atomic (dim MAIN chi giu gia moi nhat cua ma, khong dung cho tung ngay)   -- [BACKFILL-UAT-NEW]
LEFT JOIN (   -- [BACKFILL-UAT-NEW]
    -- 2026-10-12: dedupe 1 dong / (symbol, ngay) - atomic giu moi ban tin stockinfor trong ngay, join thang nhan dong flat   -- [BACKFILL-UAT-NEW]
    SELECT symbol, trading_dt, open_price, high_price, low_price, ceiling_price, floor_price,   -- [BACKFILL-UAT-NEW]
           reference_price, close_price, price_change, listed_share_count,   -- [BACKFILL-UAT-NEW]
           coupon_rate, yield, floor_code, stock_tp_code, fund_tp_code   -- [BACKFILL-UAT-NEW]
    FROM (   -- [BACKFILL-UAT-NEW]
        SELECT ticker_symbol AS symbol, ds_snpst_dt AS trading_dt, open_price, high_price, low_price, ceiling_price, floor_price,   -- [BACKFILL-UAT-NEW] [DOI THEO ATOMIC MOI 2026-10-10] atomic bo trading_dt
               reference_price, close_price, price_change, listed_share_count,   -- [BACKFILL-UAT-NEW]
               coupon_rate, yield, floor_code, stock_tp_code, fund_tp_code,   -- [BACKFILL-UAT-NEW]
               row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) AS rn   -- [BACKFILL-UAT-NEW]
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW]
        WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'   -- [BACKFILL-UAT-NEW]
    ) x   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
) sts   -- [BACKFILL-UAT-NEW]
    ON  sts.symbol = sec_dim.symbol   -- [BACKFILL-UAT-NEW]
    AND sts.trading_dt = to_date(f.snpst_dt_dim_id, 'yyyyMMdd')   -- [BACKFILL-UAT-NEW]
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} sc_dim_ctck
    ON sc_dim_ctck.securities_company_dim_id = f.securities_company_dim_id
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]