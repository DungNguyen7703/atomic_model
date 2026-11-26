--*--------------------------------------------------------------------*
--* Program code: dtm_fct_foreign_capital_flow_summary_snpst
--* Program name: Fact Foreign Capital Flow Summary Snapshot
--* Created by: huy.pham
--* Created date: 2026-11-05
--*--------------------------------------------------------------------*
--* Modified management
--* Date            User            Description
--* 2026-11-05      huy.pham        [MOI, theo LLD] Fact snapshot dong von NDTNN theo
--*                                 ky bao cao nua thang (IBOU9, sheet 'I'). Grain = 1
--*                                 doi tuong nop (reporting_entity_code / TVLK) x 1 ky
--*                                 bao cao (period_val, rpt_year). Khử trung: giu ban
--*                                 nop moi nhat (rpt_day DESC, submission_dt DESC,
--*                                 rpt_log_id DESC). Pivot dong 'Tong= (1) + (2)' thanh
--*                                 3 do do. PK hash(reporting_entity_code|period_val|
--*                                 rpt_year|src_stm_code). snpst_dt_dim_id = yyyyMMdd
--*                                 (submission_dt). Materialization append / partition
--*                                 snpst_dt_dim_id. fir_structure / foreign_investor_
--*                                 report: SCD2 -> filter ds_rcrd_st = 'ACTIVE'.
--*                                 Khong ap indicator flags vi dong 'Tong= (1) + (2)'
--*                                 co the la total_row_ind = 1.
--* 2026-11-06      huy.pham        [SUA] Doi tu merge sang append, partition theo
--*                                 snpst_dt_dim_id = yyyyMMdd(submission_dt). Them cot
--*                                 rpt_dt_dim_id = yyyyMMdd(rpt_day) de khai thac tren
--*                                 ClickHouse. Filter incremental doi sang submission_dt.
--*--------------------------------------------------------------------*

WITH fi_va AS (
    SELECT
        fir_structure_id,
        rpt_log_id,
        reporting_entity_code,
        rpt_year,
        period_val,
        rpt_day,
        submission_dt,
        src_stm_code,
        val_raw
    FROM {{ ref('atm_fir_value') }}
    WHERE src_stm_code      = 'FIMS_FIR_VALUE'
        AND period_tp_code  = 'NUA_THANG'
        ---- AND rpt_day         <= to_date('...')
        --AND submission_dt   <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

fi_st AS (
    SELECT
        fir_structure_id,
        fir_id,
        column_path
    FROM {{ ref('atm_fir_structure') }}
    WHERE ds_rcrd_st        = 'ACTIVE'
        -- AND ds_rcrd_end_dt  = to_date('2400-01-01')
        AND row_path        = 'Tổng= (1) + (2)'
),

fo_in_re AS (
    SELECT
        fir_id
    FROM {{ ref('atm_foreign_investor_report') }}
    WHERE ds_rcrd_st        = 'ACTIVE'
        --AND ds_rcrd_end_dt  = to_date('2400-01-01')
        AND rpt_code        = 'IBOU9'
        AND sheet_nm        = 'I'
),

pvt AS (
    SELECT
        fi_va.rpt_log_id,
        fi_va.reporting_entity_code,
        fi_va.rpt_year,
        fi_va.period_val,
        MAX(fi_va.rpt_day)                                                                 AS rpt_day,
        MAX(fi_va.submission_dt)                                                           AS submission_dt,
        MAX(fi_va.src_stm_code)                                                            AS src_stm_code,
        MAX(CASE WHEN fi_st.column_path = 'Giá trị dòng vốn vào trong kỳ báo cáo (+/-) (đơn vị USD)'
                 THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38, 15)) END) AS capital_flow_net_val,
        MAX(CASE WHEN fi_st.column_path = 'Tổng giá trị ngoại tệ đổi sang VND trong kỳ báo cáo (đơn vị USD)'
                 THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38, 15)) END) AS capital_inflow_val,
        MAX(CASE WHEN fi_st.column_path = 'Tổng giá trị VND đổi ra ngoại tệ và chuyển ra trong kỳ báo cáo (đơn vị USD)'
                 THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38, 15)) END) AS capital_outflow_val
    FROM fi_va
    INNER JOIN fi_st
        ON  fi_st.fir_structure_id = fi_va.fir_structure_id
    INNER JOIN fo_in_re
        ON  fo_in_re.fir_id = fi_st.fir_id
    GROUP BY fi_va.rpt_log_id, fi_va.reporting_entity_code, fi_va.rpt_year, fi_va.period_val
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY reporting_entity_code, rpt_year, period_val
            ORDER BY rpt_day DESC, submission_dt DESC, rpt_log_id DESC
        ) AS row_num
    FROM pvt
)

SELECT
    CAST({{ generate_surrogate_key(
        'FIMS_FIR_VALUE',
        "CONCAT(reporting_entity_code, '|', period_val, '|', CAST(rpt_year AS string), '|', src_stm_code)"
    ) }} AS string)                                                                        AS foreign_capital_flow_summary_snpst_id,
    CAST(date_format(submission_dt, 'yyyyMMdd') AS string)                                 AS snpst_dt_dim_id,
    CAST(date_format(rpt_day, 'yyyyMMdd') AS string)                                       AS rpt_dt_dim_id,
    CAST(reporting_entity_code AS string)                                                  AS reporting_entity_code,
    CAST(period_val AS string)                                                             AS period_val,
    CAST(rpt_year AS int)                                                                  AS rpt_year,
    CAST(capital_flow_net_val AS decimal(38, 15))                                          AS capital_flow_net_val,
    CAST(capital_inflow_val AS decimal(38, 15))                                            AS capital_inflow_val,
    CAST(capital_outflow_val AS decimal(38, 15))                                           AS capital_outflow_val,
    CAST(src_stm_code AS string)                                                           AS src_stm_code
FROM dedup
WHERE row_num = 1
