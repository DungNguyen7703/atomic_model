/*
*--------------------------------------------------------------------*
* Program code: ft_tmp_sp_pc_financials
* Program name: Bang tam first-time cua ft_dtm_fct_stock_portfolio_snpst
*--------------------------------------------------------------------*
* Modified management
* Date			User				Description
* 2026-11-09		tuan.nguyenvanb		[TACH BANG TAM, khong doi logic] Khoi tai chinh (pc_financials: doanh thu, LNST, VCSH, WAOS, ky TTM)
*                                       Cat NGUYEN VAN cac CTE tu ft_dtm_fct_stock_portfolio_snpst de moi cau lenh co ke hoach thuc thi nho (1 cau qua lon lam driver Spark treo).
*                                       Bang tam first-time (materialized table, ghi de moi lan chay), CHI phuc vu model ft_dtm_fct_stock_portfolio_snpst - phai chay TRUOC model do.
*--------------------------------------------------------------------*
*/

WITH -- 2026-10-08 tuan.nguyenvanb [BACKFILL-UAT-ONEPASS] Truc ngay giao dich cua lan chay mot luot.   -- [BACKFILL-UAT-NEW]
trade_dates AS (   -- [BACKFILL-UAT-NEW]
    -- [TOI UU 2026-11-09, chi ban first_time] Lay truc ngay thang tu cot ds_snpst_dt cua snapshot (cung tap ngay voi se_tr_sn vi se_tr_sn_all chi gom nhom theo ticker, ngay),
    -- khong tinh lai phep gom nhom ca nam chi de lay danh sach ngay (CTE nay duoc tham chieu o nhieu khoi).
    SELECT DISTINCT CAST(ds_snpst_dt AS date) AS trading_dt   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW]
),

-- Public Company (goc, dung cho join tai chinh — khac pu_co dung cho FK dim ben tren)
-- [SUA 2026-09-17] Dedupe 1 dong / equity_ticker_symbol - IDS co the co >1 ho so cung ma
-- CK (du lieu migrate/trung), neu khong dedupe se nhan dong o pc_financials.
pc_fin_all AS (
    SELECT
        pc_id,
        pc_code,
        equity_ticker_symbol,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint)) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc_fin AS (
    SELECT pc_id, equity_ticker_symbol
    FROM pc_fin_all
    WHERE rn = 1
),

-- ============================================================================
-- [SUA 2026-09-17] Viet lai toan bo khoi tai chinh cho khop 100% logic cau test
-- nghiep vu (BA), sau khi trace ra net_profit_after_tax/owner_equity NULL toan bo.
-- Nhung khac biet da sua (CAN RAISE DESIGN cap nhat LLD):
--   (1) Moi atomic scd4a doc qua _hstr + loc ds_snpst_dt/ds_rcrd_st (truoc day doc
--       thang bang current-state: khong point-in-time, va rong neu scd4a fail giua
--       chung do da DELETE truoc khi INSERT).
--   (2) BO dieu kien EXISTS violation_report - thuc do tren SHB: 402 submission hop le
--       chi con 13 sau dieu kien nay; cau test nghiep vu khong he co dieu kien nay.
--   (3) BO ep cung "ky lien truoc" (CEIL(month/3)-1) cho Revenue/NPAT: SHB khong nop
--       ky Q2/2026 -> ra NULL. Doi sang lay KY GAN NHAT co du lieu, giong cau test.
--   (4) Dedupe 1 ban ghi / (pc_id, rpt_year, rpt_quarter) TRUOC (uu tien HN>TH>ME>RI,
--       submission_dt moi nhat) roi moi xep hang ky - truoc day rank thang tren toan bo
--       dong nen TTM co the gom 4 dong CUNG 1 KY thay vi 4 ky khac nhau.
--   (5) Chi lay rpt_quarter IN (1,2,3,4) va ky ket thuc <= ngay giao dich - nguon IDS
--       con co ky 5/6 (ban nien/ca nam) lam lech xep hang ky.
-- ============================================================================
pc_rpt_sub_valid AS (
    SELECT
        prs.pc_id,
        prs.rpt_year,
        prs.rpt_quarter,
        prs.fr_code,
        prs.submission_dt,
        CASE prs.rpt_quarter
            WHEN 1 THEN to_date(concat(prs.rpt_year, '-03-31'))
            WHEN 2 THEN to_date(concat(prs.rpt_year, '-06-30'))
            WHEN 3 THEN to_date(concat(prs.rpt_year, '-09-30'))
            WHEN 4 THEN to_date(concat(prs.rpt_year, '-12-31'))
            WHEN 5 THEN to_date(concat(prs.rpt_year, '-12-31'))
        END AS period_end_dt
    FROM {{ ref('atm_pc_report_submission') }} prs
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        AND prs.ds_rcrd_st = 'ACTIVE'
        AND prs.approval_status_code = 'APPROVED'
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        AND prs.rpt_quarter IN (1,2,3,4,5)   -- [2026-11-02 LLD v4.58 muc b] them ky NAM (rpt_quarter = 5) de chon ky LNST TTM
),

-- 1 ban ghi / (cong ty, nam, quy) - uu tien HN>TH>ME>RI roi submission_dt moi nhat
-- (tuong duong CTE Company_data_chuan cua cau test), chi giu ky da ket thuc <= ngay giao dich
pc_rpt_sub_dedup_ranked AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.pc_id, s.rpt_year, s.rpt_quarter
            ORDER BY
                CASE SUBSTR(s.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                s.submission_dt DESC
        ) AS rn
    FROM pc_rpt_sub_valid s
    -- [BACKFILL-UAT-ORIG] WHERE s.period_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    -- [BACKFILL-UAT-ONEPASS] bo loc ky theo etl_date: partition (pc,nam,quy) da co dinh period_end_dt nen khong anh huong xep hang; loc ky theo tung ngay chuyen xuong pc_rpt_sub_recent4   -- [BACKFILL-UAT-NEW]
),

pc_rpt_sub_dedup AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code, period_end_dt
    FROM pc_rpt_sub_dedup_ranked
    WHERE rn = 1
),

-- Gia tri tung chi tieu THEO TUNG KY (tuong duong CTE Chitiet_DN cua cau test)
revenue_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS revenue
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

npat_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS net_profit_after_tax
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

owner_equity_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS owner_equity
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCDKT%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '400')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '500')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

-- [SUA 2026-09-23, FIX theo doi chieu HKT] Ky "hop le" = ky co IT NHAT 1 trong 3 chi
-- tieu (Doanh thu/LNST/VCSH) duoc join dung form (financial_statement_tp_code =
-- SUBSTR(fr_template_code,1,2)) - dung y het khai niem Chitiet_DN cua cau test (1 dong
-- chi ton tai khi >=1 chi tieu match). KHONG dung toan bo pc_rpt_sub_dedup (moi ky nop
-- bao cao bat ke form dung/sai) nhu ban truoc - vi ky FORM SAI HOAN TOAN (vd HKT 2025-Q4:
-- nop dang RI nhung TOAN BO du lieu nam duoi catalog ME, khong chi tieu nao khop) van bi
-- tinh vao lam anchor, cho VCSH=0 SAI trong khi test/BA muon LUI VE ky hop le gan nhat
-- (2025-Q3, co VCSH that). Phan biet 2 loai thieu du lieu:
--   - Ky hop le nhung THIEU 1 CHI TIEU rieng (vd AMV 2026-Q1: co VCSH, khong co LNST)
--     -> VAN la anchor, chi tieu thieu = 0 (KHONG lui ky) - giu nguyen theo BA da xac
--     nhan truoc do.
--   - Ky KHONG CO chi tieu nao hop le (form sai hoan toan, vd HKT 2025-Q4)
--     -> KHONG duoc tinh la 1 ky - lui ve ky hop le gan nhat truoc do.
pc_rpt_valid_periods AS (
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM revenue_by_period
    UNION
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM npat_by_period
    UNION
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM owner_equity_by_period
),

