/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_report_structure_dim
* Program name: Foreign Investor Report Structure Dimension
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_fir_structure va atm_foreign_investor_report duoc materialize
*   theo strategy SCD2 (khong co bang phu _hstr va khong co cot
*   ds_snpst_dt). Ban ghi hien hanh: ds_rcrd_st = 'ACTIVE' AND
*   ds_rcrd_end_dt = to_date('2400-01-01').
* - BK = fir_structure_code (SHEET_ID || INDICATOR_UID); structure_code
*   (INDICATOR_UID) chi duy nhat trong 1 sheet nen khong dung lam khoa.
* - report_type_nm: Atomic fir_* khong co thuoc tinh loai bao cao nen
*   suy ra theo danh sach bao cao bat thuong cua BA (xem O_NDTNN_38).
*--------------------------------------------------------------------*
*/

WITH fi_st AS (
    SELECT
        fir_id,
        fir_structure_code,
        structure_code,
        section_id,
        section_tp_code,
        row_index,
        column_index,
        row_path,
        column_path,
        data_tp,
        dynamic_ind,
        total_row_ind,
        ordinal_column_ind,
        src_stm_code
    FROM {{ ref('atm_fir_structure') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FIMS_FIR_STRUCTURE'
),

fo_in_re AS (
    SELECT
        fir_id,
        rpt_code,
        rpt_nm,
        legal_basis,
        sheet_code,
        sheet_nm
    FROM {{ ref('atm_foreign_investor_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FIMS_FOREIGN_INVESTOR_REPORT'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FIMS_FIR_STRUCTURE', 'fi_st.fir_structure_code') }} AS string) AS foreign_investor_report_structure_dim_id,
    CAST(fi_st.fir_structure_code AS string)                                                       AS fir_structure_code,
    CAST(fi_st.structure_code AS string)                                                           AS structure_code,
    CAST(fo_in_re.rpt_code AS string)                                                              AS rpt_code,
    CAST(fo_in_re.rpt_nm AS string)                                                                AS rpt_nm,
    CAST(fo_in_re.legal_basis AS string)                                                           AS legal_basis,
    CAST(
        CASE WHEN fo_in_re.rpt_nm IN (
                'Giấy chỉ định/ủy quyền thực hiện công bố thông tin của nhà đầu tư nước ngoài hoặc nhóm các nhà đầu tư nước ngoài có liên quan',
                'Báo cáo về sở hữu của nhóm nhà đầu tư nước ngoài có liên quan là cổ đông lớn, nhà đầu tư nắm giữ từ 5% trở lên cổ phiếu/chứng chỉ quỹ đóng (PLIX- TT96/2020/TT-BTC)',
                'Báo cáo thay đổi về sở hữu của nhóm nhà đầu tư nước ngoài có liên quan là cổ động lớn, nhà đầu tư nắm giữ từ 5% trở lên cổ phiếu/ chứng chỉ quỹ đóng (PLX- TT96/2020/TT-BTC)',
                'Báo cáo về ngày trở thành/không còn là cổ đông lớn, nhà đầu tư nắm giữ từ 5% trở lên cổ phiếu/chứng chỉ quỹ đóng',
                'Báo cáo về thay đổi sở hữu của cổ đông lớn, nhà đầu tư nắm giữ từ 5% trở lên cổ phiếu/chứng chỉ quỹ đóng',
                'Cập nhật thay đổi về danh sách nhóm NĐT NN có liên quan (PL II- TT51/2021/TT-BTC)',
                'Thông báo giao dịch cổ phiếu/chứng chỉ quỹ/chứng quyền có bảo đảm của người nội bộ và người có liên quan của người nội bộ',
                'Thông báo giao dịch trái phiếu chuyển đổi, quyền mua cổ phiếu/chứng chỉ quỹ, quyền mua trái phiếu chuyển đổi của người nội bộ và người có liên quan của người nội bộ',
                'Báo cáo kết quả giao dịch cổ phiếu/chứng chỉ quỹ/chứng quyền có bảo đảm của người nội bộ và người có liên quan của người nội bộ',
                'Báo cáo kết quả giao dịch trái phiếu chuyển đổi, quyền mua cổ phiếu/chứng chỉ quỹ, quyền mua trái phiếu chuyển đổi của người nội bộ và người có liên quan của người nội bộ'
            ) THEN 'Bất thường' ELSE 'Định kỳ' END
    AS string)                                                                                     AS report_type_nm,
    CAST(fo_in_re.sheet_code AS string)                                                            AS sheet_code,
    CAST(fo_in_re.sheet_nm AS string)                                                              AS sheet_nm,
    CAST(fi_st.section_id AS string)                                                               AS section_id,
    CAST(fi_st.section_tp_code AS string)                                                          AS section_tp_code,
    CAST(fi_st.row_index AS int)                                                                   AS row_index,
    CAST(fi_st.column_index AS int)                                                                AS column_index,
    CAST(fi_st.row_path AS string)                                                                 AS row_path,
    CAST(fi_st.column_path AS string)                                                              AS column_path,
    CAST(fi_st.data_tp AS string)                                                                  AS data_tp,
    CAST(fi_st.dynamic_ind AS int)                                                                 AS dynamic_ind,
    CAST(fi_st.total_row_ind AS int)                                                               AS total_row_ind,
    CAST(fi_st.ordinal_column_ind AS int)                                                          AS ordinal_column_ind,
    CAST(fi_st.src_stm_code AS string)                                                             AS src_stm_code
FROM fi_st
LEFT JOIN fo_in_re
    ON  fo_in_re.fir_id = fi_st.fir_id
