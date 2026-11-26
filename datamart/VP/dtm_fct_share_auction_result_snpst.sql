/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_share_auction_result_snpst
* Program name: Fact Share Auction Result Snapshot
* Created by: huy.pham
* Created date: 2026-11-05
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-05      huy.pham        [MOI, theo LLD] Fact snapshot ket qua dau gia co phan
*                                 theo thang bao cao. Grain = 1 dong bieu mau HNX05 (HNX)
*                                 hoac HSX03 (HOSE), nguon nop ICP, da nop. Pivot
*                                 column_path thanh: auction_tp_nm, domestic_winning_val,
*                                 foreign_winning_val. snpst_dt = LAST_DAY thang bao cao.
*                                 PK hash(snpst_dt_dim_id|rpt_code|row_nbr|src_stm_code).
*                                 ds_snpst_dt cung cua BA -> ds_rcrd_st = 'ACTIVE'.
*                                 O_VP_55: gia tri thieu/khong phai so → 0 (TRY_CAST).
* 2026-11-16      claude          [O_VP_83] Mo rong column_path filter them 3 nhan cot KL.
*                                 Them 3 cot: registered_share_quantity,
*                                 domestic_winning_share_quantity,
*                                 foreign_winning_share_quantity.
*--------------------------------------------------------------------*
*/

WITH rpt AS (
    SELECT
        src_stm_code,
        rpt_code,
        rpt_year,
        rpt_month,
        row_index,
        TRIM(REGEXP_REPLACE(column_path, '\\s+', ' ')) AS col_path_norm,
        cell_val
    FROM uat_atm.internal_statistical_report
    WHERE src_stm_code              = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND rpt_code                IN ('HNX05', 'HSX03')
        AND sheet_nm                = 'sheet 1'
        AND rpt_submission_stm_code = 'ICP'
        AND submission_status_code  IN ('SUBMITTED', 'LATE_SUBMITTED')
        AND (
            (rpt_code = 'HNX05' AND TRIM(REGEXP_REPLACE(column_path, '\\s+', ' ')) IN (
                'LOẠI HÌNH ĐẤU GIÁ',
                'GIÁ TRỊ CP TRÚNG GIÁ > NĐT TRONG NƯỚC (VND)',
                'GIÁ TRỊ CP TRÚNG GIÁ > NĐT NƯỚC NGOÀI (VND)',
                'SỐ CP ĐĂNG KÝ CHÀO BÁN',
                'SỐ CP TRÚNG GIÁ > NĐT TRONG NƯỚC',
                'SỐ CP TRÚNG GIÁ > NĐT NƯỚC NGOÀI'
            ))
            OR
            (rpt_code = 'HSX03' AND TRIM(REGEXP_REPLACE(column_path, '\\s+', ' ')) IN (
                'LOẠI HÌNH ĐẤU GIÁ',
                'GIÁ TRỊ CP TRÚNG GIÁ(VND) > NĐT TRONG NƯỚC',
                'GIÁ TRỊ CP TRÚNG GIÁ(VND) > NĐT NƯỚC NGOÀI',
                'SỐ CP ĐĂNG KÝ CHÀO BÁN',
                'SỐ CP TRÚNG GIÁ(CHỨNG KHOÁN) > NĐT TRONG NƯỚC',
                'SỐ CP TRÚNG GIÁ(CHỨNG KHOÁN) > NĐT NƯỚC NGOÀI'
            ))
        )
        --AND LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)) <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st              = 'ACTIVE'
),

