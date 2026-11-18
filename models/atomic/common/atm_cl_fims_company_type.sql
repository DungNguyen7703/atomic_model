/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fims_company_type
* Program name: Atomic Classification FIMS Company Type
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FIMS_COMPANYTYPE.
*--------------------------------------------------------------------*
*/

WITH co_ty AS (
    SELECT
        code
        , name
        , description
        , typeobject
        , ecatalog_id
    FROM {{ ref('ods_fims_companytype') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_COMPANYTYPE', "co_ty.code") }} AS cl_fims_company_tp_id
    , CAST(co_ty.code AS string)                                            AS cl_fims_company_tp_code
    , CAST('FIMS_COMPANYTYPE' AS string)                                    AS src_stm_code
    , CAST(co_ty.name AS string)                                            AS cl_fims_company_tp_nm
    , CAST(co_ty.description AS string)                                     AS description
    , CAST(co_ty.typeobject AS string)                                      AS object_tp_code
    , CAST(co_ty.ecatalog_id AS string)                                     AS ecatalog_id
FROM co_ty