/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_company_type
* Program name: Atomic Classification FMS Company Type
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FMS_COMPANY_TYPE.
*--------------------------------------------------------------------*
*/

WITH co_ty AS (
    SELECT
        id
        , code
        , item_name
        , description
        , system_object
        , joint_stock
    FROM {{ ref('ods_fms_company_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_COMPANY_TYPE', "co_ty.id") }} AS cl_fms_company_tp_id
    , CAST(co_ty.code AS string)                                          AS cl_fms_company_tp_code
    , CAST('FMS_COMPANY_TYPE' AS string)                                  AS src_stm_code
    , CAST(co_ty.item_name AS string)                                     AS cl_fms_company_tp_nm
    , CAST(co_ty.description AS string)                                   AS description
    , CAST(co_ty.system_object AS string)                                 AS stm_object_tp_codes
    , CAST(co_ty.joint_stock AS int)                                      AS joint_stock_ind
FROM co_ty