-- [BACKFILL-UAT-ORIG] pc_rpt_sub_recent4 AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] p.*,
        -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (
            -- [BACKFILL-UAT-ORIG] PARTITION BY p.pc_id
            -- [BACKFILL-UAT-ORIG] ORDER BY p.rpt_year DESC, p.rpt_quarter DESC
        -- [BACKFILL-UAT-ORIG] ) AS rn
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_valid_periods p
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Xep hang ky BCTC THEO TUNG NGAY: voi moi (cong ty, trading_dt) chi xet cac ky co   -- [BACKFILL-UAT-NEW]
-- period_end_dt <= trading_dt (giong daily: pc_rpt_sub_dedup_ranked loc period_end_dt <= etl_date), giu 4 ky gan nhat   -- [BACKFILL-UAT-NEW]
-- (moi noi dung ben duoi chi dung rn = 1 hoac rn <= 4).   -- [BACKFILL-UAT-NEW]
pc_rpt_sub_recent4 AS (   -- [BACKFILL-UAT-NEW]
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt, trading_dt, rn   -- [BACKFILL-UAT-NEW]
    FROM (   -- [BACKFILL-UAT-NEW]
        SELECT /*+ BROADCAST(td) */   -- [BACKFILL-UAT-NEW]
            p.pc_id,   -- [BACKFILL-UAT-NEW]
            p.rpt_year,   -- [BACKFILL-UAT-NEW]
            p.rpt_quarter,   -- [BACKFILL-UAT-NEW]
            p.period_end_dt,   -- [BACKFILL-UAT-NEW]
            td.trading_dt,   -- [BACKFILL-UAT-NEW]
            ROW_NUMBER() OVER (   -- [BACKFILL-UAT-NEW]
                PARTITION BY p.pc_id, td.trading_dt   -- [BACKFILL-UAT-NEW]
                ORDER BY p.rpt_year DESC, p.rpt_quarter DESC   -- [BACKFILL-UAT-NEW]
            ) AS rn   -- [BACKFILL-UAT-NEW]
        FROM pc_rpt_valid_periods p   -- [BACKFILL-UAT-NEW]
        INNER JOIN trade_dates td   -- [BACKFILL-UAT-NEW]
            ON  p.period_end_dt <= td.trading_dt   -- [BACKFILL-UAT-NEW]
            AND p.rpt_quarter <> 5   -- [2026-11-02] chi cac ky QUY; ky NAM chi dung cho LNST TTM (pc_rpt_ttm_sel)
    ) t   -- [BACKFILL-UAT-NEW]
    WHERE rn <= 4   -- [BACKFILL-UAT-NEW]
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc b] Chon ky LNST TTM THEO TUNG NGAY: ky gan nhat da cong bo la NAM (rpt_quarter = 5) -> lay LNST ky nam;
-- la QUY -> cong don 4 quy gan nhat, phai du 4 quy (so quy >= 4). Chi ap dung cho net_profit_after_tax_ttm va WAOS TTM.
pc_rpt_ttm_rank AS (
    SELECT /*+ BROADCAST(td) */
        p.pc_id,
        p.rpt_year,
        p.rpt_quarter,
        p.period_end_dt,
        td.trading_dt,
        FIRST_VALUE(p.rpt_quarter) OVER (PARTITION BY p.pc_id, td.trading_dt ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS q_latest,
        ROW_NUMBER() OVER (PARTITION BY p.pc_id, td.trading_dt ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS rn_all,
        -- [TOI UU 2026-11-09, chi ban first_time] rn_q / so_quy viet lai de CUNG partition+order voi rn_all -> Spark gop 1 lan sort thay vi 3 (bang ~hang chuc trieu dong). Ket qua tuong duong (da doi chieu tren du lieu mau):
        -- rn_q chi dung cho ky QUY (rpt_quarter <> 5): thu tu trong nhom quy = tong tich luy cua co 'la quy' theo cung thu tu; so_quy = tong so ky quy cua (cong ty, ngay).
        SUM(CASE WHEN p.rpt_quarter <> 5 THEN 1 ELSE 0 END) OVER (PARTITION BY p.pc_id, td.trading_dt ORDER BY p.rpt_year DESC, p.rpt_quarter DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn_q,
        SUM(CASE WHEN p.rpt_quarter <> 5 THEN 1 ELSE 0 END) OVER (PARTITION BY p.pc_id, td.trading_dt ORDER BY p.rpt_year DESC, p.rpt_quarter DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS so_quy
    FROM pc_rpt_valid_periods p
    INNER JOIN trade_dates td
        ON  p.period_end_dt <= td.trading_dt
),

pc_rpt_ttm_sel AS (
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt, trading_dt, q_latest
    FROM pc_rpt_ttm_rank
    WHERE (q_latest = 5 AND rn_all = 1)
        OR (q_latest <> 5 AND rpt_quarter <> 5 AND rn_q <= 4 AND so_quy >= 4)
),

-- ============================================================================
-- [SUA 2026-10-06, LLD v4.32 - rule GSDC] Revenue / Net Profit After Tax (point-in-time)
-- Doi sang dung rule bao cao tai chinh cua GSDC (dtm_fct_public_company_financial_smy_snpst):
--   - Ky: BCTC DINH KY QUY (financial_report.news_tp_code='DINH_KY', src IDS_FORMS), fr_code
--     LIKE '%QUAR', form HN>TH>ME>RI, quy 1-4, APPROVED, submission_dt <= etl_date; chot 1
--     bao cao/ky (rn0) roi lay ky GAN NHAT da cong bo (rn1) - KHONG lui ky khi ky do thieu
--     chi tieu (gia tri NULL, khong fallback, khong COALESCE 0).
--   - fr_value: data_val IS NOT NULL, dedupe 1 o / (pc,nam,quy,catalog,row,column) theo
--     ds_rcrd_udt_dt/ds_rcrd_isrt_dt/fr_val_code DESC (nhu GSDC); fr_catalog.fr_year =
--     rpt_year, src IDS_REPORT_CATALOG/IDS_RROW/IDS_RCOL.
-- CHI ap cho Revenue va Net Profit After Tax (point-in-time). Net Profit After Tax TTM,
-- Owner Equity, Fr Period End Date, WAOS GIU NGUYEN (khong doi trong LLD lan nay).
-- ============================================================================
gsdc_fr_periodic AS (
    SELECT fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

-- [BACKFILL-UAT-ORIG] gsdc_sub_ranked AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] prs.pc_id,
        -- [BACKFILL-UAT-ORIG] prs.rpt_year,
        -- [BACKFILL-UAT-ORIG] prs.rpt_quarter,
        -- [BACKFILL-UAT-ORIG] prs.fr_code,
        -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (
            -- [BACKFILL-UAT-ORIG] PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter
            -- [BACKFILL-UAT-ORIG] ORDER BY
                -- [BACKFILL-UAT-ORIG] CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                -- [BACKFILL-UAT-ORIG] prs.submission_dt DESC
        -- [BACKFILL-UAT-ORIG] ) AS rn0
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_pc_report_submission') }} prs
    -- [BACKFILL-UAT-ORIG] WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        -- [BACKFILL-UAT-ORIG] AND prs.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND prs.approval_status_code = 'APPROVED'
        -- [BACKFILL-UAT-ORIG] AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)
        -- [BACKFILL-UAT-ORIG] AND prs.fr_code LIKE '%QUAR'
        -- [BACKFILL-UAT-ORIG] AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        -- [BACKFILL-UAT-ORIG] AND prs.rpt_quarter IN (1,2,3,4)
        -- [BACKFILL-UAT-ORIG] AND prs.submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] gsdc_sub_anchor AS (
    -- [BACKFILL-UAT-ORIG] SELECT pc_id, rpt_year, rpt_quarter, fr_code
    -- [BACKFILL-UAT-ORIG] FROM (
        -- [BACKFILL-UAT-ORIG] SELECT
            -- [BACKFILL-UAT-ORIG] r.*,
            -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (PARTITION BY r.pc_id ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1
        -- [BACKFILL-UAT-ORIG] FROM gsdc_sub_ranked r
        -- [BACKFILL-UAT-ORIG] WHERE r.rn0 = 1
    -- [BACKFILL-UAT-ORIG] ) t
    -- [BACKFILL-UAT-ORIG] WHERE rn1 = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Rule GSDC theo tung ngay: chi xet bao cao co submission_dt <= trading_dt (giong daily:   -- [BACKFILL-UAT-NEW]
-- submission_dt <= etl_date). Bo cong ty co ky nop moi nhat (rn1) tinh RIENG cho tung trading_dt.   -- [BACKFILL-UAT-NEW]
gsdc_sub_ranked AS (   -- [BACKFILL-UAT-NEW]
    SELECT /*+ BROADCAST(td) */   -- [BACKFILL-UAT-NEW]
        prs.pc_id,   -- [BACKFILL-UAT-NEW]
        prs.rpt_year,   -- [BACKFILL-UAT-NEW]
        prs.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        prs.fr_code,   -- [BACKFILL-UAT-NEW]
        td.trading_dt,   -- [BACKFILL-UAT-NEW]
        ROW_NUMBER() OVER (   -- [BACKFILL-UAT-NEW]
            PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter, td.trading_dt   -- [BACKFILL-UAT-NEW]
            ORDER BY   -- [BACKFILL-UAT-NEW]
                CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,   -- [BACKFILL-UAT-NEW]
                prs.submission_dt DESC   -- [BACKFILL-UAT-NEW]
        ) AS rn0   -- [BACKFILL-UAT-NEW]
    FROM {{ ref('atm_pc_report_submission') }} prs   -- [BACKFILL-UAT-NEW]
    INNER JOIN trade_dates td   -- [BACKFILL-UAT-NEW]
        ON  prs.submission_dt <= td.trading_dt   -- [BACKFILL-UAT-NEW]
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'   -- [BACKFILL-UAT-NEW]
        AND prs.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND prs.approval_status_code = 'APPROVED'   -- [BACKFILL-UAT-NEW]
        AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)   -- [BACKFILL-UAT-NEW]
        AND prs.fr_code LIKE '%QUAR'   -- [BACKFILL-UAT-NEW]
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')   -- [BACKFILL-UAT-NEW]
        AND prs.rpt_quarter IN (1,2,3,4)   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
-- (cong ty, trading_dt) -> ky anchor   -- [BACKFILL-UAT-NEW]
gsdc_sub_anchor_d AS (   -- [BACKFILL-UAT-NEW]
    SELECT pc_id, trading_dt, rpt_year, rpt_quarter, fr_code   -- [BACKFILL-UAT-NEW]
    FROM (   -- [BACKFILL-UAT-NEW]
        SELECT   -- [BACKFILL-UAT-NEW]
            r.*,   -- [BACKFILL-UAT-NEW]
            ROW_NUMBER() OVER (PARTITION BY r.pc_id, r.trading_dt ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1   -- [BACKFILL-UAT-NEW]
        FROM gsdc_sub_ranked r   -- [BACKFILL-UAT-NEW]
        WHERE r.rn0 = 1   -- [BACKFILL-UAT-NEW]
    ) t   -- [BACKFILL-UAT-NEW]
    WHERE rn1 = 1   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
-- cac ky anchor phan biet (doc fr_value mot lan cho moi ky, khong lap theo ngay)   -- [BACKFILL-UAT-NEW]
gsdc_sub_anchor AS (   -- [BACKFILL-UAT-NEW]
    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code   -- [BACKFILL-UAT-NEW]
    FROM gsdc_sub_anchor_d   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] gsdc_fr_value AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] a.pc_id,
        -- [BACKFILL-UAT-ORIG] a.rpt_year,
        -- [BACKFILL-UAT-ORIG] a.rpt_quarter,
        -- [BACKFILL-UAT-ORIG] a.fr_code,
        -- [BACKFILL-UAT-ORIG] fv.fr_catalog_id,
        -- [BACKFILL-UAT-ORIG] fv.row_code,
        -- [BACKFILL-UAT-ORIG] fv.column_code,
        -- [BACKFILL-UAT-ORIG] fv.data_val,
        -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (
            -- [BACKFILL-UAT-ORIG] PARTITION BY fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code
            -- [BACKFILL-UAT-ORIG] ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC
        -- [BACKFILL-UAT-ORIG] ) AS rn
    -- [BACKFILL-UAT-ORIG] FROM gsdc_sub_anchor a
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_value') }} fv
        -- [BACKFILL-UAT-ORIG] ON  fv.pc_id = a.pc_id
        -- [BACKFILL-UAT-ORIG] AND fv.rpt_year = a.rpt_year
        -- [BACKFILL-UAT-ORIG] AND fv.rpt_quarter = a.rpt_quarter
        -- [BACKFILL-UAT-ORIG] AND fv.src_stm_code = 'IDS_DATA'
        -- [BACKFILL-UAT-ORIG] AND fv.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fv.data_val IS NOT NULL
-- [BACKFILL-UAT-ORIG] ),
gsdc_fr_value AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        a.pc_id,   -- [BACKFILL-UAT-NEW]
        a.rpt_year,   -- [BACKFILL-UAT-NEW]
        a.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        a.fr_code,   -- [BACKFILL-UAT-NEW]
        fv.fr_catalog_id,   -- [BACKFILL-UAT-NEW]
        fv.row_code,   -- [BACKFILL-UAT-NEW]
        fv.column_code,   -- [BACKFILL-UAT-NEW]
        fv.cell_val AS data_val,   -- [BACKFILL-UAT-NEW]
        ROW_NUMBER() OVER (   -- [BACKFILL-UAT-NEW]
            PARTITION BY a.fr_code, fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code   -- [BACKFILL-UAT-NEW]
            ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC   -- [BACKFILL-UAT-NEW]
        ) AS rn   -- [BACKFILL-UAT-NEW]
    FROM gsdc_sub_anchor a   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_value') }} fv   -- [BACKFILL-UAT-NEW]
        ON  fv.pc_id = a.pc_id   -- [BACKFILL-UAT-NEW]
        AND fv.rpt_year = a.rpt_year   -- [BACKFILL-UAT-NEW]
        AND fv.rpt_quarter = a.rpt_quarter   -- [BACKFILL-UAT-NEW]
        AND fv.src_stm_code = 'IDS_DATA'   -- [BACKFILL-UAT-NEW]
        AND fv.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fv.cell_val IS NOT NULL   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] revenue_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] v.pc_id,
        -- [BACKFILL-UAT-ORIG] SUM(v.data_val) AS revenue
    -- [BACKFILL-UAT-ORIG] FROM gsdc_fr_value v
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_catalog') }} fc
        -- [BACKFILL-UAT-ORIG] ON  fc.fr_catalog_id = v.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fc.fr_year = CAST(v.rpt_year AS string)
        -- [BACKFILL-UAT-ORIG] AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        -- [BACKFILL-UAT-ORIG] AND fc.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        -- [BACKFILL-UAT-ORIG] AND fc.rpt_code LIKE 'BCKQKD%'
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_row') }} frt
        -- [BACKFILL-UAT-ORIG] ON  frt.row_code = v.row_code
        -- [BACKFILL-UAT-ORIG] AND frt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND frt.src_stm_code = 'IDS_RROW'
        -- [BACKFILL-UAT-ORIG] AND frt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND (
            -- [BACKFILL-UAT-ORIG] (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            -- [BACKFILL-UAT-ORIG] OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        -- [BACKFILL-UAT-ORIG] )
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_column') }} fclt
        -- [BACKFILL-UAT-ORIG] ON  fclt.column_code = v.column_code
        -- [BACKFILL-UAT-ORIG] AND fclt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fclt.src_stm_code = 'IDS_RCOL'
        -- [BACKFILL-UAT-ORIG] AND fclt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fclt.column_description_reference = '1'
    -- [BACKFILL-UAT-ORIG] WHERE v.rn = 1
    -- [BACKFILL-UAT-ORIG] GROUP BY v.pc_id
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Doanh thu theo ky anchor (pc, nam, quy, fr_code); gan vao ngay o pc_financials.   -- [BACKFILL-UAT-NEW]
revenue_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        v.pc_id,   -- [BACKFILL-UAT-NEW]
        v.rpt_year,   -- [BACKFILL-UAT-NEW]
        v.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        v.fr_code,   -- [BACKFILL-UAT-NEW]
        SUM(v.data_val) AS revenue   -- [BACKFILL-UAT-NEW]
    FROM gsdc_fr_value v   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_catalog') }} fc   -- [BACKFILL-UAT-NEW]
        ON  fc.fr_catalog_id = v.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fc.fr_year = CAST(v.rpt_year AS string)   -- [BACKFILL-UAT-NEW]
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'   -- [BACKFILL-UAT-NEW]
        AND fc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)   -- [BACKFILL-UAT-NEW]
        AND fc.rpt_code LIKE 'BCKQKD%'   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_row') }} frt   -- [BACKFILL-UAT-NEW]
        ON  frt.row_code = v.row_code   -- [BACKFILL-UAT-NEW]
        AND frt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND frt.src_stm_code = 'IDS_RROW'   -- [BACKFILL-UAT-NEW]
        AND frt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND (   -- [BACKFILL-UAT-NEW]
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')   -- [BACKFILL-UAT-NEW]
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')   -- [BACKFILL-UAT-NEW]
        )   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_column') }} fclt   -- [BACKFILL-UAT-NEW]
        ON  fclt.column_code = v.column_code   -- [BACKFILL-UAT-NEW]
        AND fclt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fclt.src_stm_code = 'IDS_RCOL'   -- [BACKFILL-UAT-NEW]
        AND fclt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fclt.column_description_reference = '1'   -- [BACKFILL-UAT-NEW]
    WHERE v.rn = 1   -- [BACKFILL-UAT-NEW]
    GROUP BY v.pc_id, v.rpt_year, v.rpt_quarter, v.fr_code   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] npat_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] v.pc_id,
        -- [BACKFILL-UAT-ORIG] SUM(v.data_val) AS net_profit_after_tax
    -- [BACKFILL-UAT-ORIG] FROM gsdc_fr_value v
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_catalog') }} fc
        -- [BACKFILL-UAT-ORIG] ON  fc.fr_catalog_id = v.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fc.fr_year = CAST(v.rpt_year AS string)
        -- [BACKFILL-UAT-ORIG] AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        -- [BACKFILL-UAT-ORIG] AND fc.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        -- [BACKFILL-UAT-ORIG] AND fc.rpt_code LIKE 'BCKQKD%'
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_row') }} frt
        -- [BACKFILL-UAT-ORIG] ON  frt.row_code = v.row_code
        -- [BACKFILL-UAT-ORIG] AND frt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND frt.src_stm_code = 'IDS_RROW'
        -- [BACKFILL-UAT-ORIG] AND frt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND (
            -- [BACKFILL-UAT-ORIG] (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            -- [BACKFILL-UAT-ORIG] OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        -- [BACKFILL-UAT-ORIG] )
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_column') }} fclt
        -- [BACKFILL-UAT-ORIG] ON  fclt.column_code = v.column_code
        -- [BACKFILL-UAT-ORIG] AND fclt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fclt.src_stm_code = 'IDS_RCOL'
        -- [BACKFILL-UAT-ORIG] AND fclt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fclt.column_description_reference = '1'
    -- [BACKFILL-UAT-ORIG] WHERE v.rn = 1
    -- [BACKFILL-UAT-ORIG] GROUP BY v.pc_id
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] LNST theo ky anchor (pc, nam, quy, fr_code); gan vao ngay o pc_financials.   -- [BACKFILL-UAT-NEW]
npat_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        v.pc_id,   -- [BACKFILL-UAT-NEW]
        v.rpt_year,   -- [BACKFILL-UAT-NEW]
        v.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        v.fr_code,   -- [BACKFILL-UAT-NEW]
        SUM(v.data_val) AS net_profit_after_tax   -- [BACKFILL-UAT-NEW]
    FROM gsdc_fr_value v   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_catalog') }} fc   -- [BACKFILL-UAT-NEW]
        ON  fc.fr_catalog_id = v.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fc.fr_year = CAST(v.rpt_year AS string)   -- [BACKFILL-UAT-NEW]
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'   -- [BACKFILL-UAT-NEW]
        AND fc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)   -- [BACKFILL-UAT-NEW]
        AND fc.rpt_code LIKE 'BCKQKD%'   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_row') }} frt   -- [BACKFILL-UAT-NEW]
        ON  frt.row_code = v.row_code   -- [BACKFILL-UAT-NEW]
        AND frt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND frt.src_stm_code = 'IDS_RROW'   -- [BACKFILL-UAT-NEW]
        AND frt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND (   -- [BACKFILL-UAT-NEW]
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')   -- [BACKFILL-UAT-NEW]
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')   -- [BACKFILL-UAT-NEW]
        )   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_column') }} fclt   -- [BACKFILL-UAT-NEW]
        ON  fclt.column_code = v.column_code   -- [BACKFILL-UAT-NEW]
        AND fclt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fclt.src_stm_code = 'IDS_RCOL'   -- [BACKFILL-UAT-NEW]
        AND fclt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fclt.column_description_reference = '1'   -- [BACKFILL-UAT-NEW]
    WHERE v.rn = 1   -- [BACKFILL-UAT-NEW]
    GROUP BY v.pc_id, v.rpt_year, v.rpt_quarter, v.fr_code   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] owner_equity_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] r4.pc_id,
        -- [BACKFILL-UAT-ORIG] COALESCE(oebp.owner_equity, 0) AS owner_equity
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4 r4
    -- [BACKFILL-UAT-ORIG] LEFT JOIN owner_equity_by_period oebp
        -- [BACKFILL-UAT-ORIG] ON  oebp.pc_id = r4.pc_id
        -- [BACKFILL-UAT-ORIG] AND oebp.rpt_year = r4.rpt_year
        -- [BACKFILL-UAT-ORIG] AND oebp.rpt_quarter = r4.rpt_quarter
    -- [BACKFILL-UAT-ORIG] WHERE r4.rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Theo (cong ty, trading_dt): ky nop gan nhat tai ngay do.   -- [BACKFILL-UAT-NEW]
