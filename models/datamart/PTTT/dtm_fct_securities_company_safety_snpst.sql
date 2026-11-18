/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_safety_snpst
* Program name: Fact Securities Company Safety Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[BAN CHINH THUC] Gap O_PTTT_13 (Nhom 25 - Danh sach giam sat
*									rui ro du no margin) DA DUOC DESIGN GIAI QUYET DUT DIEM qua
*									entity moi "Fact Securities Company Safety Snapshot"
*									(DTM_PTTT_fct_securities_company_safety_snpst.csv, commit
*									be718f93 tren origin/main) - entity nay THAY THE hoan toan
*									phuong an cu trong comment 2026-10-02 truoc do (dua tren
*									fct_securities_company_financial_structure_snpst/
*									report_indicator_dim reuse tu QLKD - 2 bang KHONG hien huu,
*									xem lai lich su commit). Build lai toan bo model theo dung
*									LLD moi: GRAIN DOI tu "1 dong/CTCK/ngay" (stub cu) sang
*									"1 dong/CTCK/THANG bao cao" - dung chain
*									atm_sc_periodic_report + atm_sc_report_input_submission +
*									atm_sc_report_input_value (ca 3 da duoc build tu 2026-09-24,
*									cung chain da proven trong dtm_fct_market_risk_snpst.sql
*									chain D/E - tai su dung y het pattern dedup resubmission
*									ROW_NUMBER theo sent_tms DESC va uu tien bao cao NAM(1) >
*									BAN_NIEN(2) > QUY(3) cho VCSH). DOI TEN COT HOAN TOAN:
*									scr_co_dim_id -> securities_company_dim_id, equity_amt ->
*									owner_equity_amt, margin_balance_amt -> margin_debt_amt, BO
*									safety_ranking_code (khong con trong LLD moi), THEM rpt_year/
*									period_nbr/capital_adequacy_ratio/src_stm_code. Vi doi GAN
*									NHU TOAN BO cot (khac ten + them/bot) va bang vat ly truoc gio
*									luon 0 dong (khong co du lieu that can bao toan), khuyen nghi
*									DROP + CREATE lai thay vi ALTER/RENAME tung cot - xem DDL dinh
*									kem trong bao cao. Materialized giu nguyen incremental_rebase/
*									snapshot/partition_by ds_snpst_dt (moi lan chay ghi lai TOAN
*									BO lich su cac thang da co, giong pattern
*									dtm_fct_securities_company_balance_snpst.sql - KHONG chi giu 1
*									thang/lan chay).
* 2026-10-05		tuan.nguyenvanb		Check ky lai model vs LLD, sua 3 diem: (1) JOIN dim qua sc_id
*									(atm_sc_periodic_report.sc_code la FK tho sc_firm_info_id, KHONG
*									phai ma CTCK nghiep vu nhu dtm_securities_company_dim.sc_code ->
*									join sc_code truoc day cho securities_company_dim_id = NULL);
*									(2) dedup submission theo MAX id tho cua (ref_tp_code, ref_id)
*									dung LLD (truoc day ROW_NUMBER theo spr.sent_tms - cac submission
*									cung 1 bao cao co sent_tms bang nhau -> chon ngau nhien); (3) VCSH:
*									loai BCTCRL khi CTCK co BCTCHN cung (rpt_year, period, rpt_period)
*									va dung last_day(end_dt) lam moc cuoi thang. KHONG doi cot output
*									-> khong can ALTER.
* 2026-10-15		tuan.nguyenvanb		Doi nguon atm_sc_periodic_report va atm_sc_report_input_submission
*									(deu scd4a) sang bang _hstr, loc ds_snpst_dt bang etl_date va ds_rcrd_st ACTIVE
*									giong cac model khac. atm_sc_report_input_value la upsert, khong co _hstr nen giu
*									doc bang chinh. Khong doi cot nen khong can ALTER.
*--------------------------------------------------------------------*
* Ghi chu:
* - securities_company_dim_id: reuse dtm_securities_company_dim (module QLKD,
*   scd4a, PK securities_company_dim_id, JOIN theo sc_id - xem 2026-10-05) qua ref() bang
*   _hstr, loc ds_snpst_dt bang etl_date va ds_rcrd_st ACTIVE.
* - atm_sc_periodic_report va atm_sc_report_input_submission deu materialized
*   scd4a, nen doc bang _hstr, loc ds_snpst_dt bang etl_date va ds_rcrd_st
*   ACTIVE giong cac model khac. atm_sc_report_input_value la upsert, khong
*   co bang _hstr nen doc bang chinh.
* - Grain CTE "grain": 1 dong / (sc_code, rpt_year, period) tu
*   atm_sc_periodic_report loc rpt_period='THANG', rpt_submission_status_code
*   IN ('1','2'); snpst_dt_dim_id = date_format(MAX(end_dt) cua nhom,
*   'yyyyMMdd') dung theo LLD (dong 2 CSV): "end_dt = MAX(end_dt) cua nhom"
*   - xu ly truong hop co nhieu ban ghi bao cao dinh ky thang cung
*   sc_code/rpt_year/period (vi du resubmit tao ban ghi moi thay vi update).
* - margin_debt_amt (cell TS024, bao cao BCTHHD_CTCK, ky THANG): join
*   atm_sc_periodic_report -> atm_sc_report_input_submission (ON
*   rpt_sub.ref_id = spr.sc_periodic_rpt_code AND ref_tp_code=
*   'BAO_CAO_DINH_KY' AND sc_rpt_code='BCTHHD_CTCK' - dung y het chain D cua
*   market_risk_snpst), dedup resubmission ROW_NUMBER PARTITION BY
*   sc_periodic_rpt_code ORDER BY sent_tms DESC = 1, roi SUM(item_val) WHERE
*   cell_id='TS024' GROUP BY sc_code/rpt_year/period.
* - capital_adequacy_ratio (cell TS006, bao cao BCTLAT, ky THANG): cung
*   pattern nhu margin_debt_amt, doi sc_rpt_code='BCTLAT', cell_id='TS006'.
*   LLD ghi ro "khong chia don vi" - KHONG nhan 100, giu nguyen gia tri tho.
* - owner_equity_amt (VCSH): khac market_risk_snpst (model do chi tinh 1
*   DIEM tai etl_date), o day can tinh RIENG cho TUNG THANG trong grain (vi
*   model nay la snapshot LICH SU nhieu thang/CTCK) - dung ky thuat ASOF
*   join: voi moi (sc_code, thang trong grain), tim bao cao NAM/BAN_NIEN/QUY
*   gan nhat co sent_tms <= ngay cuoi thang do (snpst_end_dt cua grain), uu
*   tien NAM(1) > BAN_NIEN(2) > QUY(3) roi sent_tms moi nhat - dung y het
*   thu tu uu tien cua market_risk_snpst chain E nhung ASOF theo tung thang
*   thay vi 1 diem etl_date. Neu bao cao duoc chon la BCTCHN lay TS359, nguoc
*   lai (BCTCRL) lay COALESCE(NULLIF(TS223,0), TS221) - dung y LLD.
* - margin_to_equity_ratio = margin_debt_amt / owner_equity_amt * 100
*   (computed, khong doc truc tiep tu nguon).
* - Tat ca 3 chain (margin/car/vcsh) deu LEFT JOIN tu "grain" (driving) nen 1
*   thang bao cao THANG ton tai nhung thieu BCTHHD_CTCK/BCTLAT/bao cao VCSH
*   phu hop van xuat hien trong fact, cot tuong ung = NULL.
* - [Chua resolve, ke thua tu dtm_fct_market_risk_snpst.sql] cell_id TS024/
*   TS359/TS223/TS221/TS006 va ma bao cao BCTHHD_CTCK/BCTCHN/BCTCRL/BCTLAT
*   deu da duoc LLD nay viet truc tiep (khong con placeholder), nhung BAN
*   THAN gia dinh "ref_tp_code = 'BAO_CAO_DINH_KY'" (hardcode, LLD chi ghi
*   "ref_tp_code IS NOT NULL") la ke thua tu market_risk_snpst, CHUA thay LLD
*   nay xac nhan rieng gia tri cu the - giu nguyen vi dang la gia tri DUY
*   NHAT da thay trong du lieu thuc te (theo ghi chu market_risk_snpst).
* 2026-10-17		tuan.nguyenvanb		[DONG BO atm_sc_report_input_value moi] rpt_val.item_val -> rpt_val.cell_val (cot vat ly cell_val). Khong doi cot output -> khong can ALTER.
* 2026-10-19		tuan.nguyenvanb		[UAT doi atm_sc_periodic_report / atm_sc_report_input_submission scd4a -> scd2] bang scd2 khong co _hstr -> doc bang chinh, loc ds_rcrd_st = 'ACTIVE' (bo loc ds_snpst_dt = etl_date).
* 2026-10-23		tuan.nguyenvanb		[SUA LOI toan bo cot so lieu NULL, lam theo dtm_fct_stock_portfolio_snpst (GSTT)] atm_sc_report_input_submission.sc_rpt_code la id so cua form,
*									khong phai ma nghiep vu -> join atm_sc_report (rpt_code IN BCTHHD_CTCK/BCTLAT/BCTCHN/BCTCRL) thay vi so sanh sc_rpt_code voi ma chu;
*									VCSH them loc SHEET_ID theo sheetCode (06620/TS359, 06608/TS223+TS221) qua atm_sc_report_deep_config (CAN build atomic nay truoc);
*									sc_dim them loc ds_snpst_dt = etl_date (truoc day dong bi nhan 3). Khong doi cot -> khong can ALTER.
* 2026-10-23b		tuan.nguyenvanb		[SUA margin/CAR cong thua] TS024 (BCTHHD_CTCK) con o sheet II.6 va TS006 (BCTLAT) o 6 sheet (06H01/04/05/07/08/09): margin T2/2026 flat 1,95 ty vs BA 0,3384 ty
*									(II.8 = 0,3384; II.6 = 1,6169), CAR lay MAX nham sheet (gia tri hang tram nghin %). Them loc sheet: margin II.8, CAR 06H08 qua rpt_sheet
*									(doi ten vcsh_sheet -> rpt_sheet, them 'II.8','06H08'). Khong doi cot -> khong can ALTER; can build lai mart + flat.
* 2026-10-24		tuan.nguyenvanb		[BA XAC NHAN don vi TS024 = TRIEU DONG] margin_debt_amt = SUM(TS024) * 1.000.000 (ra VND nhu LLD); margin_to_equity_ratio tinh lai tu margin VND (~100-350%
*									thay vi 0.00). Khong doi cot/kieu -> khong can ALTER; can build lai mart + flat. Carry-forward 'ky gan nhat co du lieu' (nhu cau BA) xu ly o CAU KHAI THAC, khong doi fact.
* 2026-10-26		tuan.nguyenvanb		[VCSH THEO BA - da kiem chung staging] owner_equity_amt: chi bao cao QUY (BCTCHN TS359, BCTCRL TS223/TS221 khi khong co BCTCHN cung quy); moi thang grain lay QUY GAN NHAT CHUNG
*									cho ca thi truong co end_dt <= cuoi thang (CTE vcsh_latest_quy, khong xet ngay nop); CTCK khong co bao cao quy do -> NULL. Truoc day: as-of theo sent_tms, uu tien NAM > BAN_NIEN > QUY,
*									moi CTCK lay ky rieng. LLD can cap nhat theo.
* 2026-10-26b		tuan.nguyenvanb		[THEM COT owner_equity_period_end_dt (date)] ngay ket thuc cua quy tinh owner_equity_amt (vcsh_latest_quy.end_dt), dat SAU owner_equity_amt -> BAT BUOC
*									ALTER TABLE ... ADD COLUMN owner_equity_period_end_dt date AFTER owner_equity_amt (mart ghi theo VI TRI cot) truoc khi chay; sau do build lai mart + flat.
* 2026-10-26c		tuan.nguyenvanb		[THEM COT total_liabilities_amt decimal(23,2)] tong no phai tra tu SCMS (BCTCHN TS275 sheet 06620, BCTCRL TS137 sheet 06608), cung bao cao/quy voi owner_equity_amt (theo BA);
*									dat SAU owner_equity_period_end_dt -> ALTER ADD COLUMN total_liabilities_amt decimal(23,2) AFTER owner_equity_period_end_dt truoc khi chay.
* 2026-11-02		tuan.nguyenvanb		[DOI LOGIC KY THEO BA - snapshot theo etl_date] Moi lan chay chi ghi dong cua THANG BAO CAO cua etl_date (etl_date la ngay cuoi thang -> chinh thang do, ngay khac -> thang lien truoc; CTE tgt), khong con ghi toan bo lich su vao moi lat. VCSH/no phai tra/D-E dung QUY co dinh theo lich tu thang bao cao (phuong an B: T1-T3 -> Q4 nam truoc, T4-T6 -> Q1, T7-T9 -> Q2, T10-T12 -> Q3; cot grain.vcsh_q_end_dt), cung 1 quy cho moi CTCK, thieu bao cao -> NULL, KHONG lui ky (bo CTE vcsh_latest_quy). Khong xet ngay nop bao cao. owner_equity_period_end_dt luon la cuoi quy ap dung. Khong doi cot/kieu -> khong can ALTER; can build lai mart + flat.
*--------------------------------------------------------------------*
*/

WITH tgt AS (

    -- [2026-11-02 THEO BA] thang bao cao cua etl_date: etl_date la ngay CUOI THANG -> chinh thang do; ngay khac -> thang LIEN TRUOC
    -- (31/10 -> T10; 30/10 -> T9; 01/11 -> T10). Khong lui ve ky gan nhat co du lieu.
    SELECT
        year(m_end) AS m_year
        , month(m_end) AS m_period
    FROM (
        SELECT CASE
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') = last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                THEN to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            ELSE last_day(add_months(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), -1))
        END AS m_end
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
    -- [2026-11-02 THEO BA] chi lay THANG bao cao cua etl_date (tgt)
    INNER JOIN tgt
        ON tgt.m_year = CAST(rpt_year AS int)
        AND tgt.m_period = CAST(period AS int)
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
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')   -- [2026-10-23] thieu filter nay -> dong bi nhan theo so snapshot ACTIVE
        AND ds_rcrd_st = 'ACTIVE'

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
    CAST('SCMS_SC_FIRM_PERIODIC_REPORT' AS string)                AS src_stm_code
FROM grain
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
