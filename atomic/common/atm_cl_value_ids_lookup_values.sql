/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_ids_lookup_values
* Program name: Atomic Classification Value IDS.LOOKUP_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Model con (ephemeral) nguon IDS.LOOKUP_VALUES theo LLD lld_IDS_LOOKUP_VALUES (src_stm_code IDS_LOOKUP_VALUES),
*									doc ods_ids_lookup_values; atm_cl_value gop (UNION ALL) cac model con.
*									NGOAI LLD: them nhom AUDITOR_OPINION (schema_code IDS.AUDITOR_OPINION) de mart opr_corporate_bond_issuer_credit_monitor tra ten y kien kiem toan;
*									LLD hien chua co nhom nay -> can Design bo sung. LOOKUP_GROUP khong nam trong danh sach -> loai (LLD: ELSE NULL).
*--------------------------------------------------------------------*
*/

WITH lv AS (
    SELECT
        id
        , lookup_group
        , lookup_cd
        , lookup_value_vn
        , lookup_value_en
        , description
        , ROW_NUMBER() OVER (
            PARTITION BY lookup_group, lookup_cd
            ORDER BY updated_date DESC, id DESC
        ) AS rn
    FROM {{ ref('ods_ids_lookup_values') }}
    WHERE lookup_group IN ('NEWS_APPROVAL_STATUS', 'NEWS_TYPE', 'ENTITY_ROLE_TYPE', 'INSPECTION_TYPE', 'INSPECTION_MODE', 'PENALIZED_SUBJECT_TYPE', 'POSITION', 'ENTERPRISE_TYPE', 'FINANCIAL_STATEMENT_TYPE', 'SECURITIES_TYPE', 'EQUITY_LISTING_EXCH', 'STATUS_IDS', 'PUBLIC_COMPANY_FORM', 'PUBLIC_COM_TYPE', 'SO_APPROVAL_STATUS', 'COMPANY_RELATIONSHIP_TYPE', 'SHAREHOLDER_TYPE', 'SO_ADMINISTRATIVE_PROCEDURE', 'SO_ADMINISTRATIVE_STATUS', 'SO_TRANSACTION_TYPE', 'RC_TYPE', 'SUB_NEWS_TYPE', 'FORM_GROUP', 'REPORT_TYPE', 'RELATIONSHIP_TYPE', 'IDENTITY_TYPE', 'ENTITY_TYPE', 'EDUCATION_LEVEL', 'REPORT_ROW_TYPE', 'REPORT_SCOPE', 'REPORT_PERIOD_TYPE', 'FINANCIAL_STATEMENT_COMPONENT', 'RF_C_DATA_TYPE', 'RF_R_DATA_TYPE', 'SO_OFFERING_METHOD', 'SO_DISTRIBUTION_METHOD', 'SO_SECURITY_TYPE', 'RESTRICTION_TYPE', 'PUB_COM_LISTING_ACTION_TYPE', 'EXCHANGE', 'QUARTER_CODE', 'VIOLATION_STATUS', 'VIOLATION_TYPE', 'VIOLATION_SUBTYPE', 'VIOLATION_TRIGGER_POINT', 'DAY_TYPE', 'AUDITOR_OPINION')
        AND lookup_cd IS NOT NULL
)