owner_equity_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        r4.pc_id,   -- [BACKFILL-UAT-NEW]
        r4.trading_dt,   -- [BACKFILL-UAT-NEW]
        COALESCE(oebp.owner_equity, 0) AS owner_equity   -- [BACKFILL-UAT-NEW]
    FROM pc_rpt_sub_recent4 r4   -- [BACKFILL-UAT-NEW]
    LEFT JOIN owner_equity_by_period oebp   -- [BACKFILL-UAT-NEW]
        ON  oebp.pc_id = r4.pc_id   -- [BACKFILL-UAT-NEW]
        AND oebp.rpt_year = r4.rpt_year   -- [BACKFILL-UAT-NEW]
        AND oebp.rpt_quarter = r4.rpt_quarter   -- [BACKFILL-UAT-NEW]
    WHERE r4.rn = 1   -- [BACKFILL-UAT-NEW]
),

-- Financial Report Period End Date: ky ket thuc cua ky nop bao cao gan nhat (khong con
-- doc rieng tu npat_by_period - dung chung anchor voi npat_val/owner_equity_val).
-- [BACKFILL-UAT-ORIG] fr_period_end_dt AS (
    -- [BACKFILL-UAT-ORIG] SELECT pc_id, period_end_dt AS fr_period_end_dt
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
fr_period_end_dt AS (   -- [BACKFILL-UAT-NEW]
    SELECT pc_id, trading_dt, period_end_dt AS fr_period_end_dt   -- [BACKFILL-UAT-NEW]
    FROM pc_rpt_sub_recent4   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
),

-- Net Profit After Tax TTM: SUM toi da 4 KY NOP BAO CAO GAN NHAT (khong phai 4 ky co
-- LNST), ky nao thieu LNST tinh la 0 (COALESCE), khong con dieu kien COUNT(*)=4.
-- [SUA 2026-09-23, BA lam ro them] Neu cong ty KHONG CO DU 4 KY NOP BAO CAO (khong phai
-- thieu LNST, ma thieu ca ky nop) thi TTM phai la NULL - CASE COUNT(*)=4 dem so dong r4
-- (so ky nop thuc te, toi da 4 do da loc rn<=4), KHONG PHAI dem so dong LNST non-null
-- (LNST thieu trong 1 ky van tinh 0 va van tinh binh thuong neu du 4 ky nop).
-- [BACKFILL-UAT-ORIG] npat_ttm_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] r4.pc_id,
        -- [BACKFILL-UAT-ORIG] CASE WHEN COUNT(*) = 4 THEN SUM(COALESCE(nbp.net_profit_after_tax, 0)) END AS net_profit_after_tax_ttm
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4 r4
    -- [BACKFILL-UAT-ORIG] LEFT JOIN npat_by_period nbp
        -- [BACKFILL-UAT-ORIG] ON  nbp.pc_id = r4.pc_id
        -- [BACKFILL-UAT-ORIG] AND nbp.rpt_year = r4.rpt_year
        -- [BACKFILL-UAT-ORIG] AND nbp.rpt_quarter = r4.rpt_quarter
    -- [BACKFILL-UAT-ORIG] WHERE r4.rn <= 4
    -- [BACKFILL-UAT-ORIG] GROUP BY r4.pc_id
