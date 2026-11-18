-- [FIRST-TIME] ft_ndtnn_fct_foreign_investor_capital_flow_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_foreign_investor_capital_flow_snpst_flat (config ft_target='ndtnn_fct_foreign_investor_capital_flow_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_capital_flow_snpst_flat
-- Type  : FACT
-- 2026-11-15 claude: [DONG BO LLD O_NDTNN_62 + DDL ClickHouse] them investor_group_nm; thu tu cot ... src_stm_code, investor_group_nm,
-- transaction_cd, snpst_cdr_dt, rpt_code, rpt_dt_dim_id, rpt_cdr_dt (khop 01_create/02_populate); ma hoa PII investor_nm (fn_pii_encrypt).
-- 2026-11-08 nghia.le: [DONG BO daily] them cot transaction_cd (MSGD) cuoi bang.
-- 2026-10-18 nghia.le: [FIX] rpt_cdr_dt thieu nullIf(..., toDate('1970-01-01')) - ban truoc do sot khi dong bo tu
-- daily, co nguy co ghi sentinel date 1970-01-01 thay vi NULL khi LEFT JOIN khong khop tren ClickHouse
-- (join_use_nulls=0). Them nullIf khop dung daily.
-- 2026-10-14 nghia.le: [DONG BO 01_create/02_populate] bo Foreign Investor Reporting Entity Dimension (cot FK + reporting_entity_*) khoi bang flat;
-- thêm cột rpt_dt_dim_id (giữa rpt_code và rpt_cdr_dt) khớp DDL.
-- 2026-10-12 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column) -> 1 partition = 1 ngay nhu daily. Dim doc bang MAIN giong daily.
-- ────────────────────────────────────────────────────────────

SELECT
    f.snpst_dt_dim_id,
    f.rpt_log_id,
    f.section_id,
    f.dynamic_row_order,
    f.period_val,
    f.nationality_nm,
    f.investor_nm,
    f.capital_flow_net_val,
    f.src_stm_code,
    f.investor_group_nm,                 -- [MỚI 2026-11-15, O_NDTNN_62] nhóm NĐT theo row_path: A-Tổ chức / B-Cá nhân
    f.transaction_cd,                    -- MSGD 6 ký tự cuối in hoa — sau investor_group_nm, khớp LLD/DDL ClickHouse
    submission_cal.cdr_dt AS snpst_cdr_dt,
    f.rpt_code,                          -- mã báo cáo IBOU9 (PLIV-TT51, sheet I; O_NDTNN_62) — cột sau snpst_cdr_dt, khớp CK daily/DDL
    f.rpt_dt_dim_id,                     -- [MỚI 2026-10-14] FK ngày chốt số liệu (NULL khi nguồn không có DayReport)
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt   -- [MỚI 2026-10-13] ngày chốt số liệu — LEFT JOIN không khớp trả 1970-01-01 khi join_use_nulls=0 → ép về NULL, khớp daily

FROM {{ ft_ref('ft_dtm_fct_foreign_investor_capital_flow_snpst') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_investor_capital_flow_snpst')
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
-- [FT-ORIG] WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