SELECT
    CAST(lv.lookup_cd AS string)                                                AS cl_code
    , CAST(
        CASE lv.lookup_group
            WHEN 'NEWS_APPROVAL_STATUS' THEN 'IDS.NEWS_APPROVAL_STATUS'
            WHEN 'NEWS_TYPE' THEN 'IDS.NEWS_TYPE_CD'
            WHEN 'ENTITY_ROLE_TYPE' THEN 'IDS.ENTITY_ROLE_TYPE'
            WHEN 'INSPECTION_TYPE' THEN 'IDS.INSPECTION_TYPE'
            WHEN 'INSPECTION_MODE' THEN 'IDS.INSPECTION_MODE'
            WHEN 'PENALIZED_SUBJECT_TYPE' THEN 'IDS.PENALIZED_SUBJECT_TYPE'
            WHEN 'POSITION' THEN 'IDS.POSITION'
            WHEN 'ENTERPRISE_TYPE' THEN 'IDS.ENTERPRISE_TYPE'
            WHEN 'FINANCIAL_STATEMENT_TYPE' THEN 'IDS.FINANCIAL_STATEMENT_TYPE'
            WHEN 'SECURITIES_TYPE' THEN 'IDS.SECURITIES_TYPE'
            WHEN 'EQUITY_LISTING_EXCH' THEN 'IDS.EQUITY_LISTING_EXCHANGE_CODE'
            WHEN 'STATUS_IDS' THEN 'IDS.PUBLIC_STATUS'
            WHEN 'PUBLIC_COMPANY_FORM' THEN 'IDS.PUBLIC_COMPANY_FORM_TYPE'
            WHEN 'PUBLIC_COM_TYPE' THEN 'IDS.PUBLIC_COMPANY_TYPE'
            WHEN 'SO_APPROVAL_STATUS' THEN 'IDS.SO_APPROVAL_STATUS'
            WHEN 'COMPANY_RELATIONSHIP_TYPE' THEN 'IDS.COMPANY_RELATIONSHIP_TYPE'
            WHEN 'SHAREHOLDER_TYPE' THEN 'IDS.SHAREHOLDER_TYPE'
            WHEN 'SO_ADMINISTRATIVE_PROCEDURE' THEN 'IDS.SO_ADMINISTRATIVE_PROCEDURE'
            WHEN 'SO_ADMINISTRATIVE_STATUS' THEN 'IDS.SO_ADMINISTRATIVE_STATUS'
            WHEN 'SO_TRANSACTION_TYPE' THEN 'IDS.SO_TRANSACTION_TYPE'
            WHEN 'RC_TYPE' THEN 'IDS.REPORT_CATALOG_TYPE'
            WHEN 'SUB_NEWS_TYPE' THEN 'IDS.SUB_NEWS_TYPE_CD'
            WHEN 'FORM_GROUP' THEN 'IDS.FORM_GROUP_TYPE'
            WHEN 'REPORT_TYPE' THEN 'IDS.REPORT_TYPE'
            WHEN 'RELATIONSHIP_TYPE' THEN 'IDS.RELATIONSHIP_TYPE'
            WHEN 'IDENTITY_TYPE' THEN 'IDS.IDENTITY_TYPE'
            WHEN 'ENTITY_TYPE' THEN 'IDS.LEGAL_ENTITY_TYPE'
            WHEN 'EDUCATION_LEVEL' THEN 'IDS.EDUCATION_LEVEL'
            WHEN 'REPORT_ROW_TYPE' THEN 'IDS.REPORT_ROW/COL_TYPE'
            WHEN 'REPORT_SCOPE' THEN 'IDS.REPORT_SCOPE_TYPE'
            WHEN 'REPORT_PERIOD_TYPE' THEN 'IDS.REPORT_PERIOD_TYPE'
            WHEN 'FINANCIAL_STATEMENT_COMPONENT' THEN 'IDS.FINANCIAL_STATEMENT_COMPONENT_TYPE'
            WHEN 'RF_C_DATA_TYPE' THEN 'IDS.RF_C_DATA_TYPE'
            WHEN 'RF_R_DATA_TYPE' THEN 'IDS.RF_R_DATA_TYPE'
            WHEN 'SO_OFFERING_METHOD' THEN 'IDS.SO_OFFERING_METHOD'
            WHEN 'SO_DISTRIBUTION_METHOD' THEN 'IDS.SO_DISTRIBUTION_METHOD'
            WHEN 'SO_SECURITY_TYPE' THEN 'IDS.SO_SECURITY_TYPE'
            WHEN 'RESTRICTION_TYPE' THEN 'IDS.RESTRICTION_TYPE'
            WHEN 'PUB_COM_LISTING_ACTION_TYPE' THEN 'IDS.STOCK_LISTING_ACTION_TYPE'
            WHEN 'EXCHANGE' THEN 'IDS.EXCHANGE_CODE'
            WHEN 'QUARTER_CODE' THEN 'IDS.PERIOD_QUARTER_TYPE'
            WHEN 'VIOLATION_STATUS' THEN 'IDS.VIOLATION_SUBMISSION_STATUS'
            WHEN 'VIOLATION_TYPE' THEN 'IDS.VIOLATION_REPORT_TYPE'
            WHEN 'VIOLATION_SUBTYPE' THEN 'IDS.VIOLATION_REPORT_SUBTYPE'
            WHEN 'VIOLATION_TRIGGER_POINT' THEN 'IDS.VIOLATION_TRIGGER_POINT'
            WHEN 'DAY_TYPE' THEN 'IDS.DAY_TYPE'
            WHEN 'AUDITOR_OPINION' THEN 'IDS.AUDITOR_OPINION'
        END
    AS string)                                                                  AS schema_code
    , CAST(
        CASE lv.lookup_group
            WHEN 'NEWS_APPROVAL_STATUS' THEN 'IDS - Danh mục trạng thái duyệt tin'
            WHEN 'NEWS_TYPE' THEN 'IDS - Danh mục loại tin'
            WHEN 'ENTITY_ROLE_TYPE' THEN 'IDS - Danh mục loại vai trò của thực thể pháp lý'
            WHEN 'INSPECTION_TYPE' THEN 'IDS - Danh mục loại thanh tra/kiểm tra'
            WHEN 'INSPECTION_MODE' THEN 'IDS - Danh mục hình thức thanh tra/kiểm tra'
            WHEN 'PENALIZED_SUBJECT_TYPE' THEN 'IDS - Danh mục loại đối tượng bị xử phạt'
            WHEN 'POSITION' THEN 'IDS - Danh mục chức vụ'
            WHEN 'ENTERPRISE_TYPE' THEN 'IDS - Danh mục loại hình doanh nghiệp'
            WHEN 'FINANCIAL_STATEMENT_TYPE' THEN 'IDS - Danh mục loại báo cáo tài chính'
            WHEN 'SECURITIES_TYPE' THEN 'IDS - Danh mục loại chứng khoán'
            WHEN 'EQUITY_LISTING_EXCH' THEN 'IDS - Danh mục sàn niêm yết cổ phiếu'
            WHEN 'STATUS_IDS' THEN 'IDS - Danh mục trạng thái công ty đại chúng'
            WHEN 'PUBLIC_COMPANY_FORM' THEN 'IDS - Danh mục hình thức công ty đại chúng'
            WHEN 'PUBLIC_COM_TYPE' THEN 'IDS - Danh mục loại công ty đại chúng'
            WHEN 'SO_APPROVAL_STATUS' THEN 'IDS - Danh mục trạng thái phê duyệt'
            WHEN 'COMPANY_RELATIONSHIP_TYPE' THEN 'IDS - Danh mục loại quan hệ công ty'
            WHEN 'SHAREHOLDER_TYPE' THEN 'IDS - Danh mục loại cổ đông'
            WHEN 'SO_ADMINISTRATIVE_PROCEDURE' THEN 'IDS - Danh mục thủ tục hành chính chào bán chứng khoán'
            WHEN 'SO_ADMINISTRATIVE_STATUS' THEN 'IDS - Danh mục trạng thái hành chính'
            WHEN 'SO_TRANSACTION_TYPE' THEN 'IDS - Danh mục loại giao dịch'
            WHEN 'RC_TYPE' THEN 'IDS - Danh mục loại báo cáo'
            WHEN 'SUB_NEWS_TYPE' THEN 'IDS - Danh mục loại tin chi tiết'
            WHEN 'FORM_GROUP' THEN 'IDS - Danh mục nhóm biểu mẫu'
            WHEN 'REPORT_TYPE' THEN 'IDS - Danh mục loại báo cáo'
            WHEN 'RELATIONSHIP_TYPE' THEN 'IDS - Danh mục loại quan hệ'
            WHEN 'IDENTITY_TYPE' THEN 'IDS - Danh mục loại giấy tờ định danh'
            WHEN 'ENTITY_TYPE' THEN 'IDS - Danh mục loại hình thực thể pháp lý'
            WHEN 'EDUCATION_LEVEL' THEN 'IDS - Danh mục trình độ học vấn'
            WHEN 'REPORT_ROW_TYPE' THEN 'IDS - Danh mục loại hàng trong báo cáo tài chính'
            WHEN 'REPORT_SCOPE' THEN 'IDS - Danh mục phạm vi báo cáo'
            WHEN 'REPORT_PERIOD_TYPE' THEN 'IDS - Danh mục loại kỳ báo cáo'
            WHEN 'FINANCIAL_STATEMENT_COMPONENT' THEN 'IDS - Danh mục thành phần báo cáo tài chính'
            WHEN 'RF_C_DATA_TYPE' THEN 'IDS - Danh mục kiểu dữ liệu của cột trong báo cáo tài chính'
            WHEN 'RF_R_DATA_TYPE' THEN 'IDS - Danh mục kiểu dữ liệu của hàng trong báo cáo tài chính'
            WHEN 'SO_OFFERING_METHOD' THEN 'IDS - Danh mục phương thức chào bán'
            WHEN 'SO_DISTRIBUTION_METHOD' THEN 'IDS - Danh mục phương thức phân phối'
            WHEN 'SO_SECURITY_TYPE' THEN 'IDS - Danh mục loại chứng khoán'
            WHEN 'RESTRICTION_TYPE' THEN 'IDS - Danh mục loại đối tượng hạn chế'
            WHEN 'PUB_COM_LISTING_ACTION_TYPE' THEN 'IDS - Danh mục loại hành động niêm yết của công ty đại chúng'
            WHEN 'EXCHANGE' THEN 'IDS - Danh mục sàn giao dịch'
            WHEN 'QUARTER_CODE' THEN 'IDS - Danh mục quý'
            WHEN 'VIOLATION_STATUS' THEN 'IDS - Danh mục trạng thái gửi báo cáo vi phạm'
            WHEN 'VIOLATION_TYPE' THEN 'IDS - Danh mục loại báo cáo vi phạm'
            WHEN 'VIOLATION_SUBTYPE' THEN 'IDS - Danh mục loại hạng mục của báo cáo vi phạm'
            WHEN 'VIOLATION_TRIGGER_POINT' THEN 'IDS - Danh mục thời điểm kích hoạt vi phạm'
            WHEN 'DAY_TYPE' THEN 'IDS - Danh mục loại ngày'
            WHEN 'AUDITOR_OPINION' THEN 'IDS - Danh mục ý kiến kiểm toán'
        END
    AS string)                                                                  AS schema_nm
    , CAST('IDS_LOOKUP_VALUES' AS string)                                       AS src_stm_code
    , CAST(lv.lookup_value_vn AS string)                                        AS cl_nm
    , CAST(lv.lookup_value_en AS string)                                        AS cl_nm_english
    , CAST(lv.description AS string)                                            AS cl_description
FROM lv
WHERE lv.rn = 1