-- [BACKFILL-UAT-ORIG] ),
npat_ttm_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        r4.pc_id,   -- [BACKFILL-UAT-NEW]
        r4.trading_dt,   -- [BACKFILL-UAT-NEW]
        CASE WHEN COUNT(*) = CASE WHEN MAX(r4.q_latest) = 5 THEN 1 ELSE 4 END THEN SUM(COALESCE(nbp.net_profit_after_tax, 0)) END AS net_profit_after_tax_ttm   -- [SUA 2026-11-02, LLD v4.58 muc b] nam: 1 ky, quy: 4 quy
    FROM pc_rpt_ttm_sel r4   -- [SUA 2026-11-02]
    LEFT JOIN npat_by_period nbp   -- [BACKFILL-UAT-NEW]
        ON  nbp.pc_id = r4.pc_id   -- [BACKFILL-UAT-NEW]
        AND nbp.rpt_year = r4.rpt_year   -- [BACKFILL-UAT-NEW]
        AND nbp.rpt_quarter = r4.rpt_quarter   -- [BACKFILL-UAT-NEW]
    GROUP BY r4.pc_id, r4.trading_dt   -- [BACKFILL-UAT-NEW]
),

-- ============================================================================
-- [MOI 2026-09-29, LLD "38edf44" - redesign Nhom 34] 5 measure vat ly moi:
-- weighted_average_outstanding_share_quantity(_ttm), owner_equity_weighted_
-- average_outstanding_share_quantity(_ttm), owner_equity_average_4_quarter.
-- Thay AVG(outstanding_share_quantity) theo quy LICH (sai, da deprecate - xem
-- check-loi-so-lieu case ACB da xac minh: KLLH binh quan phai tinh theo dung
-- khung ngay ky BCTC gan nhat, khong phai quy duong lich).
-- CHU Y - GIA DINH CAN XAC NHAN LAI VOI DATA MODELER: LLD mo ta cot "Owner
-- Equity Weighted..." dung 1 chuoi xep hang RIENG cho VCSH (khong gioi han
-- rpt_quarter, chap nhan ky ban nien/ca nam) - DOC LAP voi ky LNST. Code hien
-- tai (owner_equity_val/owner_equity_by_period) dang TAI SU DUNG CHUNG
-- pc_rpt_sub_recent4 voi LNST (gioi han rpt_quarter IN (1,2,3,4), KHONG doc
-- lap). De nhat quan voi phan owner_equity da co san (khong tao thay doi kien
-- truc lon chua duoc xac nhan), 4 cot WAOS o day TAM THOI dung chung 1 khung
-- ngay (waos_frame_quy/waos_frame_ttm, tu pc_rpt_sub_recent4) cho ca nhanh
-- LNST va nhanh VCSH - nghia la owner_equity_weighted_average_outstanding_
-- share_quantity(_ttm) se BANG CHINH XAC weighted_average_outstanding_share_
-- quantity(_ttm) trong code nay. Neu Data Modeler xac nhan can 1 chuoi xep
-- hang VCSH DOC LAP that (cho phep ky ban nien/ca nam), can tach rieng thanh
-- 1 CTE moi (khac owner_equity_by_period hien tai) truoc khi build lai.
-- ============================================================================
-- [BACKFILL-UAT-ORIG] waos_frame_quy AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] pc_id,
        -- [BACKFILL-UAT-ORIG] CASE rpt_quarter
            -- [BACKFILL-UAT-ORIG] WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))
        -- [BACKFILL-UAT-ORIG] END AS khung_dau,
        -- [BACKFILL-UAT-ORIG] period_end_dt AS khung_cuoi
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Khung ngay theo (cong ty, trading_dt). WAOS tinh 1 lan cho moi khung phan biet   -- [BACKFILL-UAT-NEW]
-- (waos_quy_val/waos_ttm_val) roi gan lai theo ngay o pc_financials.   -- [BACKFILL-UAT-NEW]
waos_frame_quy AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        pc_id,   -- [BACKFILL-UAT-NEW]
        trading_dt,   -- [BACKFILL-UAT-NEW]
        CASE rpt_quarter   -- [BACKFILL-UAT-NEW]
            WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))   -- [BACKFILL-UAT-NEW]
        END AS khung_dau,   -- [BACKFILL-UAT-NEW]
        period_end_dt AS khung_cuoi   -- [BACKFILL-UAT-NEW]
    FROM pc_rpt_sub_recent4   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] waos_frame_ttm AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] pc_id,
        -- [BACKFILL-UAT-ORIG] MIN(CASE rpt_quarter
            -- [BACKFILL-UAT-ORIG] WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))
            -- [BACKFILL-UAT-ORIG] WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))
        -- [BACKFILL-UAT-ORIG] END) AS khung_dau,
        -- [BACKFILL-UAT-ORIG] MAX(period_end_dt) AS khung_cuoi
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4
    -- [BACKFILL-UAT-ORIG] WHERE rn <= 4
    -- [BACKFILL-UAT-ORIG] GROUP BY pc_id
    -- [BACKFILL-UAT-ORIG] HAVING COUNT(*) = 4
