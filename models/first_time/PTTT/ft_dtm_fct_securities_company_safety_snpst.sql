-- [FIRST-TIME] ft_dtm_fct_securities_company_safety_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_securities_company_safety_snpst (config ft_target='fct_securities_company_safety_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_safety_snpst
* Program name: Fact Securities Company Safety Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_securities_company_safety_snpst:
*									- Daily ghi TOAN BO lich su ky bao cao vao lat ds_snpst_dt = etl_date; ban ft sinh DUNG 1 LAT duy nhat, ds_snpst_dt = etl_date cua lan chay
*									  (chay voi dates = [ngay dau khoang lich su can xem]); noi dung lat = toan bo lich su ky bao cao (daily cung khong cat theo etl_date o cac CTE nay).
*									- append: ds_snpst_dt = etl_date dat CUOI SELECT (khong cat theo etl_date trong noi dung).
*									- HAN CHE: dim doc bang MAIN ds_rcrd_st='ACTIVE' (khong _hstr theo ngay) (securities_company_dim)
*									  khai thac lay max(ds_snpst_dt) <= ngay chon nen cac ngay chon TRUOC etl_date cua lat nay se khong co du lieu.
* 2026-11-02		tuan.nguyenvanb		[DOI LOGIC KY THEO BA] Dong bo daily: moi ngay D (2025-05-01 -> etl_date, CTE days) la 1 snapshot ds_snpst_dt = D chua cac dong cua thang bao cao cua D; VCSH/no phai tra theo QUY co dinh (phuong an B) tu thang bao cao, thieu bao cao -> NULL, khong lui ky. Thay cho ban cu (1 lat ds_snpst_dt = etl_date chua toan bo lich su). Chay voi dates = [etl_date go-live].
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi nhieu lat, ds_snpst_dt = ngay D tung dong (thay strategy snapshot cua yml)

WITH days AS (

    -- [BACKFILL-UAT-NEW] moi ngay D trong khoang 2025-05-01 -> etl_date la 1 snapshot (ds_snpst_dt = D). Thang bao cao cua D:
    -- D la ngay CUOI THANG -> chinh thang do; ngay khac -> thang LIEN TRUOC (giong daily). Sua moc 2025-05-01 neu can lui xa hon.
    SELECT
        d
        , year(m_end) AS m_year
        , month(m_end) AS m_period
    FROM (
        SELECT
            d
            , CASE WHEN d = last_day(d) THEN d ELSE last_day(add_months(d, -1)) END AS m_end
        FROM (
            SELECT explode(sequence(to_date('2025-05-01','yyyy-MM-dd'), to_date('{{ var("etl_date") }}','yyyy-MM-dd'), interval 1 day)) AS d
        ) s
    ) x

),

grain AS (

    SELECT
        sc_code
        , sc_id
        , rpt_year
        , period
        , MAX(end_dt) AS snpst_end_dt
        , date_sub(trunc(last_day(make_date(CAST(rpt_year AS int), CAST(period AS int), 1)), 'QUARTER'), 1) AS vcsh_q_end_dt   -- [2026-11-02 THEO BA, phuong an B] cuoi quy lien truoc quy chua thang bao cao: T1-T3 -> 31/12 nam truoc, T4-T6 -> 31/3, T7-T9 -> 30/6, T10-T12 -> 30/9
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND rpt_period = 'THANG'
        AND rpt_submission_status_code IN ('1','2')
    GROUP BY sc_code, sc_id, rpt_year, period

),

-- Submission moi nhat cua tung bao cao dinh ky: MAX(id tho) theo (ref_tp_code, ref_id)
-- dung LLD (sc_rpt_input_submission_code = CAST(id nguon AS string); sc_rpt_input_submission_id
-- la hash nen KHONG dung de so sanh MAX)
-- [2026-10-23 theo GSTT] atm_sc_report_input_submission.sc_rpt_code la id so cua form (CAST form_report_id),
-- KHONG phai ma nghiep vu -> join atm_sc_report (sc_rpt_code = id form) de lay rpt_code (BCTHHD_CTCK/BCTLAT/BCTCHN/BCTCRL)
rpt_sub_latest AS (

    SELECT
        ranked.sc_rpt_input_submission_id
        , ranked.sc_rpt_code AS form_code
        , sc_rpt.rpt_code
        , ranked.ref_id
    FROM (
        SELECT
            sub.sc_rpt_input_submission_id
            , sub.sc_rpt_code
            , sub.ref_id
            , CAST(sub.sc_rpt_input_submission_code AS bigint) AS sub_raw_id
            , MAX(CAST(sub.sc_rpt_input_submission_code AS bigint)) OVER (
                PARTITION BY sub.ref_tp_code, sub.ref_id
            ) AS max_raw_id
        FROM (
            -- [2026-10-26] bang submission append: nop lai = them 1 ban ghi CUNG id (data_dt = last_modified_at) -> chi lay ban ghi moi nhat (data_dt lon nhat) moi submission
            SELECT * FROM (
                SELECT s_v.*, ROW_NUMBER() OVER (PARTITION BY s_v.sc_rpt_input_submission_id ORDER BY s_v.data_dt DESC, s_v.ds_etl_pcs_tms DESC) AS rn_ver
                FROM {{ ref('atm_sc_report_input_submission') }} s_v
            ) s_r WHERE s_r.rn_ver = 1
        ) sub
        WHERE sub.ref_tp_code = 'BAO_CAO_DINH_KY'   -- [2026-10-24] bang atomic sc_report_input_submission tren UAT KHONG con scd2 (khong co ds_rcrd_st) -> bo loc ACTIVE
    ) ranked
    INNER JOIN {{ ref('atm_sc_report') }} sc_rpt
        ON sc_rpt.sc_rpt_code = ranked.sc_rpt_code
        AND sc_rpt.ds_rcrd_st = 'ACTIVE'
        AND sc_rpt.rpt_code IN ('BCTHHD_CTCK','BCTLAT','BCTCHN','BCTCRL')
    WHERE ranked.sub_raw_id = ranked.max_raw_id

),

-- [2026-10-23 theo GSTT/Oracle nguon] sheet_id theo sheetCode: VCSH 06620 (TTTC hop nhat, TS359), 06608 (TTTC rieng, TS223/TS221);
-- margin II.8 (BCTHHD_CTCK, TS024 - TS024 con nam o sheet II.6 nen PHAI loc, neu khong cong thua ~5,8 lan); CAR 06H08 (BCTLAT, TS006 - TS006 co o 06H01/04/05/07/08/09).
-- DISTINCT vi deep_config co grain (config, sheet, cell) - khong DISTINCT se nhan dong khi JOIN theo sheet_id.
rpt_sheet AS (

    SELECT DISTINCT
        sc_rpt_code
        , sheet_code
        , sheet_id
    FROM {{ ref('atm_sc_report_deep_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND sheet_code IN ('06620','06608','II.8','06H08')

),

-- ===== A. margin_debt_amt (TS024, bao cao BCTHHD_CTCK, ky THANG) =====
margin_rpt_latest AS (

    SELECT
        spr.sc_code
        , spr.rpt_year
        , spr.period
        , rpt_sub.form_code
        , rpt_sub.sc_rpt_input_submission_id
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN rpt_sub_latest rpt_sub
        ON rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.rpt_code = 'BCTHHD_CTCK'
    WHERE spr.ds_rcrd_st = 'ACTIVE'
        AND spr.src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND spr.rpt_period = 'THANG'
        AND spr.rpt_submission_status_code IN ('1','2')

),

margin_debt_monthly AS (

    SELECT
        margin_rpt_latest.sc_code
        , margin_rpt_latest.rpt_year
        , margin_rpt_latest.period
        , SUM(CAST(rpt_val.cell_val AS decimal(23,2))) * 1000000 AS margin_debt_amt   -- [2026-10-24 BA xac nhan] TS024 tinh theo TRIEU DONG -> nhan 1.000.000 ra VND
    FROM margin_rpt_latest
    INNER JOIN {{ ref('atm_sc_report_input_value') }} rpt_val
        ON rpt_val.sc_rpt_input_submission_id = margin_rpt_latest.sc_rpt_input_submission_id
        AND rpt_val.cell_id = 'TS024'
    -- [2026-10-23] chi lay sheet II.8 (Tinh hinh giao dich ky quy chung khoan) nhu cau BA
    INNER JOIN rpt_sheet sh
        ON sh.sc_rpt_code = margin_rpt_latest.form_code
        AND sh.sheet_id = rpt_val.sheet_id
        AND sh.sheet_code = 'II.8'
    GROUP BY margin_rpt_latest.sc_code, margin_rpt_latest.rpt_year, margin_rpt_latest.period

),

-- ===== B. capital_adequacy_ratio (TS006, bao cao BCTLAT, ky THANG) =====
car_rpt_latest AS (

    SELECT
        spr.sc_code
        , spr.rpt_year
        , spr.period
        , rpt_sub.form_code
        , rpt_sub.sc_rpt_input_submission_id
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN rpt_sub_latest rpt_sub
        ON rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.rpt_code = 'BCTLAT'
    WHERE spr.ds_rcrd_st = 'ACTIVE'
        AND spr.src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND spr.rpt_period = 'THANG'
        AND spr.rpt_submission_status_code IN ('1','2')

),

car_monthly AS (

    SELECT
        car_rpt_latest.sc_code
        , car_rpt_latest.rpt_year
        , car_rpt_latest.period
        , MAX(CAST(rpt_val.cell_val AS decimal(8,2))) AS capital_adequacy_ratio
    FROM car_rpt_latest
    INNER JOIN {{ ref('atm_sc_report_input_value') }} rpt_val
        ON rpt_val.sc_rpt_input_submission_id = car_rpt_latest.sc_rpt_input_submission_id
        AND rpt_val.cell_id = 'TS006'
    -- [2026-10-23] chi lay sheet 06H08 (Ty le von kha dung, LLD) - TS006 con o 06H01/04/05/07/09 voi gia tri khac
    INNER JOIN rpt_sheet sh
        ON sh.sc_rpt_code = car_rpt_latest.form_code
        AND sh.sheet_id = rpt_val.sheet_id
        AND sh.sheet_code = '06H08'
    GROUP BY car_rpt_latest.sc_code, car_rpt_latest.rpt_year, car_rpt_latest.period

),

-- ===== C. owner_equity_amt (VCSH) - [2026-11-02 THEO BA, phuong an B] QUY co dinh theo lich tu thang bao cao (xem vcsh_asof), chi bao cao QUY;
-- BCTCHN TS359, BCTCRL (chi khi CTCK khong co
-- BCTCHN cung rpt_year/period/rpt_period) COALESCE(TS223,TS221) =====
vcsh_candidates AS (

    SELECT
        spr.sc_code
        , spr.rpt_year
        , spr.period
        , spr.rpt_period
        , spr.sent_tms
        , spr.end_dt
        , rpt_sub.rpt_code
        , rpt_sub.form_code
        , rpt_sub.sc_rpt_input_submission_id
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN rpt_sub_latest rpt_sub
        ON rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.rpt_code IN ('BCTCHN','BCTCRL')
    WHERE spr.ds_rcrd_st = 'ACTIVE'
        AND spr.src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        -- [2026-10-26 THEO BA, da kiem chung bang du lieu staging] chi bao cao QUY (truoc day NAM/BAN_NIEN/QUY uu tien NAM)
        AND spr.rpt_period = 'QUY'
        AND spr.end_dt IS NOT NULL
        AND spr.rpt_submission_status_code IN ('1','2')

),

-- [2026-11-02 THEO BA, phuong an B] Quy dung cho VCSH/no phai tra/D-E co dinh theo LICH tu thang bao cao cua grain (cot vcsh_q_end_dt):
-- T1-T3 -> Q4 nam truoc, T4-T6 -> Q1, T7-T9 -> Q2, T10-T12 -> Q3; ap CUNG 1 quy cho moi CTCK; CTCK khong co bao cao cua quy do -> NULL (KHONG lui quy cu hon).
-- Khong xet ngay nop bao cao (BA xac nhan).

vcsh_asof AS (

    SELECT
        grain.sc_code
        , grain.rpt_year
        , grain.period
        , vcsh_candidates.rpt_period
        , vcsh_candidates.sent_tms
        , vcsh_candidates.rpt_code
        , vcsh_candidates.form_code
        , vcsh_candidates.sc_rpt_input_submission_id
        , CAST(vcsh_candidates.end_dt AS date) AS vcsh_period_end_dt
        , MAX(CASE WHEN vcsh_candidates.rpt_code = 'BCTCHN' THEN 1 ELSE 0 END) OVER (
            PARTITION BY grain.sc_code, grain.rpt_year, grain.period
                , vcsh_candidates.rpt_year, vcsh_candidates.period, vcsh_candidates.rpt_period
        ) AS has_bctchn
    FROM grain
    INNER JOIN vcsh_candidates
        ON vcsh_candidates.sc_code = grain.sc_code
        AND CAST(vcsh_candidates.end_dt AS date) = grain.vcsh_q_end_dt

),

vcsh_matched AS (

    SELECT
        vcsh_asof.sc_code
        , vcsh_asof.rpt_year
        , vcsh_asof.period
        , vcsh_asof.rpt_code
        , vcsh_asof.form_code
        , vcsh_asof.sc_rpt_input_submission_id
        , vcsh_asof.vcsh_period_end_dt
        , ROW_NUMBER() OVER (
            PARTITION BY vcsh_asof.sc_code, vcsh_asof.rpt_year, vcsh_asof.period
            ORDER BY vcsh_asof.sent_tms DESC   -- [2026-10-26 THEO BA] chi QUY -> khong con uu tien NAM > BAN_NIEN > QUY; lay lan nop moi nhat cua cung quy
        ) AS rn1
    FROM vcsh_asof
    WHERE vcsh_asof.rpt_code = 'BCTCHN'
        OR vcsh_asof.has_bctchn = 0

),

vcsh_selected AS (

    SELECT sc_code, rpt_year, period, rpt_code, form_code, sc_rpt_input_submission_id, vcsh_period_end_dt
    FROM vcsh_matched
    WHERE rn1 = 1

),

owner_equity_monthly AS (

    SELECT
        vcsh_selected.sc_code
        , vcsh_selected.rpt_year
        , vcsh_selected.period
        , vcsh_selected.vcsh_period_end_dt
        , CASE
            WHEN vcsh_selected.rpt_code = 'BCTCHN'
                THEN MAX(CASE WHEN rpt_val.cell_id = 'TS359' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
            ELSE COALESCE(
                NULLIF(MAX(CASE WHEN rpt_val.cell_id = 'TS223' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END), 0)
                , MAX(CASE WHEN rpt_val.cell_id = 'TS221' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
            )
          END AS owner_equity_amt
        -- [2026-10-26 THEO BA - nguon SCMS] no phai tra cung bao cao/quy voi VCSH: BCTCHN TS275 (sheet 06620), BCTCRL TS137 (sheet 06608)
        , CASE
            WHEN vcsh_selected.rpt_code = 'BCTCHN'
                THEN MAX(CASE WHEN rpt_val.cell_id = 'TS275' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
            ELSE MAX(CASE WHEN rpt_val.cell_id = 'TS137' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
          END AS total_liabilities_amt
    FROM vcsh_selected
    INNER JOIN {{ ref('atm_sc_report_input_value') }} rpt_val
        ON rpt_val.sc_rpt_input_submission_id = vcsh_selected.sc_rpt_input_submission_id
        AND rpt_val.cell_id IN ('TS359','TS223','TS221','TS275','TS137')
    -- [2026-10-23 theo GSTT] loc SHEET_ID theo sheetCode nhu cau Oracle nguon
    INNER JOIN rpt_sheet sh
        ON sh.sc_rpt_code = vcsh_selected.form_code
        AND sh.sheet_id = rpt_val.sheet_id
        AND sh.sheet_code = CASE WHEN rpt_val.cell_id IN ('TS359','TS275') THEN '06620' ELSE '06608' END
    GROUP BY vcsh_selected.sc_code, vcsh_selected.rpt_year, vcsh_selected.period, vcsh_selected.vcsh_period_end_dt, vcsh_selected.rpt_code

),

sc_dim AS (

    SELECT securities_company_dim_id, sc_id
    FROM {{ ref('dtm_securities_company_dim') }}   -- [BACKFILL-UAT-NEW] bang MAIN (first-time khong co _hstr theo ngay)
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('dtm_securities_company_dim') }}_hstr WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'

)

SELECT
    CAST(date_format(grain.snpst_end_dt, 'yyyyMMdd') AS string)   AS snpst_dt_dim_id,
    CAST(sc_dim.securities_company_dim_id AS string)              AS securities_company_dim_id,
    CAST(grain.rpt_year AS int)                                   AS rpt_year,
    CAST(grain.period AS int)                                     AS period_nbr,
    CAST(margin_debt_monthly.margin_debt_amt AS decimal(23,2))    AS margin_debt_amt,
    CAST(owner_equity_monthly.owner_equity_amt AS decimal(23,2))  AS owner_equity_amt,
    CAST(grain.vcsh_q_end_dt AS date)                             AS owner_equity_period_end_dt,   -- [2026-11-02] ngay ket thuc cua QUY ap dung theo lich (luon co gia tri du CTCK chua nop bao cao quy do -> VCSH NULL) de man hinh hien nhan ky
    CAST(owner_equity_monthly.total_liabilities_amt AS decimal(23,2)) AS total_liabilities_amt,   -- [2026-10-26] no phai tra (SCMS TS275/TS137) cung quy voi VCSH (cot MOI, ADD COLUMN ... AFTER owner_equity_period_end_dt)
    CAST(
        margin_debt_monthly.margin_debt_amt / NULLIF(owner_equity_monthly.owner_equity_amt, 0) * 100
    AS decimal(8,2))                                              AS margin_to_equity_ratio,
    CAST(car_monthly.capital_adequacy_ratio AS decimal(8,2))      AS capital_adequacy_ratio,
    CAST('SCMS_SC_FIRM_PERIODIC_REPORT' AS string)                AS src_stm_code,
    CAST(days.d AS date)                                          AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] moi ngay D 1 snapshot (daily: ds_snpst_dt = etl_date)
FROM grain
INNER JOIN days   -- [BACKFILL-UAT-NEW] moi ngay D chi nhan cac dong cua thang bao cao cua D
    ON days.m_year = CAST(grain.rpt_year AS int)
    AND days.m_period = CAST(grain.period AS int)
LEFT JOIN sc_dim
    ON sc_dim.sc_id = CAST(grain.sc_id AS string)
LEFT JOIN margin_debt_monthly
    ON margin_debt_monthly.sc_code = grain.sc_code
    AND margin_debt_monthly.rpt_year = grain.rpt_year
    AND margin_debt_monthly.period = grain.period
LEFT JOIN owner_equity_monthly
    ON owner_equity_monthly.sc_code = grain.sc_code
    AND owner_equity_monthly.rpt_year = grain.rpt_year
    AND owner_equity_monthly.period = grain.period
LEFT JOIN car_monthly
    ON car_monthly.sc_code = grain.sc_code
    AND car_monthly.rpt_year = grain.rpt_year
    AND car_monthly.period = grain.period
