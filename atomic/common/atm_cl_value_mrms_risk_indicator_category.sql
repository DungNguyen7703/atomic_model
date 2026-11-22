/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_mrms_risk_indicator_category
* Program name: Atomic Classification Value MRMS.RISK_INDICATOR_CATEGORY
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh MRMS theo lld_MRMS_RISK_INDICATOR_CATEGORY.yaml (UAT chua co). ODS da loc deleted = 0 AND status = 1.
*--------------------------------------------------------------------*
*/

WITH ri_ca AS (
    SELECT
        category_code
        , category_name
    FROM {{ ref('ods_mrms_risk_indicator_category') }}
    WHERE category_code IS NOT NULL
)

SELECT
    CAST(ri_ca.category_code AS string)                                   AS cl_code
    , CAST('MRMS.RISK_INDICATOR_CATEGORY' AS string)                      AS schema_code
    , CAST('MRMS - Danh mục nhóm chỉ tiêu tài chính rủi ro' AS string)  AS schema_nm
    , CAST('MRMS_RISK_INDICATOR_CATEGORY' AS string)                      AS src_stm_code
    , CAST(ri_ca.category_name AS string)                                 AS cl_nm
    , CAST(NULL AS string)                                                AS cl_nm_english
    , CAST(NULL AS string)                                                AS cl_description
FROM ri_ca
