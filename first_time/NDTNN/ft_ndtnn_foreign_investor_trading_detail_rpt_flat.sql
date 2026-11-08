-- [FIRST-TIME] ft_ndtnn_foreign_investor_trading_detail_rpt_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_foreign_investor_trading_detail_rpt_flat (config ft_target='ndtnn_foreign_investor_trading_detail_rpt_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_foreign_investor_trading_detail_rpt_flat
-- Type  : OPERATIONAL
-- 2026-10-16 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- report_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column = report_dt) -> 1 partition = 1 ngay nhu daily.
-- ────────────────────────────────────────────────────────────

SELECT
    f.report_dt,
    f.account_nbr,
    f.symbol,
    f.trade_direction_code,
    f.account_holder_nm,
    f.investor_nm,
    f.execution_vol,
    f.execution_val,
    f.src_stm_code

FROM {{ ft_ref('ft_dtm_foreign_investor_trading_detail_rpt') }} f   -- [FT-NEW] daily: ref('dtm_foreign_investor_trading_detail_rpt')
-- [FT-ORIG] WHERE f.report_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
