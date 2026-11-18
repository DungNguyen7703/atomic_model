/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_tthc_ap_document_stat
* Program name: Fact TTHC AP Document Statistic
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

{{ config(
    materialized         = 'incremental_rebase',
    incremental_strategy = 'snapshot',
    file_format          = 'iceberg',
    partition_by         = ['ds_snpst_dt']
) }}

WITH a AS (
    SELECT d.*
    FROM ods.uat_TTHC_ods.ap_document d
    INNER JOIN ods.uat_TTHC_ods.CLASSIFICATION_VALUE b
        ON  d.processing_authority_code = b.CLASSIFICATION_CODE
        AND b.SCHEMA_CODE               = 'TTHC.PROCESSING_AUTHORITY'
        AND b.CLASSIFICATION_NAME       = 'Ban Quản lý chào bán chứng khoán'
        AND b.ds_snpst_dt               = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    WHERE d.ds_snpst_dt    = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

b AS (
    SELECT
        a.ap_document_id,
        a.submission_tms,
        a.document_tp_code,
        b.CLASSIFICATION_NAME
    FROM a
    INNER JOIN ods.uat_TTHC_ods.CLASSIFICATION_VALUE b
        ON  a.processing_status_code = b.CLASSIFICATION_CODE
        AND b.SCHEMA_CODE            = 'TTHC.PROCESSING_STATUS'
        AND b.ds_snpst_dt            = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    WHERE b.CLASSIFICATION_NAME IN (
        'Mới tạo', 'Chờ VP tiếp nhận', 'Hồ sơ hợp lệ', 'Hồ Sơ Chưa Đầy Đủ',
        'Đã phê duyệt - Chuyển trả VP', 'CBNV Chờ Trả Kết Quả Chấp Thuận Về BPMC',
        'LĐCM Đã Ký Kết Quả Chấp Thuận', 'Đã Cấp Phép',
        'Gửi Thông Báo Từ Chối Giải Quyết', 'Gửi Thông Báo Dừng Xử Lý', 'Hủy Hồ Sơ',
        'Trả lại', 'Đã trả lại', 'Hồ Sơ Bị Từ Chối Giải Quyết', 'Yêu cầu rút hồ sơ',
        'Hồ sơ quá hạn bổ sung', 'VP Từ Chối Tiếp Nhận Hồ sơ',
        'Chờ NV xử lý', 'Chờ NV xử lý hồ sơ', 'Chờ NV xử lý bổ sung', 'Chờ VP tiếp nhận bổ sung',
        'VP đã tiếp nhận, chờ trả KQ', 'Chờ LĐCM Phân Công', 'Yêu cầu bổ sung',
        'CBNV Đợi Trình Duyệt Yêu Cầu Bổ Sung', 'Chờ LĐCM Phê Duyệt Yêu Cầu Bổ Sung',
        'LĐCM Phê duyệt YCBS', 'Chờ LĐCM Ký QĐ Yêu Cầu Bổ Sung', 'LĐCM Đã Ký QĐ Yêu Cầu Bổ Sung',
        'Chờ LĐUB Phê Duyệt Yêu Cầu Bổ Sung', 'LĐUB Đồng Ý Phê Duyệt YCBS',
        'LĐCM Từ Chối Phê Duyệt Yêu Cầu Bổ Sung', 'CBNV Chờ Trả Yêu Cầu Bổ Sung Hồ Sơ Về BPMC',
        'BPMC Chờ Trả Yêu Cầu Hoàn Thiện Hồ Sơ Về CN/TC', 'Gửi Thông Báo Yêu Cầu Bổ Sung',
        'CBNV Đợi Trình Duyệt Yêu Cầu Từ Chối Giải Quyết', 'Chờ LĐCM Phê Duyệt y.c Từ Chối Giải Quyết',
        'Chờ LĐUB Phê Duyệt Yêu Cầu Từ Chối', 'CBNV Đợi Trình Duyệt Kết Quả',
        'Chờ LĐCM Phê Duyệt Kết Quả Xử Lý', 'Chờ LĐCM Ký Kết Quả Chấp Thuận',
        'Chờ LĐUB Phê Duyệt Kết Quả', 'LĐCM Từ Chối Phê Duyệt Kết Quả', 'LĐUB Từ chối duyệt kết quả',
        'CBNV Đợi Trình Duyệt Yêu Cầu Dừng Xử Lý', 'LĐCM T.Chối P.Duyệt YC Dừng Xử Lý',
        'LĐUB Từ Chối Thông Báo TTXM'
    )
),

c AS (
    SELECT
        b.ap_document_id,
        b.submission_tms,
        CASE
            WHEN b.CLASSIFICATION_NAME IN (
                'Mới tạo', 'Chờ VP tiếp nhận', 'Hồ sơ hợp lệ', 'Hồ Sơ Chưa Đầy Đủ'
            ) THEN 'Hồ sơ đăng ký'
            WHEN b.CLASSIFICATION_NAME IN (
                'Đã phê duyệt - Chuyển trả VP', 'CBNV Chờ Trả Kết Quả Chấp Thuận Về BPMC',
                'LĐCM Đã Ký Kết Quả Chấp Thuận', 'Đã Cấp Phép'
            ) THEN 'Hồ sơ đã được chấp thuận'
            WHEN b.CLASSIFICATION_NAME IN (
                'Gửi Thông Báo Từ Chối Giải Quyết', 'Gửi Thông Báo Dừng Xử Lý', 'Hủy Hồ Sơ',
                'Trả lại', 'Đã trả lại', 'Hồ Sơ Bị Từ Chối Giải Quyết', 'Yêu cầu rút hồ sơ',
                'Hồ sơ quá hạn bổ sung', 'VP Từ Chối Tiếp Nhận Hồ sơ'
            ) THEN 'Hồ sơ bị từ chối'
            WHEN b.CLASSIFICATION_NAME IN (
                'Chờ NV xử lý', 'Chờ NV xử lý hồ sơ', 'Chờ NV xử lý bổ sung', 'Chờ VP tiếp nhận bổ sung',
                'VP đã tiếp nhận, chờ trả KQ', 'Chờ LĐCM Phân Công', 'Yêu cầu bổ sung',
                'CBNV Đợi Trình Duyệt Yêu Cầu Bổ Sung', 'Chờ LĐCM Phê Duyệt Yêu Cầu Bổ Sung',
                'LĐCM Phê duyệt YCBS', 'Chờ LĐCM Ký QĐ Yêu Cầu Bổ Sung', 'LĐCM Đã Ký QĐ Yêu Cầu Bổ Sung',
                'Chờ LĐUB Phê Duyệt Yêu Cầu Bổ Sung', 'LĐUB Đồng Ý Phê Duyệt YCBS',
                'LĐCM Từ Chối Phê Duyệt Yêu Cầu Bổ Sung', 'CBNV Chờ Trả Yêu Cầu Bổ Sung Hồ Sơ Về BPMC',
                'BPMC Chờ Trả Yêu Cầu Hoàn Thiện Hồ Sơ Về CN/TC', 'Gửi Thông Báo Yêu Cầu Bổ Sung',
                'CBNV Đợi Trình Duyệt Yêu Cầu Từ Chối Giải Quyết', 'Chờ LĐCM Phê Duyệt y.c Từ Chối Giải Quyết',
                'Chờ LĐUB Phê Duyệt Yêu Cầu Từ Chối', 'CBNV Đợi Trình Duyệt Kết Quả',
                'Chờ LĐCM Phê Duyệt Kết Quả Xử Lý', 'Chờ LĐCM Ký Kết Quả Chấp Thuận',
                'Chờ LĐUB Phê Duyệt Kết Quả', 'LĐCM Từ Chối Phê Duyệt Kết Quả', 'LĐUB Từ chối duyệt kết quả',
                'CBNV Đợi Trình Duyệt Yêu Cầu Dừng Xử Lý', 'LĐCM T.Chối P.Duyệt YC Dừng Xử Lý',
                'LĐUB Từ Chối Thông Báo TTXM'
            ) THEN 'Hồ sơ đang xử lý'
            ELSE 'Chưa xác định'
        END                   AS nhom_trang_thai,
        c.CLASSIFICATION_NAME AS offering_method_nm
    FROM b
    INNER JOIN ods.uat_TTHC_ods.CLASSIFICATION_VALUE c
        ON  b.document_tp_code = c.CLASSIFICATION_CODE
        AND c.SCHEMA_CODE      = 'TTHC.DOCUMENT_TYPE'
        AND c.ds_snpst_dt      = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    CAST(offering_method_nm                                                                     AS STRING) AS offering_method_nm,
    CAST(submission_tms                                                                         AS DATE)   AS submission_tms,
    CAST(COUNT(CASE WHEN nhom_trang_thai = 'Hồ sơ đăng ký'            THEN 1 END)              AS INT)    AS registered_document_cnt,
    CAST(COUNT(CASE WHEN nhom_trang_thai = 'Hồ sơ đang xử lý'         THEN 1 END)              AS INT)    AS processing_document_cnt,
    CAST(COUNT(CASE WHEN nhom_trang_thai = 'Hồ sơ đã được chấp thuận' THEN 1 END)              AS INT)    AS approved_document_cnt,
    CAST(COUNT(CASE WHEN nhom_trang_thai = 'Hồ sơ bị từ chối'         THEN 1 END)              AS INT)    AS rejected_document_cnt,
    CAST(COUNT(*)                                                                               AS INT)    AS total_document_cnt
FROM c
GROUP BY offering_method_nm, submission_tms
