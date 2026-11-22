/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_audit_lookup_values
* Program name: Atomic Classification Value AUDIT.LOOKUP_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh AUDIT theo lld_AUDIT_LOOKUP_VALUES.yaml (11 LOOKUP_GROUP).
*--------------------------------------------------------------------*
*/

WITH lv AS (
    SELECT
        lookup_cd
        , lookup_group
        , lookup_value_vn
        , lookup_value_en
        , description
    FROM {{ ref('ods_audit_lookup_values') }}
    WHERE lookup_group IN ('AF_TARGET_TYPE', 'AF_AUTHORITY', 'POSITION', 'AF_STATUS', 'PROFILE_APPROVAL_STATUS', 'AF_AUDITOR_STATUS', 'AF_INSPECTION_RESULT', 'AF_ACTION_TYPE', 'AF_AUDIT_ACTION', 'AF_INSPECTION_UNIT', 'AF_NEXT_YEAR_PROCESSING')
)

SELECT
    CAST(lv.lookup_cd AS string)        AS cl_code
    , CAST(CASE
            WHEN lv.lookup_group = 'AF_TARGET_TYPE' THEN 'AUDIT.AF_TARGET_TYPE'
            WHEN lv.lookup_group = 'AF_AUTHORITY' THEN 'AUDIT.AF_AUTHORITY'
            WHEN lv.lookup_group = 'POSITION' THEN 'AUDIT.POSITION'
            WHEN lv.lookup_group = 'AF_STATUS' THEN 'AUDIT.AF_STATUS'
            WHEN lv.lookup_group = 'PROFILE_APPROVAL_STATUS' THEN 'AUDIT.PROFILE_APPROVAL_STATUS'
            WHEN lv.lookup_group = 'AF_AUDITOR_STATUS' THEN 'AUDIT.AF_AUDITOR_STATUS'
            WHEN lv.lookup_group = 'AF_INSPECTION_RESULT' THEN 'AUDIT.AF_INSPECTION_RESULT'
            WHEN lv.lookup_group = 'AF_ACTION_TYPE' THEN 'AUDIT.AF_ACTION_TYPE'
            WHEN lv.lookup_group = 'AF_AUDIT_ACTION' THEN 'AUDIT.AF_AUDIT_ACTION'
            WHEN lv.lookup_group = 'AF_INSPECTION_UNIT' THEN 'AUDIT.AF_INSPECTION_UNIT'
            WHEN lv.lookup_group = 'AF_NEXT_YEAR_PROCESSING' THEN 'AUDIT.AF_NEXT_YEAR_PROCESSING'
            ELSE NULL END AS string)
        AS schema_code
    , CAST(CASE
            WHEN lv.lookup_group = 'AF_TARGET_TYPE' THEN 'AUDIT - Danh mục loại đối tượng áp dụng'
            WHEN lv.lookup_group = 'AF_AUTHORITY' THEN 'AUDIT - Danh mục cơ quan có thẩm quyền'
            WHEN lv.lookup_group = 'POSITION' THEN 'AUDIT - Danh mục chức vụ'
            WHEN lv.lookup_group = 'AF_STATUS' THEN 'AUDIT - Danh mục trạng thái công ty kiểm toán'
            WHEN lv.lookup_group = 'PROFILE_APPROVAL_STATUS' THEN 'AUDIT - Danh mục trạng thái phê duyệt hồ sơ'
            WHEN lv.lookup_group = 'AF_AUDITOR_STATUS' THEN 'AUDIT - Danh mục trạng thái kiểm toán viên'
            WHEN lv.lookup_group = 'AF_INSPECTION_RESULT' THEN 'AUDIT - Danh mục kết quả thanh tra/kiểm tra'
            WHEN lv.lookup_group = 'AF_ACTION_TYPE' THEN 'AUDIT - Danh mục loại hành động'
            WHEN lv.lookup_group = 'AF_AUDIT_ACTION' THEN 'AUDIT - Danh mục loại hình thức xử lý vi phạm'
            WHEN lv.lookup_group = 'AF_INSPECTION_UNIT' THEN 'AUDIT - Danh mục đơn vị thanh tra/kiểm tra'
            WHEN lv.lookup_group = 'AF_NEXT_YEAR_PROCESSING' THEN 'AUDIT - Danh mục hướng xử lý xem xét năm sau'
            ELSE NULL END AS string)
        AS schema_nm
    , CAST('AUDIT_LOOKUP_VALUES' AS string)      AS src_stm_code
    , CAST(lv.lookup_value_vn AS string)         AS cl_nm
    , CAST(lv.lookup_value_en AS string)         AS cl_nm_english
    , CAST(lv.description AS string)             AS cl_description
FROM lv
