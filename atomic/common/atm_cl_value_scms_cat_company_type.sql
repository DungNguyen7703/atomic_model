/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value_scms_cat_company_type
* Program name: Atomic Classification Value SCMS.CAT_COMPANY_TYPE
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model con (ephemeral) nguon SCMS.CAT_COMPANY_TYPE theo LLD lld_SCMS_CAT_COMPANY_TYPE.yaml (src_stm_code SCMS_CAT_COMPANY_TYPE),
*									doc ods_scms_cat_company_type; atm_cl_value gop (UNION ALL) cac model con. cl_description chua map (LLD) -> NULL.
*									Loc company_type_code IS NOT NULL vi cl_code thuoc khoa (schema_code, cl_code) cua cl_value.
*--------------------------------------------------------------------*
*/

WITH ca_co_ty AS (
    SELECT
        company_type_code
        , company_type_name
    FROM {{ ref('ods_scms_cat_company_type') }}
    WHERE company_type_code IS NOT NULL
)

SELECT
    CAST(ca_co_ty.company_type_code AS string)                                  AS cl_code
    , CAST('SCMS.CAT_COMPANY_TYPE' AS string)                                   AS schema_code
    , CAST('SCMS - Danh mục loại hình doanh nghiệp' AS string)                  AS schema_nm
    , CAST('SCMS_CAT_COMPANY_TYPE' AS string)                                   AS src_stm_code
    , CAST(ca_co_ty.company_type_name AS string)                                AS cl_nm
    , CAST(NULL AS string)                                                      AS cl_nm_english
    , CAST(NULL AS string)                                                      AS cl_description
FROM ca_co_ty
