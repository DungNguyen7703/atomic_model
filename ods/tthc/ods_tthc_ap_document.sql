-- /*
-- *--------------------------------------------------------------------*
-- * Program code: ods_tthc_ap_document
-- * Program name: ODS TTHC.AP_DOCUMENT
-- * Created by:
-- * Created date:
-- *--------------------------------------------------------------------*
-- * Modified management
-- * Date				User				Description
-- *
-- *--------------------------------------------------------------------*
-- */
-- WITH d AS (
--     SELECT *
--     FROM staging.uat_tthc_stg.document
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
-- ),
-- c AS (
--     SELECT *
--     FROM staging.uat_tthc_stg.contentitemindex
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--       AND LATEST = 1
--       AND PUBLISHED = 1
--       AND CONTENTTYPE = 'HoSoTTHC'
-- ), cte AS (
-- SELECT
--     c.contentitemid,
--     c.contenttype,
--     c.displaytext,
--     d.content
-- FROM d
-- INNER JOIN c
--     ON d.id = c.documentid

-- )

-- SELECT

--     -- =========================================================
--     -- Business columns
--     -- =========================================================

--     CAST(
--         cte.contentitemid AS STRING
--     ) AS ap_document_id,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.DoiTuongNopHoSo.ContentItemIds[0]'
--         ) AS STRING
--     ) AS ap_document_applicant_id,

--     CAST(
--         cte.displaytext AS STRING
--     ) AS document_title,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.MaChungKhoanMaChungQuyen.Text'
--         ) AS STRING
--     ) AS securities_code,

--     CAST(
--         COALESCE(
--             get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds[0]'),
--             get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds')
--         ) AS STRING
--     ) AS processing_status_code,


--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.CoQuanXuLy.ContentItemIds[0]'
--         ) AS STRING
--     ) AS processing_authority_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.LoaiHoSo.ContentItemIds[0]'
--         ) AS STRING
--     ) AS document_tp_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.LinhvucTTHC.ContentItemIds[0]'
--         ) AS STRING
--     ) AS domain_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.MucdoTTHC.ContentItemIds[0]'
--         ) AS STRING
--     ) AS priority_level_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.Kenhtiepnhanhoso.ContentItemIds[0]'
--         ) AS STRING
--     ) AS reception_channel_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.ThongTinHinhThucTraHoSo.Text'
--         ) AS INT
--     ) AS return_method_code,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.Canboxuly.UserIds[0]'
--         ) AS STRING
--     ) AS processing_officer_code,

--     -- =========================================================
--     -- Timestamp
--     -- =========================================================

--     CAST(
--         CASE
--             WHEN get_json_object(
--                 CONTENT,
--                 '$.HoSoTTHC.NgayGuiHoSo.Value'
--             ) LIKE '%Z'

--             OR get_json_object(
--                 CONTENT,
--                 '$.HoSoTTHC.NgayGuiHoSo.Value'
--             ) LIKE '%+00:00'

--             THEN from_utc_timestamp(
--                 to_timestamp(
--                     substring(
--                         get_json_object(
--                             CONTENT,
--                             '$.HoSoTTHC.NgayGuiHoSo.Value'
--                         ),
--                         1,
--                         19
--                     ),
--                     "yyyy-MM-dd'T'HH:mm:ss"
--                 ),
--                 'Asia/Ho_Chi_Minh'
--             )

--             ELSE to_timestamp(
--                 substring(
--                     get_json_object(
--                         CONTENT,
--                         '$.HoSoTTHC.NgayGuiHoSo.Value'
--                     ),
--                     1,
--                     19
--                 ),
--                 "yyyy-MM-dd'T'HH:mm:ss"
--             )
--         END AS TIMESTAMP
--     ) AS submission_tms,

--     CAST(
--         COALESCE(
--             get_json_object(
--                 content,
--                 '$.HoSoTTHC.NgayTiepNhan.Value'
--             ),
--             get_json_object(
--                 content,
--                 '$.HoSoTTHC.Ngaytiepnhan.Value'
--             )
--         ) AS TIMESTAMP
--     ) AS reception_tms,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.Thoihanxuly.Value'
--         ) AS TIMESTAMP
--     ) AS processing_deadline_tms,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.NgayTraKetQua.Value'
--         ) AS TIMESTAMP
--     ) AS result_return_tms,

