/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_report_data
* Program name: Dtm Opr Securities Company Report Data
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 23] Sinh moi -
*                                       Securities Company Report Data.
*                                       [CAP NHAT 2026-10-02] Nguon atm_sc_
*                                       report_input_value DA CO trong atomic
*                                       layer (xem models/atomic/documentation/
*                                       atm_sc_report_input_value.sql) - model
*                                       nay co the dbt run duoc, nhung khoa
*                                       join van can BA xac nhan lai (xem ghi
*                                       chu ben duoi - rui ro cartesian cao
*                                       nhat trong nhom report vi khong co
*                                       dedupe sau JOIN ON 1=1).
*                                       Bang cell-level tho, khong khu trung
*                                       multi-version (khac voi Fact
*                                       Financial Structure Snapshot va
*                                       Financial Report History) - LLD
*                                       khong yeu cau dedupe o day, PK lay
*                                       truc tiep tu Report Input Value Id.
*                                       CAN XAC NHAN LAI: LLD khong mo ta ro
*                                       khoa join giua sc_report_input_value/
*                                       sc_periodic_report/sc_report_input_
*                                       submission (moi bang duoc mo ta rieng
*                                       le theo tung cot, khong co FK chung
*                                       ro rang). Dang tam dung JOIN ON 1=1 -
*                                       PHAI sua lai dung dieu kien join khi
*                                       co atomic that va biet ro cau truc khoa.
* 2026-10-23		claude			[SUA theo dung LLD] Ap dung dung chain
*                                       join da duoc xac nhan (giong
*                                       dtm_opr_securities_company_financial_
*                                       report_hist va dtm_opr_securities_
*                                       company_practitioner_profile): INNER
*                                       JOIN sc_report_input_submission ON
*                                       sc_rpt_input_submission_id, INNER
*                                       JOIN sc_periodic_report ON ref_id =
*                                       sc_periodic_rpt_code AND ref_tp_code =
*                                       'BAO_CAO_DINH_KY', INNER JOIN
*                                       securities_company ON sc_id, JOIN
*                                       sc_report de lay dung rpt_code nghiep
*                                       vu (khong phai sc_rpt_code - ID ky
*                                       thuat form_report_id). Bo JOIN ON
*                                       1=1 (cartesian). Sua ten cot doc sai
*                                       tu atm_sc_report_input_value: row_no
*                                       -> row_index, item_val -> cell_val
*                                       (dung ten that cua atomic hien tai).
* 2026-10-23		claude			[BO SUNG theo LLD cap nhat] Them cot
*                                       rpt_input_submission_id (nguon
*                                       sc_report_input_value.sc_rpt_input_
*                                       submission_id, direct) - dinh danh
*                                       lan nop eForm, phan biet cac lan nop
*                                       cung ky - truoc day cot nay chi dung
*                                       lam khoa JOIN noi bo, chua duoc
*                                       SELECT ra lam cot output.
*                                       [DA KIEM TRA 2026-10-23, CAP NHAT 2026-10-26]
*                                       Mapping bang nay (DTM_QLKD_opr_securities_
*                                       company_report_data_SCMS_REPORT_INPUT_
*                                       CELL_VALUE.csv) khong co dong etl_logic
*                                       nao yeu cau tuong minh dieu kien ds_rcrd_st
*                                       = 'ACTIVE'. Tuy nhien model hien dang ap
*                                       dung filter nay tren ca 3 bang Atomic join
*                                       (sc_report, sc_periodic_report, securities_
*                                       company) - da xac nhan voi user 2026-10-26:
*                                       GIU NGUYEN filter nay (coi la quyet dinh
*                                       nghiep vu da co hieu lech trong code hien
*                                       tai), KHONG go bo. Ghi chu lai de khong con
*                                       mau thuan voi code thuc te nhu truoc day.
* 2026-10-24		claude			[SUA theo dung LLD mapping dong 4-9/15/17/18]
*                                       Thay dieu kien sai `sc_report_input_
*                                       value.data_dt = etl_date` bang dung
*                                       dieu kien LLD yeu cau tren sc_report_
*                                       input_submission: data_dt = MAX(data_dt)
*                                       cua cung sc_rpt_input_submission_id -
*                                       co lap version hien hanh, tranh nhan
*                                       dong khi Atomic APPEND ban ghi moi luc
*                                       nop lai (O_QLKD_55).
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission va
*                                       atm_sc_report_input_value HIEN CHUA
*                                       SELECT cot data_dt trong output - model
*                                       se loi compile (column not found) cho
*                                       toi khi Atomic duoc bo sung cot nay.
*                                       Quyet dinh tam thoi da duoc user xac
*                                       nhan 2026-10-24: sua datamart truoc
*                                       theo dung LLD, bo sung atomic sau.
* 2026-10-26		claude			[BO SUNG theo dung LLD - ket qua ra soat
*                                       doi chieu Mapping] Them cot
*                                       rpt_input_submission_code bi thieu
*                                       (LLD dong 4, nguon sc_report_input_
*                                       value.sc_rpt_input_submission_code,
*                                       direct) - khac voi rpt_input_submission_id
*                                       (surrogate key dai dien, khong dung de
*                                       xep thu tu lan nop).
* 2026-10-28		tuan.nguyenvanb		[BO SUNG theo LLD cap nhat O_QLKD_63]
*                                       Them cot sheet_code (LLD dong 12,
*                                       nguon atm_sc_report_deep_config.
*                                       sheet_code) - ma sheet nghiep vu cua
*                                       eForm dong, dung cho KPI Nhom 31
*                                       (loc sheetCode = 'II.2'). LEFT JOIN
*                                       qua CTE dedup sc_rpt_deep_cfg_dedup
*                                       (SELECT DISTINCT sc_rpt_id, sheet_id,
*                                       sheet_code) theo dung (sc_rpt_id,
*                                       sheet_id) - cung pattern da dung o
*                                       dtm_opr_securities_company_financial_
*                                       report_hist va dtm_opr_securities_
*                                       company_practitioner_profile.
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        sc_rpt_input_val_id,
        sc_rpt_input_submission_code,
        cell_id,
        sheet_id,
        section_id,
        row_index,
        cell_val,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code
    FROM {{ ref('atm_sc_report_input_submission') }} sc_rpt_in_su
    WHERE sc_rpt_in_su.data_dt = (
            SELECT MAX(sub_ver.data_dt)
            FROM {{ ref('atm_sc_report_input_submission') }} sub_ver
            WHERE sub_ver.sc_rpt_input_submission_id = sc_rpt_in_su.sc_rpt_input_submission_id
        )
),

