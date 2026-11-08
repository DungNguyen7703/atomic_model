-- [FIRST-TIME] ft_dtm_fct_foreign_investor_capital_flow_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_foreign_investor_capital_flow_snpst (config ft_target='fct_foreign_investor_capital_flow_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_investor_capital_flow_snpst
* Program name: Fact Foreign Investor Capital Flow Snapshot
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-12		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao: dim scd4a doc bang MAIN thay vi
*                                       <bang>_hstr tai etl_date. Fact daily von da doc toan bo atm_fir_value
*                                       (khong loc etl_date) nen phan fact giu nguyen.
* 2026-10-17		nghia.le			Bo Foreign Investor Reporting Entity Dimension khoi fact (theo DTM moi + bang mart thuc te khong con cot
*									foreign_investor_reporting_entity_dim_id): bo cot FK, CTE fi_re_en_di va LEFT JOIN tuong ung.
* 2026-10-13		nghia.le			[RULE BAO CAO DINH KY / BAT THUONG] nap them bao cao bat thuong EPW5C/V2YZM/22ZBE; them 2 cot CUOI bang rpt_code, rpt_dt_dim_id (ngay chot so lieu)
*                                       - can ALTER TABLE datamart.uat_dtm.fct_foreign_investor_capital_flow_snpst ADD COLUMNS (rpt_code string, rpt_dt_dim_id string).
*                                       Dung cho K_NDTNN_29..32 (dinh ky IBOU9 den moc nua thang, bat thuong tu sau moc).
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Pivot 1 dong bao cao: GROUP BY rpt_log_id, section_id, dynamic_row_order
*   tren fir_value x fir_structure x foreign_investor_report, bao cao IBOU9
*   sheet 'I' (PLIV-TT51). Doc dung theo LLD
*   DTM_NDTNN_fct_foreign_investor_capital_flow_snpst.csv, khong loc etl_date.
* - Atomic fir_structure / foreign_investor_report materialize SCD2 (khong
*   co _hstr): ban ghi hien hanh ds_rcrd_st = 'ACTIVE' AND
*   ds_rcrd_end_dt = to_date('2400-01-01').
* - snpst_dt_dim_id = ngay thuc te nop bao cao (MAX submission_dt).
*--------------------------------------------------------------------*
*/

WITH fi_va AS (
    SELECT
        fir_structure_id,
        rpt_log_id,
        period_val,
        submission_dt,
        dynamic_row_order,
        total_row_ind,
        section_echo_ind,
        band_overflow_ind,
        static_copy_ind,
        rpt_marker_ind,
        val_raw,
        src_stm_code,
        rpt_day   -- ngày chốt số liệu GỐC, NULL khi nguồn không có (không fallback ở đây — ClickHouse tự ifNull theo ngày nộp)
    FROM {{ ref('atm_fir_value') }}
    WHERE src_stm_code = 'FIMS_FIR_VALUE'
),

fi_st AS (
    SELECT
        fir_structure_id,
        fir_id,
        section_id,
        row_path,
        column_path
    FROM {{ ref('atm_fir_structure') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
),

fo_in_re AS (
    SELECT
        fir_id,
        rpt_code,
        sheet_nm
    FROM {{ ref('atm_foreign_investor_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),


ca_fl AS (
    SELECT
        fi_va.rpt_log_id,
        fi_st.section_id,
        fi_va.dynamic_row_order,
        MAX(fi_va.submission_dt)                                   AS submission_dt,
        MAX(fi_va.period_val)                                      AS period_val,
        MAX(CASE WHEN fi_st.column_path = 'Quốc tịch' THEN fi_va.val_raw END) AS nationality_nm,
        MAX(CASE WHEN fi_st.column_path = 'Tên nhà đầu tư' THEN fi_va.val_raw END) AS investor_nm,
        MAX(CASE WHEN fi_st.column_path IN ('Giá trị dòng vốn vào trong kỳ báo cáo (+/-) (đơn vị USD)', 'Kỳ báo cáo > Giá trị dòng vốn vào trong kỳ báo cáo (+/-) (đơn vị USD)') THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS capital_flow_net_val,
        MAX(fi_va.src_stm_code)                                    AS src_stm_code,
        MAX(fo_in_re.rpt_code)                                     AS rpt_code,
        MAX(fi_va.rpt_day)                                         AS rpt_day
    FROM fi_va
    INNER JOIN fi_st
        ON  fi_st.fir_structure_id = fi_va.fir_structure_id
    INNER JOIN fo_in_re
        ON  fo_in_re.fir_id = fi_st.fir_id
    -- [RULE BAO CAO DINH KY / BAT THUONG 2026-10-13] IBOU9 (dinh ky, sheet 'I') + 3 mau bat thuong EPW5C/V2YZM/22ZBE (sheet 'Input 2 - Vốn', cung cau truc cot).
    -- Moc dinh ky/bat thuong ap o tang KPI theo to_date (xem 03_kpi_queries.sql).
    WHERE ((fo_in_re.rpt_code = 'IBOU9' AND fo_in_re.sheet_nm = 'I')
           OR (fo_in_re.rpt_code IN ('EPW5C', 'V2YZM', '22ZBE') AND fo_in_re.sheet_nm = 'Input 2 - Vốn'))
        AND fi_va.total_row_ind = 0
        AND fi_va.section_echo_ind = 0
        AND fi_va.band_overflow_ind = 0
        AND fi_va.static_copy_ind = 0
        AND fi_va.rpt_marker_ind = 0
    GROUP BY fi_va.rpt_log_id, fi_st.section_id, fi_va.dynamic_row_order
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                    AS snpst_dt_dim_id,
    CAST(rp_cd_dt_di.cdr_dt_dim_id AS string)                                 AS rpt_dt_dim_id,
    CAST(ca_fl.rpt_log_id AS string)                                          AS rpt_log_id,
    CAST(ca_fl.section_id AS string)                                          AS section_id,
    CAST(ca_fl.dynamic_row_order AS int)                                      AS dynamic_row_order,
    CAST(ca_fl.period_val AS string)                                          AS period_val,
    CAST(ca_fl.rpt_code AS string)                                            AS rpt_code,
    CAST(ca_fl.nationality_nm AS string)                                      AS nationality_nm,
    CAST(ca_fl.investor_nm AS string)                                         AS investor_nm,
    CAST(ca_fl.capital_flow_net_val AS decimal(23,2))                         AS capital_flow_net_val,
    CAST(ca_fl.src_stm_code AS string)                                        AS src_stm_code


FROM ca_fl
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = ca_fl.submission_dt
LEFT JOIN cd_dt_di rp_cd_dt_di
    ON  rp_cd_dt_di.cdr_dt = ca_fl.rpt_day