--     -- DDL yêu cầu STRING
--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.Danoplephi.Value'
--         ) AS STRING
--     ) AS fee_paid_ind,

--     CAST(
--         get_json_object(
--             content,
--             '$.HoSoTTHC.LePhi.Value'
--         ) AS DECIMAL(23, 2)
--     ) AS fee_amt,

--     -- =========================================================
--     -- JSON columns
--     -- =========================================================

--     CAST(
--         COALESCE(
--             get_json_object(
--                 content,
--                 '$.ThanhPhanHoSo.ContentItems'
--             ),
--             '[]'
--         ) AS STRING
--     ) AS doc_component,

--     CAST(
--         COALESCE(
--             get_json_object(
--                 content,
--                 '$.Eform.ContentItems[0]'
--             ),
--             '{}'
--         ) AS STRING
--     ) AS eform_data

-- FROM cte
-- --------------code mới--------------------------

-- ==================== CÁCH 1: ContentItems[0] với COALESCE BagPart (đã comment) ====================
-- /*
-- *--------------------------------------------------------------------*
-- * Program code: ods_tthc_ap_document
-- * Program name: ODS TTHC.AP_DOCUMENT
-- * Created by:
-- * Created date:
-- *--------------------------------------------------------------------*
-- * Modified management
-- * Date				User				Description
-- *
-- *--------------------------------------------------------------------*
-- */
-- WITH d AS (
--     SELECT *
--     FROM staging.uat_tthc_stg.document
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
-- ),
-- c AS (
--     SELECT *
--     FROM staging.uat_tthc_stg.contentitemindex
--     WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
--       AND LATEST = 1
--       AND PUBLISHED = 1
--       AND CONTENTTYPE = 'HoSoTTHC'
-- ), cte AS (
-- SELECT
--     c.contentitemid,
--     c.contenttype,
--     c.displaytext,
--     d.content
-- FROM d
-- INNER JOIN c
--     ON d.id = c.documentid
-- )
--
-- SELECT
--
--     -- =========================================================
--     -- Business columns
--     -- =========================================================
--
--     CAST(cte.contentitemid AS STRING) AS AP_DOCUMENT_ID,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.DoiTuongNopHoSo.ContentItemIds[0]')
--     AS STRING) AS AP_DOCUMENT_APPLICANT_ID,
--
--     CAST(cte.displaytext AS STRING) AS DOCUMENT_TITLE,
--
--     CAST(
--         COALESCE(
--             CASE get_json_object(content, '$.Eform.ContentItems[0].ContentType')
--                 WHEN 'Eform6'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform6.MacophieucuaTCduocchaoban.Text')
--                 WHEN 'Eform11'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform11.MacophieuTCphathanh.Text')
--                 WHEN 'Eform12'
--                     THEN COALESCE(
--                         get_json_object(content, '$.Eform.ContentItems[0].Eform12.MacophieuTCphathanh.Text'),
--                         get_json_object(content, '$.Eform.ContentItems[0].Eform12.MacophieuTCduochoandoi.Text')
--                     )
--                 WHEN 'Eform13'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].BagPart.ContentItems[0].Eform13ToChucThamGiaHopNhat.MaCoPhieu.Text')
--                 WHEN 'Eform14'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform14.MaCoPhieu.Text')
--                 WHEN 'Eform15'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform15.Macophieu.Text')
--                 WHEN 'Eform23'
--                     THEN COALESCE(
--                         get_json_object(content, '$.Eform.ContentItems[0].Eform23.Macophieu.Text'),
--                         get_json_object(content, '$.Eform.ContentItems[0].Eform23.Machungkhoan.Text')
--                     )
--                 WHEN 'Eform23PL'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform23PL.Macophieu.Text')
--                 WHEN 'Eform35PL'
--                     THEN get_json_object(content, '$.Eform.ContentItems[0].Eform35PL.MaCoPhieu.Text')
--                 ELSE NULLIF(
--                     regexp_extract(
--                         get_json_object(content, '$.Eform.ContentItems[0]'),
--                         '"(?:Macophieu|MaCoPhieu|Machungkhoan|MaChungKhoan)"\\s*:\\s*\\{"Text"\\s*:\\s*"([^"]*)"',
--                         1
--                     ),
--                     ''
--                 )
--             END,
--             NULLIF(
--                 regexp_extract(
--                     get_json_object(content, '$.Eform.ContentItems[0].BagPart.ContentItems'),
--                     '"(?:Macophieu|MaCoPhieu|Machungkhoan|MaChungKhoan)"\\s*:\\s*\\{"Text"\\s*:\\s*"([^"]*)"',
--                     1
--                 ),
--                 ''
--             )
--         )
--     AS STRING) AS SECURITIES_CODE,
--
--     CAST(
--         COALESCE(
--             get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds[0]'),
--             get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds')
--         )
--
--     AS STRING) AS PROCESSING_STATUS_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.CoQuanXuLy.ContentItemIds[0]')
--     AS STRING) AS PROCESSING_AUTHORITY_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.LoaiHoSo.ContentItemIds[0]')
--     AS STRING) AS DOCUMENT_TYPE_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.LinhvucTTHC.ContentItemIds[0]')
--     AS STRING) AS DOMAIN_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.MucdoTTHC.ContentItemIds[0]')
--     AS STRING) AS PRIORITY_LEVEL_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.Kenhtiepnhanhoso.ContentItemIds[0]')
--     AS STRING) AS RECEPTION_CHANNEL_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.ThongTinHinhThucTraHoSo.Text')
--     AS INT) AS RETURN_METHOD_CODE,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.Canboxuly.UserIds[0]')
--     AS STRING) AS PROCESSING_OFFICER_CODE,
--
--     -- =========================================================
--     -- Timestamp
--     -- =========================================================
--
--     CAST(
--         CASE
--             WHEN get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
--             THEN CASE
--                     WHEN get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') LIKE '%Z'
--                       OR get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') LIKE '%+00:00'
--                     THEN from_utc_timestamp(
--                             to_timestamp(
--                                 substring(get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value'), 1, 19),
--                                 "yyyy-MM-dd'T'HH:mm:ss"
--                             ),
--                             'Asia/Ho_Chi_Minh'
--                          )
--                     ELSE to_timestamp(
--                             substring(get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value'), 1, 19),
--                             "yyyy-MM-dd'T'HH:mm:ss"
--                          )
--                  END
--             ELSE NULL
--         END
--     AS TIMESTAMP) AS SUBMISSION_TIMESTAMP,
--
--     CAST(
--         CASE
--             WHEN COALESCE(
--                     get_json_object(content, '$.HoSoTTHC.NgayTiepNhan.Value'),
--                     get_json_object(content, '$.HoSoTTHC.Ngaytiepnhan.Value')
--                  ) RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
--             THEN to_timestamp(
--                     substring(COALESCE(
--                         get_json_object(content, '$.HoSoTTHC.NgayTiepNhan.Value'),
--                         get_json_object(content, '$.HoSoTTHC.Ngaytiepnhan.Value')
--                     ), 1, 19),
--                     "yyyy-MM-dd'T'HH:mm:ss"
--                  )
--             ELSE NULL
--         END
--     AS TIMESTAMP) AS RECEPTION_TIMESTAMP,
--
--     CAST(
--         CASE
--             WHEN get_json_object(content, '$.HoSoTTHC.Thoihanxuly.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
--             THEN to_timestamp(
--                     substring(get_json_object(content, '$.HoSoTTHC.Thoihanxuly.Value'), 1, 19),
--                     "yyyy-MM-dd'T'HH:mm:ss"
--                  )
--             ELSE NULL
--         END
--     AS TIMESTAMP) AS PROCESSING_DEADLINE_TIMESTAMP,
--
--     CAST(
--         CASE
--             WHEN get_json_object(content, '$.HoSoTTHC.NgayTraKetQua.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
--             THEN to_timestamp(
--                     substring(get_json_object(content, '$.HoSoTTHC.NgayTraKetQua.Value'), 1, 19),
--                     "yyyy-MM-dd'T'HH:mm:ss"
--                  )
--             ELSE NULL
--         END
--     AS TIMESTAMP) AS RESULT_RETURN_TIMESTAMP,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.Danoplephi.Value')
--     AS STRING) AS FEE_PAID_INDICATOR,
--
--     CAST(
--         get_json_object(content, '$.HoSoTTHC.LePhi.Value')
--     AS DECIMAL(23, 2)) AS FEE_AMOUNT,
--
--     -- =========================================================
--     -- JSON columns
--     -- =========================================================
--
--     CAST(
--         COALESCE(get_json_object(content, '$.ThanhPhanHoSo.ContentItems'), '[]')
--     AS STRING) AS DOC_COMPONENT,
--
--     CAST(
--         COALESCE(get_json_object(content, '$.Eform.ContentItems[0]'), '{}')
--     AS STRING) AS EFORM_DATA
--
-- FROM cte

-- ==================== CÁCH 2: LATERAL VIEW explode (tương đương JSON_TABLE Oracle) ====================
-- Khác cách 1: unnest tất cả ContentItems[*], xử lý từng eform độc lập như Oracle
-- Cần thêm CTE eform_unnested + securities_agg để gộp lại 1 dòng/hồ sơ

/*
*--------------------------------------------------------------------*
* Program code: ods_tthc_ap_document
* Program name: ODS TTHC.AP_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/
WITH d AS (
    SELECT *
    FROM staging.uat_tthc_stg.document
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),
c AS (
    SELECT *
    FROM staging.uat_tthc_stg.contentitemindex
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND LATEST = 1
      AND PUBLISHED = 1
      AND CONTENTTYPE = 'HoSoTTHC'
),
cte AS (
    SELECT c.contentitemid, c.contenttype, c.displaytext, d.content
    FROM d
    INNER JOIN c ON d.id = c.documentid
),
eform_unnested AS (
    -- eform_item = từng phần tử ContentItems[i], path tính từ phần tử (không cần $.Eform.ContentItems[0]. prefix)
    SELECT
        cte.contentitemid,
        COALESCE(
            CASE get_json_object(eform_item, '$.ContentType')
                WHEN 'Eform6'
                    THEN get_json_object(eform_item, '$.Eform6.MacophieucuaTCduocchaoban.Text')
                WHEN 'Eform11'
                    THEN get_json_object(eform_item, '$.Eform11.MacophieuTCphathanh.Text')
                WHEN 'Eform12'
                    THEN COALESCE(
                        get_json_object(eform_item, '$.Eform12.MacophieuTCphathanh.Text'),
                        get_json_object(eform_item, '$.Eform12.MacophieuTCduochoandoi.Text')
                    )
                WHEN 'Eform13'
                    THEN get_json_object(eform_item, '$.BagPart.ContentItems[0].Eform13ToChucThamGiaHopNhat.MaCoPhieu.Text')
                WHEN 'Eform14'
                    THEN get_json_object(eform_item, '$.Eform14.MaCoPhieu.Text')
                WHEN 'Eform15'
                    THEN get_json_object(eform_item, '$.Eform15.Macophieu.Text')
                WHEN 'Eform23'
                    THEN COALESCE(
                        get_json_object(eform_item, '$.Eform23.Macophieu.Text'),
                        get_json_object(eform_item, '$.Eform23.Machungkhoan.Text')
                    )
                WHEN 'Eform23PL'
                    THEN get_json_object(eform_item, '$.Eform23PL.Macophieu.Text')
                WHEN 'Eform35PL'
                    THEN get_json_object(eform_item, '$.Eform35PL.MaCoPhieu.Text')
                ELSE NULLIF(
                    regexp_extract(
                        eform_item,
                        '"(?:Macophieu|MaCoPhieu|Machungkhoan|MaChungKhoan)"\\s*:\\s*\\{"Text"\\s*:\\s*"([^"]*)"',
                        1
                    ),
                    ''
                )
            END,
            NULLIF(
                regexp_extract(
                    get_json_object(eform_item, '$.BagPart.ContentItems'),
                    '"(?:Macophieu|MaCoPhieu|Machungkhoan|MaChungKhoan)"\\s*:\\s*\\{"Text"\\s*:\\s*"([^"]*)"',
                    1
                ),
                ''
            )
        ) AS securities_code_candidate
    FROM cte
    LATERAL VIEW OUTER explode(
        from_json(
            get_json_object(cte.content, '$.Eform.ContentItems'),
            'array<string>'
        )
    ) eform_tbl AS eform_item
),
securities_agg AS (
    -- Gộp lại 1 dòng/hồ sơ, lấy mã đầu tiên khác NULL theo thứ tự index
    SELECT contentitemid, first(securities_code_candidate, true) AS SECURITIES_CODE
    FROM eform_unnested
    GROUP BY contentitemid
)

SELECT
    CAST(cte.contentitemid AS STRING)                                                            AS AP_DOCUMENT_ID,
    CAST(get_json_object(content, '$.HoSoTTHC.DoiTuongNopHoSo.ContentItemIds[0]') AS STRING)    AS AP_DOCUMENT_APPLICANT_ID,
    CAST(cte.displaytext AS STRING)                                                              AS DOCUMENT_TITLE,
    CAST(sec.SECURITIES_CODE AS STRING)                                                          AS SECURITIES_CODE,
    CAST(COALESCE(
            get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds[0]'),
            get_json_object(content, '$.HoSoTTHC.TrangThaiHoSo.ContentItemIds')
        ) AS STRING)                                                                             AS PROCESSING_STATUS_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.CoQuanXuLy.ContentItemIds[0]') AS STRING)         AS PROCESSING_AUTHORITY_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.LoaiHoSo.ContentItemIds[0]') AS STRING)           AS DOCUMENT_TYPE_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.LinhvucTTHC.ContentItemIds[0]') AS STRING)        AS DOMAIN_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.MucdoTTHC.ContentItemIds[0]') AS STRING)          AS PRIORITY_LEVEL_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.Kenhtiepnhanhoso.ContentItemIds[0]') AS STRING)   AS RECEPTION_CHANNEL_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.ThongTinHinhThucTraHoSo.Text') AS INT)            AS RETURN_METHOD_CODE,
    CAST(get_json_object(content, '$.HoSoTTHC.Canboxuly.UserIds[0]') AS STRING)                 AS PROCESSING_OFFICER_CODE,
    CAST(CASE
            WHEN get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
            THEN CASE
                    WHEN get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') LIKE '%Z'
                      OR get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value') LIKE '%+00:00'
                    THEN from_utc_timestamp(to_timestamp(substring(get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value'), 1, 19), "yyyy-MM-dd'T'HH:mm:ss"), 'Asia/Ho_Chi_Minh')
                    ELSE to_timestamp(substring(get_json_object(content, '$.HoSoTTHC.NgayGuiHoSo.Value'), 1, 19), "yyyy-MM-dd'T'HH:mm:ss")
                 END
            ELSE NULL
        END AS TIMESTAMP)                                                                        AS SUBMISSION_TIMESTAMP,
    CAST(CASE
            WHEN COALESCE(get_json_object(content, '$.HoSoTTHC.NgayTiepNhan.Value'), get_json_object(content, '$.HoSoTTHC.Ngaytiepnhan.Value')) RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
            THEN to_timestamp(substring(COALESCE(get_json_object(content, '$.HoSoTTHC.NgayTiepNhan.Value'), get_json_object(content, '$.HoSoTTHC.Ngaytiepnhan.Value')), 1, 19), "yyyy-MM-dd'T'HH:mm:ss")
            ELSE NULL
        END AS TIMESTAMP)                                                                        AS RECEPTION_TIMESTAMP,
    CAST(CASE
            WHEN get_json_object(content, '$.HoSoTTHC.Thoihanxuly.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
            THEN to_timestamp(substring(get_json_object(content, '$.HoSoTTHC.Thoihanxuly.Value'), 1, 19), "yyyy-MM-dd'T'HH:mm:ss")
            ELSE NULL
        END AS TIMESTAMP)                                                                        AS PROCESSING_DEADLINE_TIMESTAMP,
    CAST(CASE
            WHEN get_json_object(content, '$.HoSoTTHC.NgayTraKetQua.Value') RLIKE '^[12][0-9]{3}-[0-1][0-9]-[0-3][0-9]'
            THEN to_timestamp(substring(get_json_object(content, '$.HoSoTTHC.NgayTraKetQua.Value'), 1, 19), "yyyy-MM-dd'T'HH:mm:ss")
            ELSE NULL
        END AS TIMESTAMP)                                                                        AS RESULT_RETURN_TIMESTAMP,
    CAST(get_json_object(content, '$.HoSoTTHC.Danoplephi.Value') AS STRING)                     AS FEE_PAID_INDICATOR,
    CAST(get_json_object(content, '$.HoSoTTHC.LePhi.Value') AS DECIMAL(23, 2))                  AS FEE_AMOUNT,
    CAST(COALESCE(get_json_object(content, '$.ThanhPhanHoSo.ContentItems'), '[]') AS STRING)     AS DOC_COMPONENT,
    CAST(COALESCE(get_json_object(content, '$.Eform.ContentItems[0]'), '{}') AS STRING)          AS EFORM_DATA
FROM cte
LEFT JOIN securities_agg sec ON sec.contentitemid = cte.contentitemid
