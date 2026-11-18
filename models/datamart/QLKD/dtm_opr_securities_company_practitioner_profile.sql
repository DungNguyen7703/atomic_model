/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_practitioner_profile
* Program name: Dtm Opr Securities Company Practitioner Profile
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 25] Sinh moi -
*                                       Securities Company Practitioner
*                                       Profile.
* 2026-10-19		claude				[SUA theo LLD moi nhat] Thay CROSS
*                                       JOIN bang khoa join that (giong chain
*                                       dung o dtm_opr_securities_company_
*                                       financial_report_hist): INNER JOIN
*                                       sc_report_input_submission ON
*                                       sc_rpt_input_submission_id, INNER
*                                       JOIN sc_periodic_report ON ref_id =
*                                       sc_periodic_rpt_code AND ref_tp_code =
*                                       'BAO_CAO_DINH_KY', INNER JOIN
*                                       securities_company ON sc_id, INNER
*                                       JOIN sc_report ON sc_rpt_id. Them
*                                       filter bat buoc theo LLD: rpt_code IN
*                                       ('BCTHHD_CTCK','BCHDPS') AND
*                                       ref_tp_code = 'BAO_CAO_DINH_KY' AND
*                                       sent_tms IS NOT NULL - day la dieu
*                                       kien phan biet voi financial_report_
*                                       hist (cung nguon atomic). Sua ten cot
*                                       item_val -> cell_val. Sua lai toan bo
*                                       bo cell_id dung theo LLD (TS017/TS018
*                                       cho BCTHHD_CTCK, TS107/TS115/TS119/
*                                       TS111 cho BCTHHD_CTCK theo bo phan,
*                                       TS009/TS017/TS013 cho BCHDPS) - moi
*                                       CASE WHEN co guard rpt_code tuong ung
*                                       vi TS017 trung ma giua 2 bieu mau.
*                                       unlicensed_practitioner_cnt doi sang
*                                       TS017 - TS018 (tru 2 cell) thay vi doc
*                                       1 cell rieng. Doi SUM -> MAX theo dung
*                                       LLD (khoa join da dung nen khong con
*                                       fan-out). Them cot rpt_code,
*                                       rpt_period_tp_code, submission_status_
*                                       code bi thieu. Sua PK hash du 5 thanh
*                                       phan (sc_code, rpt_code, rpt_year,
*                                       rpt_period, period) theo dung LLD.
* 2026-10-24		claude			[BO SUNG theo dung LLD mapping - moi cot FK/DD/
*                                       src_stm_code] Them dieu kien LLD yeu
*                                       cau tren sc_report_input_submission:
*                                       data_dt = MAX(data_dt) cua cung
*                                       sc_rpt_input_submission_id - co lap
*                                       version hien hanh, tranh nhan dong khi
*                                       Atomic APPEND ban ghi moi luc nop lai
*                                       (O_QLKD_55). Truoc day model khong co
*                                       dieu kien data_dt nao.
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission va
*                                       atm_sc_report_input_value HIEN CHUA
*                                       SELECT cot data_dt trong output - model
*                                       se loi compile (column not found) cho
*                                       toi khi Atomic duoc bo sung cot nay.
*                                       Quyet dinh tam thoi da duoc user xac
*                                       nhan 2026-10-24: sua datamart truoc
*                                       theo dung LLD, bo sung atomic sau.
* 2026-10-26		claude			[SUA theo dung LLD moi nhat - ket qua ra soat
*                                       doi chieu Mapping] (1) Sua cell_id SAI:
*                                       total_employee_cnt phai la TS001 (khong
*                                       phai TS017), licensed_practitioner_cnt
*                                       phai la TS002 (khong phai TS018) - LLD
*                                       dong 9/10 ghi ro TS017/TS018 la ma CU da
*                                       lap thoi ("truoc do TS017 sheet TTC_N ky
*                                       Nam"), ban moi (BA 24/10) dung TS001/
*                                       TS002 sheet TTC_T. (2) Them dieu kien
*                                       loc bat buoc rpt_period = 'THANG' cho 2
*                                       CASE WHEN tren (LLD: "Chi co gia tri o
*                                       dong ky THANG vi cung ma o TS001 o ky
*                                       QUY la von dieu le"). (3) Them cot end_dt
*                                       vao CTE sc_pe_rpt (nguon atm_sc_periodic_
*                                       report.end_dt) va doi dieu kien loc bat
*                                       buoc tu sent_tms IS NOT NULL sang end_dt
*                                       IS NOT NULL (LLD dong 22: "BA 24/10:
*                                       p.END_DATE IS NOT NULL thay cho p.
*                                       SENT_AT IS NOT NULL"). (4) Bo sung cot
*                                       output end_dt (LLD dong 20) - chi xuat
*                                       nhu mot cot du lieu binh thuong, KHONG
*                                       them tang xu ly "latest_per_ctck" vi do
*                                       la co che rieng cua KPI Nhom 28-30 khac,
*                                       khong thuoc pham vi bang nay (da xac nhan
*                                       voi user 2026-10-26). (5) Them buoc khu
*                                       trung theo MAX(sc_rpt_input_submission_
*                                       code) ep kieu BIGINT trong tung slot
*                                       (ref_tp_code, ref_id) tai CTE sc_rpt_in_su
*                                       (LLD dong 22: "moi slot (ref_tp_code,
*                                       ref_id) lay ban nop co sc_rpt_input_
*                                       submission_code lon nhat") - thuc hien
*                                       TRUOC buoc khu trung theo sent_tms da co
*                                       san o CTE agg (giu nguyen, LLD yeu cau 2
*                                       buoc khu trung noi tiep nhau).
* 2026-10-26		claude			[SUA theo xac nhan user - ket qua ra soat
*                                       doi chieu Mapping lan 2] Them dieu kien
*                                       loc con thieu sc_pe_rpt.rpt_period =
*                                       'NAM' cho 7 CASE WHEN: brokerage/
*                                       underwriting/advisory/proprietary_
*                                       practitioner_cnt (BCTHHD_CTCK nhom STT
*                                       29) va deriv_brokerage/advisory/
*                                       proprietary_practitioner_cnt (BCHDPS
*                                       nhom STT 30). LLD dong 7 (NK rpt_period_
*                                       tp_code): "BA STT 28 loc THANG...; BA
*                                       STT 29/30 loc NAM" va mo ta dong 12/16
*                                       ("sheet II.1/01, ky Nam") xac nhan cac
*                                       bieu mau nay chi co gia tri o ky NAM -
*                                       truoc day cac CASE WHEN nay chi loc
*                                       theo rpt_code + cell_id, thieu dieu
*                                       kien ky bao cao nen co rui ro trung ma
*                                       o neu cung cell_id xuat hien o ky khac
*                                       cua cung bieu mau (tuong tu rui ro da
*                                       biet voi TS001/TS002).
* 2026-10-28		claude			[BO SUNG theo dung LLD mapping, O_QLKD_63/64]
*                                       (1) Them CTE sc_rpt_deep_cfg_dedup
*                                       (SELECT DISTINCT sc_rpt_id, sheet_id,
*                                       sheet_code FROM atm_sc_report_deep_
*                                       config) va LEFT JOIN vao CTE joined
*                                       theo (sc_rpt_id, sheet_id). Them dieu
*                                       kien sheet_cfg.sheet_code vao 9 CASE
*                                       WHEN: total_employee_cnt/licensed_
*                                       practitioner_cnt loc sheet 'TTC_T'
*                                       (BCTHHD_CTCK, ky THANG); brokerage/
*                                       underwriting/advisory/proprietary_
*                                       practitioner_cnt loc sheet 'II.1'
*                                       (BCTHHD_CTCK, ky NAM); deriv_brokerage/
*                                       advisory/proprietary_practitioner_cnt
*                                       loc sheet '01' (BCHDPS, ky NAM). Ly do:
*                                       cung mot ma o xuat hien o nhieu sheet
*                                       khac nhau cua cung bieu mau - truoc day
*                                       khong loc sheet nen MAX lay nham gia tri
*                                       sai (BA phat hien lech so Staging vs
*                                       ClickHouse, issue 27/10 #266/#267).
*                                       (2) Them cot legal_basis (nguon sc_rpt.
*                                       legal_basis, da co san trong atm_sc_
*                                       report) vao SELECT cua CTE joined/agg/
*                                       final, vao thanh phan PK hash
*                                       (prac_profile_id them legal_basis sau
*                                       rpt_code) va vao GROUP BY + PARTITION
*                                       BY khu trung o CTE agg - theo dung
*                                       Mapping: moi bieu mau theo tung thong tu
*                                       la mot dong rieng, khong gop cheo thong
*                                       tu (KPI Nhom 28/29 loc legal_basis LIKE
*                                       '%121/2020/TT-BTC%').
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        cell_id,
        cell_val,
        sheet_id,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt_in_su_ver AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code,
        sc_rpt_input_submission_code,
        row_number() over (
            partition by ref_tp_code, ref_id
            order by TRY_CAST(sc_rpt_input_submission_code AS BIGINT) DESC
        ) as rn_submission
    FROM {{ ref('atm_sc_report_input_submission') }} sc_rpt_in_su
    WHERE sc_rpt_in_su.data_dt = (
        SELECT MAX(sub_ver.data_dt)
        FROM {{ ref('atm_sc_report_input_submission') }} sub_ver
        WHERE sub_ver.sc_rpt_input_submission_id = sc_rpt_in_su.sc_rpt_input_submission_id
    )
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code
    FROM sc_rpt_in_su_ver
    WHERE rn_submission = 1
),

sc_rpt AS (
    SELECT
        sc_rpt_id,
        rpt_code,
        legal_basis
    FROM {{ ref('atm_sc_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

sc_rpt_deep_cfg_dedup AS (
    SELECT DISTINCT
        sc_rpt_id,
        sheet_id,
        sheet_code
    FROM {{ ref('atm_sc_report_deep_config') }}
),

sc_pe_rpt AS (
    SELECT
        sc_id,
        sc_code,
        sc_periodic_rpt_code,
        rpt_year,
        rpt_period,
        period,
        sent_tms,
        end_dt,
        rpt_submission_status_code
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND ds_rcrd_st = 'ACTIVE'
),

se_co AS (
    SELECT
        sc_id,
        sc_code,
        sc_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

joined AS (
    SELECT
        se_co.sc_code                                                                                                     AS sc_code,
        se_co.sc_nm                                                                                                       AS sc_nm,
        sc_rpt.rpt_code                                                                                                   AS rpt_code,
        sc_rpt.legal_basis                                                                                                AS legal_basis,
        sc_pe_rpt.rpt_year                                                                                                AS rpt_year,
        sc_pe_rpt.rpt_period                                                                                              AS rpt_period_tp_code,
        sc_pe_rpt.period                                                                                                  AS period_nbr,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'THANG' AND sheet_cfg.sheet_code = 'TTC_T' AND sc_rpt_in_va.cell_id = 'TS001' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS total_employee_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'THANG' AND sheet_cfg.sheet_code = 'TTC_T' AND sc_rpt_in_va.cell_id = 'TS002' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS licensed_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = 'II.1' AND sc_rpt_in_va.cell_id = 'TS107' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS brokerage_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = 'II.1' AND sc_rpt_in_va.cell_id = 'TS115' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS underwriting_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = 'II.1' AND sc_rpt_in_va.cell_id = 'TS119' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS advisory_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = 'II.1' AND sc_rpt_in_va.cell_id = 'TS111' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS proprietary_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = '01'   AND sc_rpt_in_va.cell_id = 'TS009' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_brokerage_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = '01'   AND sc_rpt_in_va.cell_id = 'TS017' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_advisory_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_pe_rpt.rpt_period = 'NAM' AND sheet_cfg.sheet_code = '01'   AND sc_rpt_in_va.cell_id = 'TS013' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_proprietary_practitioner_cnt,
        CAST(sc_pe_rpt.sent_tms AS date)                                                                                  AS submission_dt,
        CAST(sc_pe_rpt.end_dt AS date)                                                                                    AS end_dt,
        sc_pe_rpt.rpt_submission_status_code                                                                             AS submission_status_code,
        sc_rpt_in_va.src_stm_code                                                                                         AS src_stm_code
    FROM sc_rpt_in_va
    INNER JOIN sc_rpt_in_su
        ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
    INNER JOIN sc_pe_rpt
        ON  sc_pe_rpt.sc_periodic_rpt_code = sc_rpt_in_su.ref_id
        AND sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
    INNER JOIN se_co
        ON  se_co.sc_id = sc_pe_rpt.sc_id
    INNER JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    LEFT JOIN sc_rpt_deep_cfg_dedup sheet_cfg
        ON  sheet_cfg.sc_rpt_id = sc_rpt.sc_rpt_id
        AND sheet_cfg.sheet_id = sc_rpt_in_va.sheet_id
    WHERE sc_rpt.rpt_code IN ('BCTHHD_CTCK', 'BCHDPS')
        AND sc_pe_rpt.end_dt IS NOT NULL
),

agg AS (
    SELECT
        sc_code,
        sc_nm,
        rpt_code,
        legal_basis,
        rpt_year,
        rpt_period_tp_code,
        period_nbr,
        MAX(total_employee_cnt)                 AS total_employee_cnt,
        MAX(licensed_practitioner_cnt)          AS licensed_practitioner_cnt,
        MAX(total_employee_cnt) - MAX(licensed_practitioner_cnt) AS unlicensed_practitioner_cnt,
        MAX(brokerage_practitioner_cnt)         AS brokerage_practitioner_cnt,
        MAX(underwriting_practitioner_cnt)      AS underwriting_practitioner_cnt,
        MAX(advisory_practitioner_cnt)          AS advisory_practitioner_cnt,
        MAX(proprietary_practitioner_cnt)       AS proprietary_practitioner_cnt,
        MAX(deriv_brokerage_practitioner_cnt)   AS deriv_brokerage_practitioner_cnt,
        MAX(deriv_advisory_practitioner_cnt)    AS deriv_advisory_practitioner_cnt,
        MAX(deriv_proprietary_practitioner_cnt) AS deriv_proprietary_practitioner_cnt,
        MAX(submission_dt)                      AS submission_dt,
        MAX(end_dt)                              AS end_dt,
        MAX(submission_status_code)             AS submission_status_code,
        MAX(src_stm_code)                       AS src_stm_code,
        row_number() over (
            partition by sc_code, rpt_code, legal_basis, rpt_year, rpt_period_tp_code, period_nbr
            order by MAX(submission_dt) desc
        ) as rn
    FROM joined
    GROUP BY sc_code, sc_nm, rpt_code, legal_basis, rpt_year, rpt_period_tp_code, period_nbr
)

SELECT
    CAST({{ generate_surrogate_key_bigint('OPR_SC_PRAC_PROFILE', "concat_ws('-', agg.sc_code, agg.rpt_code, COALESCE(agg.legal_basis, ''), agg.rpt_year, agg.rpt_period_tp_code, agg.period_nbr)") }} AS string) AS prac_profile_id,
    CAST(sc_code AS string)                              AS sc_code,
    CAST(sc_nm AS string)                                AS sc_nm,
    CAST(rpt_code AS string)                             AS rpt_code,
    CAST(legal_basis AS string)                          AS legal_basis,
    CAST(rpt_year AS int)                                AS rpt_year,
    CAST(rpt_period_tp_code AS string)                   AS rpt_period_tp_code,
    CAST(period_nbr AS int)                              AS period_nbr,
    CAST(total_employee_cnt AS int)                      AS total_employee_cnt,
    CAST(licensed_practitioner_cnt AS int)               AS licensed_practitioner_cnt,
    CAST(unlicensed_practitioner_cnt AS int)             AS unlicensed_practitioner_cnt,
    CAST(brokerage_practitioner_cnt AS int)              AS brokerage_practitioner_cnt,
    CAST(underwriting_practitioner_cnt AS int)           AS underwriting_practitioner_cnt,
    CAST(advisory_practitioner_cnt AS int)               AS advisory_practitioner_cnt,
    CAST(proprietary_practitioner_cnt AS int)            AS proprietary_practitioner_cnt,
    CAST(deriv_brokerage_practitioner_cnt AS int)        AS deriv_brokerage_practitioner_cnt,
    CAST(deriv_advisory_practitioner_cnt AS int)         AS deriv_advisory_practitioner_cnt,
    CAST(deriv_proprietary_practitioner_cnt AS int)      AS deriv_proprietary_practitioner_cnt,
    CAST(submission_dt AS date)                          AS submission_dt,
    CAST(end_dt AS date)                                 AS end_dt,
    CAST(submission_status_code AS string)               AS submission_status_code,
    CAST(src_stm_code AS string)                         AS src_stm_code
FROM agg
WHERE rn = 1
