/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_stockholder_type
* Program name: Atomic Classification FMS Stockholder Type
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FMS_STOCKHOLDER_TYPE.
*--------------------------------------------------------------------*
*/

WITH st_ty AS (
    SELECT
        id
        , item_name
        , description
        , personal_type
    FROM {{ ref('ods_fms_stockholder_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STOCKHOLDER_TYPE', "st_ty.id") }} AS cl_fms_stockholder_tp_id
    , CAST(st_ty.id AS string)                                                AS cl_fms_stockholder_tp_code
    , CAST('FMS_STOCKHOLDER_TYPE' AS string)                                  AS src_stm_code
    , CAST(st_ty.item_name AS string)                                         AS cl_fms_stockholder_tp_nm
    , CAST(st_ty.description AS string)                                       AS description
    , CAST(st_ty.personal_type AS int)                                        AS personal_tp_ind
FROM st_ty