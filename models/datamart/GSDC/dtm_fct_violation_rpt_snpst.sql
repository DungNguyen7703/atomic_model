/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_violation_rpt_snpst
* Program name: Dtm Fct Violation Rpt Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-22						Fix bug mat/sai so lieu phat hien qua UAT test cua BA (BA bao
*									Q3/2025: HNX=8, cac san khac=0, trong khi nguon Oracle
*									(violation_report JOIN forms(news_type_cd='DINH_KY') JOIN
*									company_profiles(status='APPROVED_PUBLIC'), loc dung
*									period_year/period_quarter) tra ve HNX=284,HOSE=534,OTC=45,
*									UPCOM=255 (dem theo so dong nghia vu, khong distinct company -
*									1 cong ty co the no nhieu loai bao cao DINH_KY cung ky). Da
*									trace tung CTE, xac nhan vr_all/fr_tpl join dung (khop nguon
*									tuyet doi khi dem COUNT(1)) - loi nam o vr_lts + vr_due/vr_sub:
*									(1) vr_lts chon "ky MOI NHAT tinh den etl_date" cua tung cong ty
*									thay vi giu dung ky dang xet - vi vay khi query 1 ky da qua (vd
*									Q3/2025 test o thoi diem etl_date da sang ky sau), hau het cong
*									ty da "troi" sang ky moi hon nen bi loai khoi output, chi con
*									dung 1 cong ty tinh co con ket o dung ky do.
*									(2) vr_due/vr_sub GROUP BY chi theo pc_code (khong co
*									period_year/period_tp_code) - cong don SO LUONG NGHIA VU DINH_KY
*									TOAN BO LICH SU cua cong ty, gan nham vao dong output cua ky
*									"moi nhat" o (1). Da confirm bang trace: 1 cong ty HNX co
*									vr_lts=(2025,3) va rpt_due_count luy ke ca doi la 8 => dung la
*									con so "8" BA thay.
*									Fix (v1, cung ngay - DA ROLLBACK, xem entry ben duoi): bo han
*									vr_lts, doi vr_due/vr_sub sang GROUP BY them period_year,
*									period_tp_code (grain thanh 1 dong/cong ty/ky). Sau khi doi
*									chieu voi LLD thiet ke (xem
*									ubck_atomic_design/Datamart/lld/GSDC/DTM_GSDC_fct_violation_rpt_snpst.csv)
*									phat hien fix nay VI PHAM grain da khai bao: khoa chi gom
*									public_company_dim_id + snpst_dt_dim_id (FK), rpt_year/rpt_quarter
*									la thuoc tinh (DD) khong phai khoa - dung nghia "1 dong/cong
*									ty/ngay chay, full-scan daily". Doi grain se lam volume fact
*									tang gap nhieu lan moi ngay (khong gioi han rpt_year) va thay
*									doi ca ket qua downstream dtm_public_company_regulatory_compliance_rpt.
*									Nguoi yeu cau xac nhan ROLLBACK ve dung grain thiet ke, chi giu
*									lai phan sua dem hop le (xem entry ben duoi).
* 2026-08-22						Rollback ve dung grain LLD (1 dong/cong ty/ngay), khoi phuc lai
*									vr_lts. Giu lai 1 phan sua hop le doi chieu voi mo ta LLD cho
*									rpt_due_count/rpt_submitted_count: "... da den han nop TRONG KY,
*									theo cong ty" - nhung code cu JOIN vr_due/vr_sub vao ket qua chi
*									theo pc_code (khong rang buoc period_year/period_tp_code), nen
*									dem CONG DON TOAN BO LICH SU nghia vu DINH_KY cua cong ty do roi
*									gan nham vao dong cua ky "moi nhat" (vr_lts) - sai voi mo ta
*									"trong ky" cua LLD. Fix: vr_due/vr_sub van GROUP BY them
*									period_year/period_tp_code (chi de co the JOIN dung ky), nhung
*									final SELECT JOIN vr_due/vr_sub VAO DUNG KY ma vr_lts da chon
*									(theo pc_code + period_year + period_tp_code) thay vi chi
*									pc_code - grain output khong doi (van 1 dong/cong ty/ngay, khop
*									LLD), due/submitted count gio dung nghia "trong ky hien tai cua
*									cong ty" thay vi luy ke lich sư.
*									LUU Y (2026-08-22, da xu ly - xem entry 2026-08-24 ben duoi): voi
*									grain (cong ty, ngay), fact table khong the tra loi dung cau hoi
*									"Q3/2025 co bao nhieu due/submitted" cho TOAN BO cong ty mot khi
*									thoi gian da troi qua khoi ky do, vi moi cong ty chi giu dung 1
*									ky (ky moi nhat tinh den ngay chay). Da bao lai nguoi yeu cau,
*									cho quyet dinh tiep theo.
* 2026-08-24						Doi grain CHINH THUC thanh (public_company_dim_id, rpt_year,
*									rpt_quarter) - moi cong ty giu 1 dong RIENG cho tung ky co nghia
*									vu (vr_lts bi loai bo, vr_due/vr_sub tinh truc tiep theo tung
*									ky). Ly do quay lai huong nay (sau khi da rollback ngay
*									2026-08-22): xac nhan voi nguoi yeu cau ve nghiep vu
*									violation_report - period_year/period_tp_code cua 1 dong la CO
*									DINH, chi actual_submit_dt duoc dien muon (co the muon nhieu ky
*									sau) - voi grain (cong ty, ngay) cu, mot khi "ky moi nhat" troi
*									qua ky cu, moi su kien nop muon cua ky cu KHONG BAO GIO duoc phan
*									anh lai - sai logic nghiep vu khi chay daily, khong chi la van de
*									khop so UAT.
*									Doi materialization tu "append" (INSERT OVERWRITE theo partition
*									snpst_dt_dim_id, moi ngay 1 partition moi) sang "merge" (MERGE
*									INTO theo unique_key = public_company_dim_id + rpt_year +
*									rpt_quarter, xem schema_dtm_gsdc.yml) de kiem soat tang truong
*									volume: voi grain (cong ty, ky) nhung van dung "append", moi ngay
*									se INSERT lai toan bo lich su cac ky cua tung cong ty => phinh du
*									lieu vo han. Dung "merge" thi mot (cong ty, ky) chi co DUNG 1
*									dong vat ly, moi ngay chay chi UPDATE lai dong da co (VD
*									rpt_submitted_count tang khi co nop muon) hoac INSERT dong moi
*									cho ky moi phat sinh - volume tang dung theo thuc te nghiep vu
*									(so cong ty x so ky co nghia vu), khong nhan theo so ngay chay
*									job nua.
*									Anh huong cot audit: vi "merge" dung "WHEN MATCHED THEN UPDATE
*									SET *", ca ds_snpst_dt (macro tu them) VA snpst_dt_dim_id (cot tu
*									select cua model, cung = etl_date) deu bi GHI DE = etl_date cua
*									lan MERGE gan nhat mỗi khi dong bi match lai - tuc la 2 cot nay
*									tu "ngay dong duoc tao" doi thanh "ngay dong duoc cap nhat gan
*									nhat", KHONG con giu duoc ngay tao ban dau. Da kiem tra: khong
*									anh huong toi gsdc_fct_violation_rpt_snpst_flat.sql (filter
*									snpst_dt_dim_id = etl_date) vi voi grain moi, moi (cong ty, ky)
*									con "song" (con nam trong vr_due hom nay) deu duoc touch lai mỗi
*									ngay nen snpst_dt_dim_id luon = hom nay - filter van lay dung
*									toan bo state hien hanh. Edge case: neu 1 (cong ty, ky) khong con
*									xuat hien trong nguon nua (nghia vu bi xoa o nguon, hoac cong ty
*									thanh inactive khoi pc_di), dong do se KHONG duoc touch nua, dung
*									lai voi snpst_dt_dim_id cua lan cuoi con active - tu dong bi loai
*									khoi bang flat (dung y muon) nhung van ton tai vinh vien trong
*									bang Mart nay (merge khong xoa dong not-matched-by-source) - chap
*									nhan duoc vi day la du lieu lich su hop le, khong phai rac tang
*									vo han.
*									CAN LAM TIEP (chua lam trong lan sua nay): cap nhat LLD
*									(ubck_atomic_design/Datamart/lld/GSDC/DTM_GSDC_fct_violation_rpt_snpst.csv)
*									cho khop khoa moi (public_company_dim_id + rpt_year +
*									rpt_quarter, bo snpst_dt_dim_id khoi key) va ghi lai dung nghia
*									moi cua snpst_dt_dim_id ("ngay cap nhat gan nhat", khong phai
*									"ngay chay full-scan daily" nhu truoc).
* 2026-08-26						HUY quyet dinh doi sang "merge" cua entry 2026-08-24 ben tren -
*									GIU LAI "append" (config thuc te trong schema_dtm_gsdc.yml chua
*									tung duoc doi, van la incremental_strategy: append, partition_by:
*									snpst_dt_dim_id). Ly do:
*									(1) Da danh gia lai voi ha tang ve nguy co phinh du lieu - khong
*									can lo dung luong, "append" (moi ngay 1 partition, INSERT lai
*									toan bo lich su cac ky cua tung cong ty) chap nhan duoc, khong can
*									doi sang "merge" (tranh duoc rui ro ghi de cot audit ds_snpst_dt/
*									snpst_dt_dim_id da neu o entry 2026-08-24 - 2 cot nay giu dung
*									nghia "ngay chay job tao ra ban ghi").
*									(2) BA xac nhan: theo quy dinh VN, cong ty duoc phep nop muon bao
*									cao toi da 10 NAM so voi ky goc. Nghia la voi grain (cong ty, ky)
*									hien tai, due/submitted cua CA CAC KY DA QUA RAT LAU van co the
*									thay doi (actual_submit_dt duoc dien them khi nop muon) va PHAI
*									duoc tinh lai/ghi nhan lai O MOI LAN CHAY - vr_all/vr_due/vr_sub
*									trong model nay khong gioi han theo rpt_year nen da tu dong tinh
*									DUNG toan bo nghia vu lich su moi ngay, phu hop yeu cau 10 nam nay.
*									"Append" day du toan bo lich su moi ngay vi vay la dung y do (moi
*									partition = 1 snapshot day du de downstream dedup/as-of theo
*									snpst_dt_dim_id gan nhat <= ngay can xem), khong phai phinh du
*									lieu vo ich.
*									Anh huong downstream: voi "append", 1 (cong ty, ky) co the co
*									NHIEU dong (nhieu partition/ngay) trong bang - ROW_NUMBER dedup
*									"snapshot gan nhat <= etl_date" (CTE violation_dedup trong
*									dtm_public_company_regulatory_compliance_rpt.sql) la BAT BUOC, DA
*									DINH CHINH lai comment o file do (truoc ghi nham la "vestigial" vi
*									gia dinh nham da doi sang merge).
* 2026-09-15						Sua nguon tinh "da nop" cho rpt_submitted_count. BA xac nhan
*									violation_report.actual_submit_dt la SAI nguon (uoc luong tu
*									IDS_VIOLATION_REPORT, khong phan anh dung workflow nop bao cao
*									thuc te) - dinh nghia dung theo query BA cung cap:
*									company_data(news_status_cd='APPROVED') JOIN forms(DINH_KY) JOIN
*									company_profiles(APPROVED_PUBLIC). Them CTE moi
*									pc_report_submission doc atm_pc_report_submission (scd4a
*									current-state, khong can loc ds_snpst_dt/ds_rcrd_st - dung
*									convention da ap dung o
*									dtm_fct_public_company_financial_smy_snpst.sql), loc
*									submission_status_code='APPROVED' AND
*									src_stm_code='IDS_COMPANY_DATA', INNER JOIN fr_template co san
*									(da loc DINH_KY). violation_submitted_summary doi sang dem
*									COUNT(DISTINCT fr_template_id) tren nguon moi nay (tranh dem
*									trung khi 1 form nop/duyet lai nhieu lan).
*									QUYET DINH: rpt_due_count/rpt_submitted_count O BANG NAY VAN la
*									dem "SO BCTC" (khong doi thanh dem distinct cong ty) vi bang
*									fact nay con phuc vu truc tiep Nhom 6 - Ty le nop BCTC =
*									SUM(rpt_submitted_count)/SUM(rpt_due_count) (xem
*									DTM_GSDC_Detail_Mapping.csv, K_GSDC_47/48), can dung don vi "so
*									luong BCTC". Quy doi sang "so cong ty" (CTDC) chi thuc hien
*									rieng o Mart dtm_public_company_regulatory_compliance_rpt (CTE
*									violation_agg, dung COUNT(DISTINCT public_company_dim_id)).
*									rpt_due_count KHONG doi (van tinh tu violation_report/
*									deadline_dt nhu cu). KHONG bo sung loc trang thai cong ty vao
*									model nay khi wire nguon submitted moi - tranh lap lai bug
*									"revoke hoi to" da fix truoc do, loc trang thai as-of theo dung
*									ky van o rieng tai Mart.
* 2026-09-22						Atomic doi co che (scd4a --> scd2/upsert) cho atm_financial_report va
*									atm_pc_report_submission. Sua theo dung: bo hau to _hstr + bo
*									dieu kien ds_snpst_dt (doc thang bang current-state), doi
*									submission_status_code --> approval_status_code
*									(atm_pc_report_submission). Van giu ds_rcrd_st = 'ACTIVE' (soft
*									delete flag khong doi). atm_violation_report KHONG doi (khong
*									thuoc pham vi 10 bang IDS dang chuyen doi) - giu nguyen _hstr/
*									ds_snpst_dt/fr_template_id nhu cu.
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
        public_company_dim_id,
        public_company_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