-- [BACKFILL-UAT-ORIG] ),
waos_frame_ttm AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        pc_id,   -- [BACKFILL-UAT-NEW]
        trading_dt,   -- [BACKFILL-UAT-NEW]
        MIN(CASE rpt_quarter   -- [BACKFILL-UAT-NEW]
            WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))   -- [BACKFILL-UAT-NEW]
            WHEN 5 THEN to_date(concat(rpt_year, '-01-01'))   -- [SUA 2026-11-02] ky nam: tu dau nam
        END) AS khung_dau,   -- [BACKFILL-UAT-NEW]
        MAX(period_end_dt) AS khung_cuoi   -- [BACKFILL-UAT-NEW]
    FROM pc_rpt_ttm_sel   -- [SUA 2026-11-02, LLD v4.58 muc b] cung ky voi LNST TTM
    GROUP BY pc_id, trading_dt   -- [BACKFILL-UAT-NEW]
    HAVING COUNT(*) = CASE WHEN MAX(q_latest) = 5 THEN 1 ELSE 4 END   -- [SUA 2026-11-02]
),

-- VCSH binh quan CONG (AVG, khong phai SUM) cua 4 ky - dao nguoc quyet dinh cu
-- (2026-09-04) da xac nhan sai qua SQL tham khao BA. Tai su dung owner_equity_by_period
-- + pc_rpt_sub_recent4 da co san.
-- [BACKFILL-UAT-ORIG] owner_equity_avg4_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] r4.pc_id,
        -- [BACKFILL-UAT-ORIG] CASE WHEN COUNT(*) = 4 THEN AVG(oebp.owner_equity) END AS owner_equity_average_4_quarter
    -- [BACKFILL-UAT-ORIG] FROM pc_rpt_sub_recent4 r4
    -- [BACKFILL-UAT-ORIG] INNER JOIN owner_equity_by_period oebp
        -- [BACKFILL-UAT-ORIG] ON  oebp.pc_id = r4.pc_id
        -- [BACKFILL-UAT-ORIG] AND oebp.rpt_year = r4.rpt_year
        -- [BACKFILL-UAT-ORIG] AND oebp.rpt_quarter = r4.rpt_quarter
    -- [BACKFILL-UAT-ORIG] WHERE r4.rn <= 4
    -- [BACKFILL-UAT-ORIG] GROUP BY r4.pc_id
