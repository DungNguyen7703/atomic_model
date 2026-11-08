/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_investor_portfolio_report_snpst
* Program name: Fact Foreign Investor Portfolio Report Snapshot
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		nghia.le			Dong bo LLD 2026-10-21: sua foreign_bank_branch_ind = CASE WHEN rpt_code = '59WJB' THEN 1 ELSE 0 END
*									(BA STT 6 Ma 50: chi nhanh NH nuoc ngoai tai VN chi lay bao cao ma 59WJB, sheet II), thay gia
*									dinh cu 'A-To chuc AND loai hinh LIKE %Ngan hang%' (O_NDTNN_46).
* 2026-10-17		nghia.le			Bo Foreign Investor Reporting Entity Dimension khoi fact (theo DTM moi + bang mart thuc te khong con cot
*									foreign_investor_reporting_entity_dim_id): bo cot FK, CTE fi_re_en_di va LEFT JOIN tuong ung.
* 2026-10-16		nghia.le			Đồng bộ DTM BA 2026-10-16: thêm foreign_bank_branch_ind (K_NDTNN_265, BA Mã 47 — GIẢ ĐỊNH 'A-Tổ chức' + loại hình
*									chứa 'Ngân hàng', tập con của non_fund_org_ind, O_NDTNN_46) và transaction_cd (MSGD 6 ký tự cuối in hoa của cột
*									'Mã số giao dịch chứng khoán', BA Mã 74/75, O_NDTNN_47 — column_path chờ BA xác nhận)
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Pivot 1 dong bao cao: GROUP BY rpt_log_id, section_id, dynamic_row_order
*   tren fir_value x fir_structure x foreign_investor_report, bao cao 59WJB/BZ5X4
*   sheet 'II' (PLIII-TT51). Doc dung theo LLD
*   DTM_NDTNN_fct_foreign_investor_portfolio_report_snpst.csv, khong loc etl_date.
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
        src_stm_code
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