sc_rpt AS (
    SELECT
        sc_rpt_id,
        rpt_code
    FROM {{ ref('atm_sc_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
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
        submission_deadline_dt,
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

sc_rpt_deep_cfg_dedup AS (
    SELECT DISTINCT
        sc_rpt_id,
        sheet_id,
        sheet_code
    FROM {{ ref('atm_sc_report_deep_config') }}
)

SELECT
    CAST(sc_rpt_in_va.sc_rpt_input_val_id AS string) AS rpt_cell_val_id,
    CAST(sc_rpt_in_va.sc_rpt_input_submission_id AS string) AS rpt_input_submission_id,
    CAST(sc_rpt_in_va.sc_rpt_input_submission_code AS string) AS rpt_input_submission_code,
    CAST(se_co.sc_code AS string)                    AS sc_code,
    CAST(se_co.sc_nm AS string)                      AS sc_nm,
    CAST(sc_rpt.rpt_code AS string)                  AS rpt_code,
    CAST(sc_pe_rpt.rpt_year AS int)                  AS rpt_year,
    CAST(sc_pe_rpt.rpt_period AS string)             AS rpt_period,
    CAST(sc_pe_rpt.period AS int)                    AS period_nbr,
    CAST(sc_rpt_in_va.sheet_id AS string)            AS sheet_id,
    CAST(sheet_cfg.sheet_code AS string)             AS sheet_code,
    CAST(sc_rpt_in_va.section_id AS string)          AS section_id,
    CAST(sc_rpt_in_va.cell_id AS string)             AS cell_id,
    CAST(sc_rpt_in_va.row_index AS int)              AS row_nbr,
    CAST(sc_rpt_in_va.cell_val AS string)            AS item_val,
    CAST(sc_pe_rpt.sent_tms AS date)                 AS submission_dt,
    CAST(sc_rpt_in_va.src_stm_code AS string)        AS src_stm_code,
    CAST(sc_pe_rpt.submission_deadline_dt AS date)   AS submission_deadline_dt,
    CAST(sc_pe_rpt.rpt_submission_status_code AS string) AS submission_status_code
FROM sc_rpt_in_va
INNER JOIN sc_rpt_in_su
    ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
INNER JOIN sc_pe_rpt
    ON  sc_pe_rpt.sc_periodic_rpt_code = sc_rpt_in_su.ref_id
    AND sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
INNER JOIN se_co
    ON  se_co.sc_id = sc_pe_rpt.sc_id
JOIN sc_rpt
    ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
LEFT JOIN sc_rpt_deep_cfg_dedup sheet_cfg
    ON  sheet_cfg.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    AND sheet_cfg.sheet_id = sc_rpt_in_va.sheet_id
