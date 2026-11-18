/*
*--------------------------------------------------------------------*
* Program code: dtm_report_indicator_dim
* Program name: Dtm Report Indicator Dim
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 21] Sinh moi -
*                                       Report Indicator Dimension. Nguon
*                                       atm_sc_report_input_value CHUA TON
*                                       TAI trong atomic layer (se duoc bo
*                                       sung sau) - model nay chua the
*                                       dbt run cho toi khi co atomic.
*                                       LLD chua chi ro bang cau hinh bieu
*                                       mau nguon cho indicator_code/
*                                       indicator_nm/indicator_group_nm/
*                                       statement_tp_code/unit_of_measure
*                                       (etl_logic ghi "computed" nhung
*                                       khong co cong thuc/bang tra cuu cu
*                                       the) - tam de NULL, CAN BO SUNG khi
*                                       co bang cau hinh bieu mau chinh thuc
*                                       tu BA.
* 2026-10-15		claude			[SUA, theo dung LLD DTM_QLKD_report_
*                                       indicator_dim_SCMS_REPORT_INPUT_CELL_
*                                       VALUE.csv] Doi grain/PK tu chi theo
*                                       cell_id sang composite (rpt_code,
*                                       sheet_id, cell_id) - cung mot cell_id
*                                       mang nghia khac nhau giua cac bieu
*                                       mau/sheet (VD TS001: 'Tong so nguoi
*                                       lao dong' o BCTHHD_CTCK/TTC_T, 'Von
*                                       dieu le' o TTC_Q), truoc day gop
*                                       nham. Them rpt_code (JOIN sc_report_
*                                       input_submission -> sc_report) va
*                                       sheet_id (COALESCE rong neu NULL)
*                                       lam cot NK. Bo 5 cot indicator_code/
*                                       indicator_nm/indicator_group_nm/
*                                       statement_tp_code/unit_of_measure -
*                                       khong co can cu trong Mapping & Design
*                                       (LLD chi dinh nghia 5 cot nghiep vu:
*                                       report_indicator_dim_id, rpt_code,
*                                       sheet_id, cell_id, src_stm_code).
* 2026-10-24		claude			[BO SUNG theo dung LLD mapping dong 3]
*                                       Them dieu kien LLD yeu cau tren
*                                       sc_report_input_submission: data_dt =
*                                       MAX(data_dt) cua cung sc_rpt_input_
*                                       submission_id - co lap version hien
*                                       hanh, tranh nhan dong khi Atomic APPEND
*                                       ban ghi moi luc nop lai (O_QLKD_55).
*                                       Truoc day model khong co dieu kien
*                                       data_dt nao.
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission HIEN
*                                       CHUA SELECT cot data_dt trong output -
*                                       model se loi compile (column not found)
*                                       cho toi khi Atomic duoc bo sung cot
*                                       nay. Quyet dinh tam thoi da duoc user
*                                       xac nhan 2026-10-24: sua datamart
*                                       truoc theo dung LLD, bo sung atomic sau.
* 2026-10-27		claude			[BO SUNG theo dung LLD mapping dong 5,
*                                       O_QLKD_63] Them cot sheet_code - LEFT
*                                       JOIN atm_sc_report_deep_config (da
*                                       SELECT DISTINCT theo sc_rpt_id, sheet_id,
*                                       sheet_code de dedup truoc khi join, vi
*                                       atomic nguon co grain 1 dong/(config,
*                                       sheet, cell) - nhieu cell_id khac nhau
*                                       co the trung (sc_rpt_id, sheet_id) nhung
*                                       cung sheet_code, dung mapping "MAX theo
*                                       (rpt_code, sheet_id) de moi toa do co
*                                       dung 1 ma sheet"). Muc dich: cung cap ma
*                                       sheet nghiep vu truc tiep (VD 06620,
*                                       06608, TTC_T, TTC_Q) de loai bo rui ro
*                                       cong trung cac o cung cell_id nhung
*                                       khac nghia giua cac sheet.
* 2026-10-28		claude			[FIX loi alias sai cot, theo dung LLD
*                                       mapping dong 3-4, O_QLKD_65] Final SELECT
*                                       truoc day gan nham sc_rpt_id vao cot
*                                       output rpt_code (CAST(sc_rpt_id AS string)
*                                       AS rpt_code) va thieu han cot sc_rpt_id, du
*                                       CTE joined da co san ca hai cot rieng biet.
*                                       Sua lai dung: rpt_code lay tu joined.
*                                       rpt_code, bo sung cot sc_rpt_id tu joined.
*                                       sc_rpt_id (NK moi - phan biet cac ban bieu
*                                       mau cung rpt_code khi nop lai/doi thong
*                                       tu). Doi hash PK tu 3 thanh phan (sc_rpt_id,
*                                       sheet_id, cell_id) sang dung 4 thanh phan
*                                       LLD yeu cau (rpt_code, sc_rpt_id, sheet_id,
*                                       cell_id).
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        cell_id,
        sheet_id,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id
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
),

sc_rpt_deep_cfg_dedup AS (
    SELECT DISTINCT
        sc_rpt_id,
        sheet_id,
        sheet_code
    FROM {{ ref('atm_sc_report_deep_config') }}
),

joined AS (
    SELECT DISTINCT
        sc_rpt.sc_rpt_id                          AS sc_rpt_id,
        sc_rpt.rpt_code                           AS rpt_code,
        COALESCE(sc_rpt_in_va.sheet_id, '')       AS sheet_id,
        sc_rpt_deep_cfg_dedup.sheet_code          AS sheet_code,
        sc_rpt_in_va.cell_id                      AS cell_id,
        sc_rpt_in_va.src_stm_code                 AS src_stm_code
    FROM sc_rpt_in_va
    JOIN sc_rpt_in_su
        ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
    JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    LEFT JOIN sc_rpt_deep_cfg_dedup
        ON  sc_rpt_deep_cfg_dedup.sc_rpt_id = sc_rpt.sc_rpt_id
        AND sc_rpt_deep_cfg_dedup.sheet_id = sc_rpt_in_va.sheet_id
)

SELECT
    {{ generate_surrogate_key_bigint('REPORT_INDICATOR_DIM', "concat_ws('-', joined.rpt_code, joined.sc_rpt_id, joined.sheet_id, joined.cell_id)") }} AS report_indicator_dim_id,
    CAST(rpt_code AS string)             AS rpt_code,
    CAST(sc_rpt_id AS string)            AS sc_rpt_id,
    CAST(sheet_id AS string)             AS sheet_id,
    CAST(sheet_code AS string)           AS sheet_code,
    CAST(cell_id AS string)              AS cell_id,
    CAST(src_stm_code AS string)         AS src_stm_code
FROM joined