-- [BACKFILL-UAT-ORIG] ),
owner_equity_avg4_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        r4.pc_id,   -- [BACKFILL-UAT-NEW]
        r4.trading_dt,   -- [BACKFILL-UAT-NEW]
        CASE WHEN COUNT(*) = 4 THEN AVG(oebp.owner_equity) END AS owner_equity_average_4_quarter   -- [BACKFILL-UAT-NEW]
    FROM pc_rpt_sub_recent4 r4   -- [BACKFILL-UAT-NEW]
    INNER JOIN owner_equity_by_period oebp   -- [BACKFILL-UAT-NEW]
        ON  oebp.pc_id = r4.pc_id   -- [BACKFILL-UAT-NEW]
        AND oebp.rpt_year = r4.rpt_year   -- [BACKFILL-UAT-NEW]
        AND oebp.rpt_quarter = r4.rpt_quarter   -- [BACKFILL-UAT-NEW]
    WHERE r4.rn <= 4   -- [BACKFILL-UAT-NEW]
    GROUP BY r4.pc_id, r4.trading_dt   -- [BACKFILL-UAT-NEW]
),

-- Nguon VSDC listed_share_information cho WAOS - cung pattern LEAD/DATEDIFF nhu cau test BA
-- (WAOS_base/KLLH_binh_quan_all), khac oss_val_all (chi lay 1 ban ghi moi nhat, dung cho
-- outstanding_share_quantity hien tai) - o day can TOAN BO lich su trong khung ngay.
waos_lsis_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.ds_snpst_dt,
        lsis.outstanding_share_quantity,
        LEAD(lsis.ds_snpst_dt) OVER (PARTITION BY lsis.ticker_symbol ORDER BY lsis.ds_snpst_dt) AS next_ds_snpst_dt
    FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