po_re AS (
    SELECT
        fi_va.rpt_log_id,
        fi_st.section_id,
        fi_va.dynamic_row_order,
        MAX(fi_va.submission_dt)                                   AS submission_dt,
        MAX(fi_va.period_val)                                      AS period_val,
        MAX(fo_in_re.rpt_code)                                     AS rpt_code,
        MAX(fi_st.row_path)                                        AS investor_group_nm,
        MAX(CASE WHEN fi_st.column_path = 'Quốc tịch' THEN fi_va.val_raw END) AS nationality_nm,
        MAX(CASE WHEN fi_st.column_path = 'Loại hình đối với tổ chức' THEN fi_va.val_raw END) AS investor_type_nm,
        MAX(CASE WHEN fi_st.column_path = 'Tên khách hàng' THEN fi_va.val_raw END) AS investor_nm,
        SUBSTR(UPPER(TRIM(MAX(CASE WHEN fi_st.column_path = 'Mã số giao dịch chứng khoán' THEN fi_va.val_raw END))), -6) AS transaction_cd,
        MAX(CASE WHEN fi_st.column_path = 'Tín phiếu > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS bill_val,
        SUM(CASE WHEN fi_st.column_path IN (
            'Trái phiếu > Thời gian còn lại tới khi đáo hạn > Ngắn hạn > Dưới 12 tháng > Giá trị',
            'Trái phiếu > Thời gian còn lại tới khi đáo hạn > Trung hạn > Từ 12 tháng đến 24 tháng > Giá trị',
            'Trái phiếu > Thời gian còn lại tới khi đáo hạn > Dài hạn > Trên 24 tháng > Giá trị'
        ) THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS bond_val,
        MAX(CASE WHEN fi_st.column_path = 'Cổ phiếu/Chứng chỉ quỹ > Cổ phiếu niêm yết, chứng chỉ quỹ niêm yết > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS listed_equity_fund_val,
        MAX(CASE WHEN fi_st.column_path = 'Cổ phiếu/Chứng chỉ quỹ > Cổ phiếu công ty đại chúng đăng ký giao dịch (upcom) > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS upcom_equity_val,
        MAX(CASE WHEN fi_st.column_path = 'Cổ phiếu/Chứng chỉ quỹ > Giá trị vốn góp mua cổ phần, quỹ thành viên và chứng khoán khác > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS capital_contribution_val,
        MAX(CASE WHEN fi_st.column_path = 'Tiền và các khoản tương đương tiền (chứng chỉ tiền gửi...) > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS cash_equivalent_val,
        MAX(CASE WHEN fi_st.column_path = 'Tổng giá trị danh mục > Giá trị' THEN TRY_CAST(REGEXP_REPLACE(fi_va.val_raw, '^''', '') AS DECIMAL(38,10)) END) AS total_portfolio_val,
        MAX(fi_va.src_stm_code)                                    AS src_stm_code
    FROM fi_va
    INNER JOIN fi_st
        ON  fi_st.fir_structure_id = fi_va.fir_structure_id
    INNER JOIN fo_in_re
        ON  fo_in_re.fir_id = fi_st.fir_id
    WHERE fo_in_re.rpt_code IN ('59WJB', 'BZ5X4')
        AND fo_in_re.sheet_nm = 'II'
        AND fi_va.total_row_ind = 0
        AND fi_va.section_echo_ind = 0
        AND fi_va.band_overflow_ind = 0
        AND fi_va.static_copy_ind = 0
        AND fi_va.rpt_marker_ind = 0
    GROUP BY fi_va.rpt_log_id, fi_st.section_id, fi_va.dynamic_row_order
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                    AS snpst_dt_dim_id,
    CAST(po_re.rpt_log_id AS string)                                          AS rpt_log_id,
    CAST(po_re.section_id AS string)                                          AS section_id,
    CAST(po_re.dynamic_row_order AS int)                                      AS dynamic_row_order,
    CAST(po_re.period_val AS string)                                          AS period_val,
    CAST(po_re.rpt_code AS string)                                            AS rpt_code,
    CAST(po_re.investor_group_nm AS string)                                   AS investor_group_nm,
    CAST(po_re.nationality_nm AS string)                                      AS nationality_nm,
    CAST(po_re.investor_type_nm AS string)                                    AS investor_type_nm,
    CAST(po_re.investor_nm AS string)                                         AS investor_nm,
    CAST(po_re.bill_val AS decimal(23,2))                                     AS bill_val,
    CAST(po_re.bond_val AS decimal(23,2))                                     AS bond_val,
    CAST(po_re.listed_equity_fund_val AS decimal(23,2))                       AS listed_equity_fund_val,
    CAST(po_re.upcom_equity_val AS decimal(23,2))                             AS upcom_equity_val,
    CAST(po_re.capital_contribution_val AS decimal(23,2))                     AS capital_contribution_val,
    CAST(po_re.cash_equivalent_val AS decimal(23,2))                          AS cash_equivalent_val,
    CAST(po_re.total_portfolio_val AS decimal(23,2))                          AS total_portfolio_val,
    CAST(CASE WHEN po_re.investor_group_nm = 'B-Cá nhân' THEN 1 ELSE 0 END AS int) AS individual_ind,
    CAST(CASE WHEN po_re.investor_group_nm = 'A-Tổ chức'
                   AND po_re.investor_type_nm LIKE '%Quỹ%'
                   AND po_re.investor_type_nm NOT LIKE '%Không phải quỹ%'
              THEN 1 ELSE 0 END AS int)                                       AS fund_ind,
    CAST(CASE WHEN po_re.investor_group_nm = 'A-Tổ chức'
                   AND (po_re.investor_type_nm LIKE '%Công ty%'
                        OR po_re.investor_type_nm LIKE '%Ngân hàng%'
                        OR po_re.investor_type_nm LIKE '%Tổ chức%'
                        OR po_re.investor_type_nm LIKE '%Không phải quỹ%'
                        OR po_re.investor_type_nm LIKE '%Các loại khác%')
              THEN 1 ELSE 0 END AS int)                                       AS non_fund_org_ind,
    CAST(CASE WHEN po_re.rpt_code = '59WJB'
              THEN 1 ELSE 0 END AS int)                                       AS foreign_bank_branch_ind,
    CAST(po_re.transaction_cd AS string)                                      AS transaction_cd,
    CAST(po_re.src_stm_code AS string)                                        AS src_stm_code
FROM po_re
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = po_re.submission_dt