violation_report AS (
    SELECT
        pc_code,
        vr_code,
        fr_template_id,
        deadline_dt,
        actual_submit_dt,
        period_year,
        quarter_tp_code
    FROM {{ ref('atm_violation_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_VIOLATION_REPORT'
),

fr_template AS (
    SELECT
        fr_id
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND news_tp_code = 'DINH_KY'
        AND src_stm_code = 'IDS_FORMS'
),

violation_due_summary AS (
    SELECT
        violation_report.pc_code,
        violation_report.period_year,
        violation_report.quarter_tp_code,
        COUNT(violation_report.vr_code) AS rpt_due_count
    FROM violation_report
    INNER JOIN fr_template
        ON fr_template.fr_id = violation_report.fr_template_id
    WHERE violation_report.deadline_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY violation_report.pc_code, 
             violation_report.period_year, 
             violation_report.quarter_tp_code
),

-- Nguon "da nop" dung (thay the violation_report.actual_submit_dt)
pc_report_submission AS (
    SELECT
        pc_code,
        fr_id,
        rpt_year,
        rpt_quarter
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_DATA'
        AND approval_status_code = 'APPROVED'

),

violation_submitted_summary AS (
    SELECT
        pc_report_submission.pc_code,
        pc_report_submission.rpt_year                         AS period_year,
        CAST(pc_report_submission.rpt_quarter AS string)      AS quarter_tp_code,
        COUNT(DISTINCT pc_report_submission.fr_id)            AS rpt_submitted_count
    FROM pc_report_submission
    INNER JOIN fr_template
        ON fr_template.fr_id = pc_report_submission.fr_id
    GROUP BY pc_report_submission.pc_code, 
            pc_report_submission.rpt_year, 
            pc_report_submission.rpt_quarter
)

SELECT
    CAST(company.public_company_dim_id AS string)                               AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')       AS snpst_dt_dim_id,
    CAST(violation_due_summary.period_year AS string)                           AS rpt_year,
    CAST(violation_due_summary.quarter_tp_code AS string)                       AS rpt_quarter,
    CAST(violation_due_summary.rpt_due_count AS int)                            AS rpt_due_count,
    CAST(violation_submitted_summary.rpt_submitted_count AS int)                AS rpt_submitted_count
FROM company
JOIN violation_due_summary
    ON violation_due_summary.pc_code = company.public_company_code
LEFT JOIN violation_submitted_summary
    ON  violation_submitted_summary.pc_code = violation_due_summary.pc_code
    AND violation_submitted_summary.period_year = violation_due_summary.period_year
    AND violation_submitted_summary.quarter_tp_code = violation_due_summary.quarter_tp_code