-- [BACKFILL-UAT-ORIG] waos_quy_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] pcf.equity_ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] SUM(w.outstanding_share_quantity * DATEDIFF(
            -- [BACKFILL-UAT-ORIG] LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            -- [BACKFILL-UAT-ORIG] GREATEST(w.ds_snpst_dt, f.khung_dau)
        -- [BACKFILL-UAT-ORIG] )) / NULLIF(SUM(DATEDIFF(
            -- [BACKFILL-UAT-ORIG] LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            -- [BACKFILL-UAT-ORIG] GREATEST(w.ds_snpst_dt, f.khung_dau)
        -- [BACKFILL-UAT-ORIG] )), 0) AS weighted_average_outstanding_share_quantity
    -- [BACKFILL-UAT-ORIG] FROM waos_frame_quy f
    -- [BACKFILL-UAT-ORIG] INNER JOIN pc_fin pcf
        -- [BACKFILL-UAT-ORIG] ON  pcf.pc_id = f.pc_id
    -- [BACKFILL-UAT-ORIG] INNER JOIN waos_lsis_all w
        -- [BACKFILL-UAT-ORIG] ON  w.symbol = pcf.equity_ticker_symbol
        -- [BACKFILL-UAT-ORIG] AND w.ds_snpst_dt <= f.khung_cuoi
        -- [BACKFILL-UAT-ORIG] AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau
    -- [BACKFILL-UAT-ORIG] GROUP BY pcf.equity_ticker_symbol
-- [BACKFILL-UAT-ORIG] ),
waos_quy_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        pcf.equity_ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        f.khung_dau,   -- [BACKFILL-UAT-NEW]
        f.khung_cuoi,   -- [BACKFILL-UAT-NEW]
        SUM(w.outstanding_share_quantity * DATEDIFF(   -- [BACKFILL-UAT-NEW]
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),   -- [BACKFILL-UAT-NEW]
            GREATEST(w.ds_snpst_dt, f.khung_dau)   -- [BACKFILL-UAT-NEW]
        )) / NULLIF(SUM(DATEDIFF(   -- [BACKFILL-UAT-NEW]
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),   -- [BACKFILL-UAT-NEW]
            GREATEST(w.ds_snpst_dt, f.khung_dau)   -- [BACKFILL-UAT-NEW]
        )), 0) AS weighted_average_outstanding_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM (SELECT DISTINCT pc_id, khung_dau, khung_cuoi FROM waos_frame_quy) f   -- [BACKFILL-UAT-NEW]
    INNER JOIN pc_fin pcf   -- [BACKFILL-UAT-NEW]
        ON  pcf.pc_id = f.pc_id   -- [BACKFILL-UAT-NEW]
    INNER JOIN waos_lsis_all w   -- [BACKFILL-UAT-NEW]
        ON  w.symbol = pcf.equity_ticker_symbol   -- [BACKFILL-UAT-NEW]
        AND w.ds_snpst_dt <= f.khung_cuoi   -- [BACKFILL-UAT-NEW]
        AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau   -- [BACKFILL-UAT-NEW]
    GROUP BY pcf.equity_ticker_symbol, f.khung_dau, f.khung_cuoi   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-ORIG] waos_ttm_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] pcf.equity_ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] SUM(w.outstanding_share_quantity * DATEDIFF(
            -- [BACKFILL-UAT-ORIG] LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            -- [BACKFILL-UAT-ORIG] GREATEST(w.ds_snpst_dt, f.khung_dau)
        -- [BACKFILL-UAT-ORIG] )) / NULLIF(SUM(DATEDIFF(
            -- [BACKFILL-UAT-ORIG] LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            -- [BACKFILL-UAT-ORIG] GREATEST(w.ds_snpst_dt, f.khung_dau)
        -- [BACKFILL-UAT-ORIG] )), 0) AS weighted_average_outstanding_share_quantity_ttm
    -- [BACKFILL-UAT-ORIG] FROM waos_frame_ttm f
    -- [BACKFILL-UAT-ORIG] INNER JOIN pc_fin pcf
        -- [BACKFILL-UAT-ORIG] ON  pcf.pc_id = f.pc_id
    -- [BACKFILL-UAT-ORIG] INNER JOIN waos_lsis_all w
        -- [BACKFILL-UAT-ORIG] ON  w.symbol = pcf.equity_ticker_symbol
        -- [BACKFILL-UAT-ORIG] AND w.ds_snpst_dt <= f.khung_cuoi
        -- [BACKFILL-UAT-ORIG] AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau
    -- [BACKFILL-UAT-ORIG] GROUP BY pcf.equity_ticker_symbol
-- [BACKFILL-UAT-ORIG] ),
waos_ttm_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        pcf.equity_ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        f.khung_dau,   -- [BACKFILL-UAT-NEW]
        f.khung_cuoi,   -- [BACKFILL-UAT-NEW]
        SUM(w.outstanding_share_quantity * DATEDIFF(   -- [BACKFILL-UAT-NEW]
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),   -- [BACKFILL-UAT-NEW]
            GREATEST(w.ds_snpst_dt, f.khung_dau)   -- [BACKFILL-UAT-NEW]
        )) / NULLIF(SUM(DATEDIFF(   -- [BACKFILL-UAT-NEW]
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),   -- [BACKFILL-UAT-NEW]
            GREATEST(w.ds_snpst_dt, f.khung_dau)   -- [BACKFILL-UAT-NEW]
        )), 0) AS weighted_average_outstanding_share_quantity_ttm   -- [BACKFILL-UAT-NEW]
    FROM (SELECT DISTINCT pc_id, khung_dau, khung_cuoi FROM waos_frame_ttm) f   -- [BACKFILL-UAT-NEW]
    INNER JOIN pc_fin pcf   -- [BACKFILL-UAT-NEW]
        ON  pcf.pc_id = f.pc_id   -- [BACKFILL-UAT-NEW]
    INNER JOIN waos_lsis_all w   -- [BACKFILL-UAT-NEW]
        ON  w.symbol = pcf.equity_ticker_symbol   -- [BACKFILL-UAT-NEW]
        AND w.ds_snpst_dt <= f.khung_cuoi   -- [BACKFILL-UAT-NEW]
        AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau   -- [BACKFILL-UAT-NEW]
    GROUP BY pcf.equity_ticker_symbol, f.khung_dau, f.khung_cuoi   -- [BACKFILL-UAT-NEW]
),

