-- [FIRST-TIME] ft_dtm_fct_foreign_bank_branch_portfolio_report_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_foreign_bank_branch_portfolio_report_snpst (config ft_target='fct_foreign_bank_branch_portfolio_report_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_bank_branch_portfolio_report_snpst
* Program name: Fact Foreign Bank Branch Portfolio Report Snapshot
* Created by:
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		claude				[FIRST-TIME NDTNN] Tao moi, dong bo daily dtm_fct_foreign_bank_branch_portfolio_report_snpst
*									(LLD O_NDTNN_60). Fact daily von da doc toan bo atm_fir_value (khong loc etl_date)
*									nen phan fact giu nguyen, khong can ft_ref.
*--------------------------------------------------------------------*
* Ghi chu:
* - Grain = 1 o 'So du cuoi ky > Gia tri' cua 1 dong tai san sheet III bao cao 59WJB x 1 lan nop;
*   PK = fir_val_id. KHONG GROUP BY / pivot.
* - Atomic fir_structure / foreign_investor_report materialize SCD2 (khong co _hstr):
*   ban ghi hien hanh ds_rcrd_st = 'ACTIVE' AND ds_rcrd_end_dt = to_date('2400-01-01').
*--------------------------------------------------------------------*
*/

WITH fi_va AS (
    SELECT
        fir_val_id,
        fir_structure_id,
        rpt_log_id,
        period_val,
        submission_dt,
        rpt_day,
        total_row_ind,
        section_echo_ind,
        band_overflow_ind,
        static_copy_ind,
        rpt_marker_ind,
        val_raw,
        src_stm_code
    FROM {{ ref('atm_fir_value') }}
    WHERE src_stm_code = 'FIMS_FIR_VALUE'
        AND ds_rcrd_st='ACTIVE'
),

fi_st AS (
    SELECT
        fir_structure_id,
        fir_id,
        row_path,
        column_path
    FROM {{ ref('atm_fir_structure') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

fo_in_re AS (
    SELECT
        fir_id,
        rpt_code,
        sheet_nm
    FROM {{ ref('atm_foreign_investor_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
)

SELECT
    CAST(fi_va.fir_val_id AS string)                                          AS fir_val_id,
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                    AS snpst_dt_dim_id,
    CAST(rp_cd_dt_di.cdr_dt_dim_id AS string)                                 AS rpt_dt_dim_id,
    CAST(fi_va.rpt_log_id AS string)                                          AS rpt_log_id,
    CAST(fi_va.period_val AS string)                                          AS period_val,
    CAST(fo_in_re.rpt_code AS string)                                         AS rpt_code,
    CAST(fi_st.row_path AS string)                                            AS asset_group_nm,
    CAST(TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) AS decimal(23,2)) AS closing_balance_val,
    CAST(fi_va.src_stm_code AS string)                                        AS src_stm_code
FROM fi_va
INNER JOIN fi_st
    ON  fi_st.fir_structure_id = fi_va.fir_structure_id
INNER JOIN fo_in_re
    ON  fo_in_re.fir_id = fi_st.fir_id
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = fi_va.submission_dt
LEFT JOIN cd_dt_di rp_cd_dt_di
    ON  rp_cd_dt_di.cdr_dt = fi_va.rpt_day
WHERE fo_in_re.rpt_code = '59WJB'
    AND fo_in_re.sheet_nm = 'III'
    AND fi_st.column_path = 'Số dư cuối kỳ > Giá trị'
    AND fi_va.total_row_ind = 0
    AND fi_va.section_echo_ind = 0
    AND fi_va.band_overflow_ind = 0
    AND fi_va.static_copy_ind = 0
    AND fi_va.rpt_marker_ind = 0
