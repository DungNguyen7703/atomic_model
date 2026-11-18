-- [FIRST-TIME] ft_gstt_fct_security_trading_intraday_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_security_trading_intraday_flat (config ft_target='gstt_fct_security_trading_intraday_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_fct_security_trading_intraday_flat
-- Type  : FACT
-- 2026-09-14 tuan.nguyenvanb: [BO SUNG theo pull LLD moi] Them cot is_trading_date -
-- JOIN dtm_cdr_dt_dim (dim da rebuild khong partition + BROADCAST, xem ghi chu chi tiet
-- o gstt_fct_stock_portfolio_snpst_flat.sql). cdr_dt van suy truc tiep tu cdr_dt_dim_id
-- nhu cu, khong doi.
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
-- Dong goc giu o dang comment BACKFILL-UAT-ORIG. Revert: bo comment BACKFILL-UAT-ORIG va xoa dong BACKFILL-UAT-NEW (hoac chuyen che do daily bang first_time_mode.py). [BACKFILL-UAT-NEW]
-- 2026-10-22 tuan.nguyenvanb: Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. Khong doi cot/kieu.
-- ────────────────────────────────────────────────────────────

SELECT /*+ BROADCAST(cal) */
    -- FACT Security Trading Intraday
    f.security_trading_snpst_dim_id,
    f.cdr_dt_dim_id,
    f.trading_tms,
    f.open_price_at_time,
    f.high_price_at_time,
    f.low_price_at_time,
    f.close_price_at_time,
    f.cumulative_vol_at_time,
    -- CALENDAR DATE
    to_date(f.cdr_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                 AS is_trading_date,
    -- SECURITY TRADING SNAPSHOT DIMENSION
    scr_dim.symbol                      AS symbol,
    scr_dim.security_full_nm            AS security_full_nm,
    -- [BACKFILL-UAT-ORIG] scr_dim.floor_code AS floor_code,
    COALESCE(sts.floor_code, scr_dim.floor_code) AS floor_code,   -- [BACKFILL-UAT-NEW] theo NGAY (dim MAIN chi giu gia tri moi nhat cua ma)
    -- [BACKFILL-UAT-ORIG] scr_dim.stock_tp_code AS stock_tp_code,
    COALESCE(sts.stock_tp_code, scr_dim.stock_tp_code) AS stock_tp_code,   -- [BACKFILL-UAT-NEW] theo NGAY (dim MAIN chi giu gia tri moi nhat cua ma)
    -- [BACKFILL-UAT-ORIG] scr_dim.stock_tp_nm AS stock_tp_nm,
    CASE WHEN sts.symbol IS NULL THEN scr_dim.stock_tp_nm ELSE {{ ft_stock_tp_nm('sts.floor_code', 'sts.stock_tp_code', 'sts.fund_tp_code') }} END AS stock_tp_nm,   -- [BACKFILL-UAT-NEW] theo NGAY (dim MAIN chi giu gia tri moi nhat cua ma)
    scr_dim.src_stm_code                AS security_trading_src_stm_code

FROM {{ ft_ref('ft_dtm_fct_security_trading_intraday') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.cdr_dt_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr scr_dim
LEFT JOIN {{ ft_ref('ft_dtm_security_trading_snpst_dim') }} scr_dim   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id AND scr_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ON scr_dim.security_trading_snpst_dim_id = f.security_trading_snpst_dim_id   -- [BACKFILL-UAT-NEW]
-- 2026-10-10 tuan.nguyenvanb: san / loai CK theo NGAY lay tu atomic (dim MAIN chi giu san moi nhat, vd BVB UPCOM -> HOSE)   -- [BACKFILL-UAT-NEW]
LEFT JOIN (   -- [BACKFILL-UAT-NEW]
    -- 2026-10-12: dedupe 1 dong / (symbol, ngay) - atomic giu moi ban tin stockinfor trong ngay, join thang nhan moi nen   -- [BACKFILL-UAT-NEW]
    -- len hang nghin lan (fact 299.734 -> 2,8 ty dong). Chi chon 1 ban ghi de tra san/loai CK, KHONG bo nen nao.   -- [BACKFILL-UAT-NEW]
    SELECT symbol, trading_dt, floor_code, stock_tp_code, fund_tp_code   -- [BACKFILL-UAT-NEW]
    FROM (   -- [BACKFILL-UAT-NEW]
        SELECT ticker_symbol AS symbol, ds_snpst_dt AS trading_dt, floor_code, stock_tp_code, fund_tp_code,   -- [BACKFILL-UAT-NEW]
               row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) AS rn   -- [BACKFILL-UAT-NEW]
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW]
        WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'   -- [BACKFILL-UAT-NEW]
    ) x   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
) sts   -- [BACKFILL-UAT-NEW]
    ON  sts.symbol = scr_dim.symbol   -- [BACKFILL-UAT-NEW]
    AND sts.trading_dt = to_date(f.cdr_dt_dim_id, 'yyyyMMdd')   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-ORIG] WHERE f.cdr_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]