-- Tong hop cac chi tieu tai chinh theo symbol
-- [SUA 2026-09-17 - FIX NHAN DONG] Truoc day CTE nay lay FROM se_tr_sn va xuat
-- company_join_symbol AS symbol: company_join_symbol KHONG duy nhat (moi chung quyen
-- tren SHB deu co company_join_symbol='SHB') -> CTE co 14 dong symbol='SHB' -> JOIN o
-- SELECT cuoi nhan 14 lan. Tra ve grain 1 dong / 1 cong ty (FROM pc_fin, da dedupe theo
-- equity_ticker_symbol). outstanding_share_quantity tach ra join thang o SELECT cuoi theo
-- se_tr_sn.symbol (giong free_float_share_quantity) de ma khong co ho so IDS (vd VIX) van
-- lay duoc KLLH tu VSDC.
-- [BACKFILL-UAT-ORIG] pc_financials AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] pcf.equity_ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] rev.revenue,
        -- [BACKFILL-UAT-ORIG] npat.net_profit_after_tax,
        -- [BACKFILL-UAT-ORIG] npat_ttm.net_profit_after_tax_ttm,
        -- [BACKFILL-UAT-ORIG] oe.owner_equity,
        -- [BACKFILL-UAT-ORIG] fped.fr_period_end_dt,
        -- [BACKFILL-UAT-ORIG] wq.weighted_average_outstanding_share_quantity,
        -- [BACKFILL-UAT-ORIG] wt.weighted_average_outstanding_share_quantity_ttm,
        -- [BACKFILL-UAT-ORIG] -- [xem canh bao dau khoi WAOS] tam thoi dung chung frame voi nhanh LNST
        -- [BACKFILL-UAT-ORIG] wq.weighted_average_outstanding_share_quantity AS owner_equity_weighted_average_outstanding_share_quantity,
        -- [BACKFILL-UAT-ORIG] wt.weighted_average_outstanding_share_quantity_ttm AS owner_equity_weighted_average_outstanding_share_quantity_ttm,
        -- [BACKFILL-UAT-ORIG] oe4.owner_equity_average_4_quarter
    -- [BACKFILL-UAT-ORIG] FROM pc_fin pcf
    -- [BACKFILL-UAT-ORIG] LEFT JOIN revenue_val rev
        -- [BACKFILL-UAT-ORIG] ON  rev.pc_id = pcf.pc_id
    -- [BACKFILL-UAT-ORIG] LEFT JOIN npat_val npat
        -- [BACKFILL-UAT-ORIG] ON  npat.pc_id = pcf.pc_id
    -- [BACKFILL-UAT-ORIG] LEFT JOIN npat_ttm_val npat_ttm
        -- [BACKFILL-UAT-ORIG] ON  npat_ttm.pc_id = pcf.pc_id
    -- [BACKFILL-UAT-ORIG] LEFT JOIN owner_equity_val oe
        -- [BACKFILL-UAT-ORIG] ON  oe.pc_id = pcf.pc_id
    -- [BACKFILL-UAT-ORIG] LEFT JOIN fr_period_end_dt fped
        -- [BACKFILL-UAT-ORIG] ON  fped.pc_id = pcf.pc_id
    -- [BACKFILL-UAT-ORIG] LEFT JOIN waos_quy_val wq
        -- [BACKFILL-UAT-ORIG] ON  wq.symbol = pcf.equity_ticker_symbol
    -- [BACKFILL-UAT-ORIG] LEFT JOIN waos_ttm_val wt
        -- [BACKFILL-UAT-ORIG] ON  wt.symbol = pcf.equity_ticker_symbol
    -- [BACKFILL-UAT-ORIG] LEFT JOIN owner_equity_avg4_val oe4
        -- [BACKFILL-UAT-ORIG] ON  oe4.pc_id = pcf.pc_id
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Grain: 1 dong / (cong ty, trading_dt). Moi chi tieu lay dung gia tri cua tung ngay.   -- [BACKFILL-UAT-NEW]
pc_financials AS (   -- [BACKFILL-UAT-NEW]
    SELECT /*+ BROADCAST(td) */   -- [BACKFILL-UAT-NEW]
        pcf.equity_ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        td.trading_dt,   -- [BACKFILL-UAT-NEW]
        rev.revenue,   -- [BACKFILL-UAT-NEW]
        npat.net_profit_after_tax,   -- [BACKFILL-UAT-NEW]
        npat_ttm.net_profit_after_tax_ttm,   -- [BACKFILL-UAT-NEW]
        oe.owner_equity,   -- [BACKFILL-UAT-NEW]
        fped.fr_period_end_dt,   -- [BACKFILL-UAT-NEW]
        wq.weighted_average_outstanding_share_quantity,   -- [BACKFILL-UAT-NEW]
        wt.weighted_average_outstanding_share_quantity_ttm,   -- [BACKFILL-UAT-NEW]
        wq.weighted_average_outstanding_share_quantity AS owner_equity_weighted_average_outstanding_share_quantity,   -- [BACKFILL-UAT-NEW]
        wt.weighted_average_outstanding_share_quantity_ttm AS owner_equity_weighted_average_outstanding_share_quantity_ttm,   -- [BACKFILL-UAT-NEW]
        oe4.owner_equity_average_4_quarter   -- [BACKFILL-UAT-NEW]
    FROM pc_fin pcf   -- [BACKFILL-UAT-NEW]
    CROSS JOIN trade_dates td   -- [BACKFILL-UAT-NEW]
    LEFT JOIN gsdc_sub_anchor_d ga   -- [BACKFILL-UAT-NEW]
        ON  ga.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND ga.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN revenue_val rev   -- [BACKFILL-UAT-NEW]
        ON  rev.pc_id = ga.pc_id   -- [BACKFILL-UAT-NEW]
        AND rev.rpt_year = ga.rpt_year   -- [BACKFILL-UAT-NEW]
        AND rev.rpt_quarter = ga.rpt_quarter   -- [BACKFILL-UAT-NEW]
        AND rev.fr_code = ga.fr_code   -- [BACKFILL-UAT-NEW]
    LEFT JOIN npat_val npat   -- [BACKFILL-UAT-NEW]
        ON  npat.pc_id = ga.pc_id   -- [BACKFILL-UAT-NEW]
        AND npat.rpt_year = ga.rpt_year   -- [BACKFILL-UAT-NEW]
        AND npat.rpt_quarter = ga.rpt_quarter   -- [BACKFILL-UAT-NEW]
        AND npat.fr_code = ga.fr_code   -- [BACKFILL-UAT-NEW]
    LEFT JOIN npat_ttm_val npat_ttm   -- [BACKFILL-UAT-NEW]
        ON  npat_ttm.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND npat_ttm.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN owner_equity_val oe   -- [BACKFILL-UAT-NEW]
        ON  oe.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND oe.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN fr_period_end_dt fped   -- [BACKFILL-UAT-NEW]
        ON  fped.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND fped.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN waos_frame_quy fq   -- [BACKFILL-UAT-NEW]
        ON  fq.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND fq.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN waos_quy_val wq   -- [BACKFILL-UAT-NEW]
        ON  wq.symbol = pcf.equity_ticker_symbol   -- [BACKFILL-UAT-NEW]
        AND wq.khung_dau = fq.khung_dau   -- [BACKFILL-UAT-NEW]
        AND wq.khung_cuoi = fq.khung_cuoi   -- [BACKFILL-UAT-NEW]
    LEFT JOIN waos_frame_ttm ft   -- [BACKFILL-UAT-NEW]
        ON  ft.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND ft.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
    LEFT JOIN waos_ttm_val wt   -- [BACKFILL-UAT-NEW]
        ON  wt.symbol = pcf.equity_ticker_symbol   -- [BACKFILL-UAT-NEW]
        AND wt.khung_dau = ft.khung_dau   -- [BACKFILL-UAT-NEW]
        AND wt.khung_cuoi = ft.khung_cuoi   -- [BACKFILL-UAT-NEW]
    LEFT JOIN owner_equity_avg4_val oe4   -- [BACKFILL-UAT-NEW]
        ON  oe4.pc_id = pcf.pc_id   -- [BACKFILL-UAT-NEW]
        AND oe4.trading_dt = td.trading_dt   -- [BACKFILL-UAT-NEW]
)

SELECT * FROM pc_financials
