/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_tthc_ap_document
* Program name: Fact TTHC AP Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH apd AS (
    SELECT d.*
    FROM {{ ref('atm_tthc_ap_document') }}_hstr d
    INNER JOIN {{ ref('atm_cl_value') }} auth
        ON  d.processing_authority_code = auth.cl_code
        AND auth.schema_code            = 'TTHC.PROCESSING_AUTHORITY'
        AND auth.cl_nm                  = 'Ban Quản lý chào bán chứng khoán'
        AND auth.ds_rcrd_st             = 'ACTIVE'
        AND auth.src_stm_code           = 'TTHC_CLASSIFICATION_VALUE'
    WHERE d.ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND d.ds_rcrd_st = 'ACTIVE'
),

enriched AS (
    SELECT
        apd.ap_document_applicant_id,
        apd.ap_document_applicant_code,
        apd.ap_document_code,
        apd.securities_code,
        apd.submission_tms,
        CASE
            WHEN st.cl_nm IN ('Mới tạo', 'Chờ VP tiếp nhận', 'Hồ sơ hợp lệ', 'Hồ Sơ Chưa Đầy Đủ')
                THEN 'Hồ sơ đăng ký'
            WHEN st.cl_nm IN (
                'Chờ NV xử lý', 'Chờ NV xử lý hồ sơ', 'Chờ NV xử lý bổ sung',
                'Chờ VP tiếp nhận bổ sung', 'VP đã tiếp nhận, chờ trả KQ', 'Chờ LĐCM Phân Công',
                'Yêu cầu bổ sung', 'CBNV Đợi Trình Duyệt Yêu Cầu Bổ Sung',
                'Chờ LĐCM Phê Duyệt Yêu Cầu Bổ Sung', 'LĐCM Phê duyệt YCBS',
                'Chờ LĐCM Ký QĐ Yêu Cầu Bổ Sung', 'LĐCM Đã Ký QĐ Yêu Cầu Bổ Sung',
                'Chờ LĐUB Phê Duyệt Yêu Cầu Bổ Sung', 'LĐUB Đồng Ý Phê Duyệt YCBS',
                'LĐCM Từ Chối Phê Duyệt Yêu Cầu Bổ Sung', 'CBNV Chờ Trả Yêu Cầu Bổ Sung Hồ Sơ Về BPMC',
                'BPMC Chờ Trả Yêu Cầu Hoàn Thiện Hồ Sơ Về CN/TC', 'Gửi Thông Báo Yêu Cầu Bổ Sung',
                'CBNV Đợi Trình Duyệt Yêu Cầu Từ Chối Giải Quyết',
                'Chờ LĐCM Phê Duyệt y.c Từ Chối Giải Quyết', 'Chờ LĐUB Phê Duyệt Yêu Cầu Từ Chối',
                'CBNV Đợi Trình Duyệt Kết Quả', 'Chờ LĐCM Phê Duyệt Kết Quả Xử Lý',
                'Chờ LĐCM Ký Kết Quả Chấp Thuận', 'Chờ LĐUB Phê Duyệt Kết Quả',
                'LĐCM Từ Chối Phê Duyệt Kết Quả', 'LĐUB Từ chối duyệt kết quả',
                'CBNV Đợi Trình Duyệt Yêu Cầu Dừng Xử Lý', 'LĐCM T.Chối P.Duyệt YC Dừng Xử Lý',
                'LĐUB Từ Chối Thông Báo TTXM'
            ) THEN 'Hồ sơ đang xử lý'
            WHEN st.cl_nm IN (
                'Đã phê duyệt - Chuyển trả VP', 'CBNV Chờ Trả Kết Quả Chấp Thuận Về BPMC',
                'LĐCM Đã Ký Kết Quả Chấp Thuận', 'Đã Cấp Phép'
            ) THEN 'Hồ sơ đã được chấp thuận'
            WHEN st.cl_nm IN (
                'Gửi Thông Báo Từ Chối Giải Quyết', 'Gửi Thông Báo Dừng Xử Lý',
                'Hủy Hồ Sơ', 'Trả lại', 'Đã trả lại', 'Hồ Sơ Bị Từ Chối Giải Quyết',
                'Yêu cầu rút hồ sơ', 'VP Từ Chối Tiếp Nhận Hồ sơ'
            ) THEN 'Hồ sơ bị từ chối'
            WHEN st.cl_nm = 'Hồ sơ quá hạn bổ sung' THEN 'Hồ sơ quá hạn bổ sung'
            ELSE 'Chưa xác định'
        END                 AS document_status_group_nm,
        tp.cl_nm            AS offering_method_nm
    FROM apd
    INNER JOIN {{ ref('atm_cl_value') }} st
        ON  apd.processing_status_code = st.cl_code
        AND st.SCHEMA_CODE             = 'TTHC.PROCESSING_STATUS'
        AND st.ds_rcrd_st              = 'ACTIVE'
        AND st.src_stm_code            = 'TTHC_CLASSIFICATION_VALUE'
    INNER JOIN {{ ref('atm_cl_value') }} tp
        ON  apd.document_tp_code       = tp.cl_code
        AND tp.SCHEMA_CODE             = 'TTHC.DOCUMENT_TYPE'
        AND tp.ds_rcrd_st              = 'ACTIVE'
        AND tp.src_stm_code            = 'TTHC_CLASSIFICATION_VALUE'
)

SELECT
    CAST(e.ap_document_code         AS STRING) AS ap_document_code,
    CAST(app.display_nm             AS STRING) AS ap_document_applicant_nm,
    CAST(e.securities_code          AS STRING) AS securities_code,
    CAST(e.offering_method_nm       AS STRING) AS offering_method_nm,
    CAST(e.submission_tms           AS DATE)   AS submission_dt,
    CAST(e.document_status_group_nm AS STRING) AS document_status_group_nm
FROM enriched e
LEFT JOIN {{ ref('atm_tthc_ap_document_applicant') }}_hstr app
    ON  e.ap_document_applicant_id = app.ap_document_applicant_id
    AND app.ds_snpst_dt            = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND app.ds_rcrd_st             = 'ACTIVE'
    AND app.src_stm_code           = 'TTHC_AP_DOCUMENT_APPLICANT'