rpt_pvt AS (
    SELECT
        src_stm_code,
        rpt_code,
        rpt_year,
        rpt_month,
        row_index,
        LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1))                                               AS snpst_dt,
        TRIM(MAX(CASE WHEN col_path_norm = 'LOẠI HÌNH ĐẤU GIÁ'
                      THEN cell_val END))                                                          AS auction_tp_nm_raw,
        CAST(COALESCE(TRY_CAST(MAX(CASE WHEN col_path_norm IN (
                'GIÁ TRỊ CP TRÚNG GIÁ > NĐT TRONG NƯỚC (VND)',
                'GIÁ TRỊ CP TRÚNG GIÁ(VND) > NĐT TRONG NƯỚC'
            ) THEN cell_val END) AS DECIMAL(38, 10)), 0) AS DECIMAL(23, 2))                       AS domestic_winning_val,
        CAST(COALESCE(TRY_CAST(MAX(CASE WHEN col_path_norm IN (
                'GIÁ TRỊ CP TRÚNG GIÁ > NĐT NƯỚC NGOÀI (VND)',
                'GIÁ TRỊ CP TRÚNG GIÁ(VND) > NĐT NƯỚC NGOÀI'
            ) THEN cell_val END) AS DECIMAL(38, 10)), 0) AS DECIMAL(23, 2))                       AS foreign_winning_val,
        CAST(COALESCE(TRY_CAST(MAX(CASE WHEN col_path_norm IN (
                'SỐ CP ĐĂNG KÝ CHÀO BÁN'
            ) THEN cell_val END) AS DECIMAL(38, 10)), 0) AS BIGINT)                               AS registered_share_quantity,
        CAST(COALESCE(TRY_CAST(MAX(CASE WHEN col_path_norm IN (
                'SỐ CP TRÚNG GIÁ > NĐT TRONG NƯỚC',
                'SỐ CP TRÚNG GIÁ(CHỨNG KHOÁN) > NĐT TRONG NƯỚC'
            ) THEN cell_val END) AS DECIMAL(38, 10)), 0) AS BIGINT)                               AS domestic_winning_share_quantity,
        CAST(COALESCE(TRY_CAST(MAX(CASE WHEN col_path_norm IN (
                'SỐ CP TRÚNG GIÁ > NĐT NƯỚC NGOÀI',
                'SỐ CP TRÚNG GIÁ(CHỨNG KHOÁN) > NĐT NƯỚC NGOÀI'
            ) THEN cell_val END) AS DECIMAL(38, 10)), 0) AS BIGINT)                               AS foreign_winning_share_quantity
    FROM rpt
    GROUP BY src_stm_code, rpt_code, rpt_year, rpt_month, row_index
)

SELECT
    CAST({{ generate_surrogate_key(
        'ISS_INTERNAL_STATISTICAL_REPORT',
        "CONCAT(date_format(snpst_dt, 'yyyyMMdd'), '|', rpt_code, '|', CAST(row_index AS string), '|', src_stm_code)"
    ) }} AS string)                                                                                AS share_auction_result_snpst_id,
    CAST(date_format(snpst_dt, 'yyyyMMdd') AS string)                                             AS snpst_dt_dim_id,
    CAST(rpt_code AS string)                                                                       AS rpt_code,
    CAST(row_index AS int)                                                                         AS row_nbr,
    CAST(auction_tp_nm_raw AS string)                                                              AS auction_tp_nm,
    CAST(CASE
        WHEN auction_tp_nm_raw IN ('Cổ phần hóa')
            THEN 'IPO'
        WHEN auction_tp_nm_raw IN (
            'Bán phần vốn Nhà nước',
            'Bán phần vốn Nhà nước (chào bán cạnh tranh)',
            'Bán phần vốn Nhà nước (Đấu giá cả lô cổ phần)',
            'Đấu giá phần góp vốn',
            'Thoái phần vốn nhà nước',
            'Chào bán cạnh tranh cả lô cổ phần (Bán phần vốn Nhà nước)'
        )
            THEN 'Thoái vốn'
        WHEN auction_tp_nm_raw IN (
            'Bán phần vốn Nhà nước (Đấu giá quyền mua cổ phiếu)',
            'Bán CP ra công chúng của cổ đông lớn theo giấy phép UBCK',
            'Bán CP ra công chúng theo giấy phép UBCK'
        )
            THEN 'Phát hành ra công chúng / quyền mua'
        ELSE 'Khác'
    END AS string)                                                                                 AS auction_tp_group_nm,
    domestic_winning_val,
    foreign_winning_val,
    registered_share_quantity,
    domestic_winning_share_quantity,
    foreign_winning_share_quantity,
    CAST(src_stm_code AS string)                                                                   AS src_stm_code
FROM rpt_pvt
