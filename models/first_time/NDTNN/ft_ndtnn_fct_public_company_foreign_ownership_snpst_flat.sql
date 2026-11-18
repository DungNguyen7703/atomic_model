-- [FIRST-TIME] ft_ndtnn_fct_public_company_foreign_ownership_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_public_company_foreign_ownership_snpst_flat (config ft_target='ndtnn_fct_public_company_foreign_ownership_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_public_company_foreign_ownership_snpst_flat
-- Type  : FACT
-- 2026-10-18 nghia.le: [DOC README/COMMENT] daily flat da chuyen sang doc fact CHINH (dtm_fct_public_company_foreign_ownership_snpst,
-- khong con _test) nen 2 ben da dong nhat ve nguon; cap nhat lai comment dong 31 cho khop thuc te (truoc do ghi nham daily van doc _test).
-- 2026-10-17 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay snapshot cua tung
-- dong (ft_day_column = snpst_cdr_dt) -> 1 partition = 1 ngay nhu daily.
-- ────────────────────────────────────────────────────────────

SELECT
    -- FACT Fact Public Company Foreign Ownership Snapshot
    f.snpst_dt_dim_id,
    f.public_company_dim_id,
    f.ticker_symbol,
    f.total_issued_share_quantity,
    f.max_foreign_ownership_ratio,
    f.max_foreign_holding_quantity,
    f.current_foreign_holding_quantity,
    f.remaining_foreign_holding_quantity,
    f.src_stm_code,
    f.foreign_holding_value,
    -- CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                       AS snpst_cdr_dt,
    -- PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm

FROM {{ ft_ref('ft_dtm_fct_public_company_foreign_ownership_snpst') }} f   -- ban first-time doc fact CHINH qua ft_dtm_fct_public_company_foreign_ownership_snpst (goc ft_atm_foreign_ownership_info cua GSTT); daily flat cung doc fact CHINH (ref('dtm_fct_public_company_foreign_ownership_snpst')) - 2 ben da dong nhat ve nguon
JOIN {{ ref('dtm_cdr_dt_dim') }} snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [FT-NEW 2026-10-26] thuoc tinh dim cong ty doc bang MAIN cua dtm_public_company_dim (giong daily), KHONG doc _hstr theo ngay
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
-- [FT-ORIG] WHERE snpst_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
