/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_business
* Program name: Atomic Classification FMS Business
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FMS_BUSINESS.
*--------------------------------------------------------------------*
*/

WITH bu AS (
    SELECT
        id
        , item_name
        , description
        , system_object
    FROM {{ ref('ods_fms_business') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BUSINESS', "bu.id") }}                                                AS cl_fms_business_id
    , CAST(bu.id AS string)                                                                                       AS cl_fms_business_code
    , CAST('FMS_BUSINESS' AS string)                                                                              AS src_stm_code
    , CAST(bu.item_name AS string)                                                                                AS cl_fms_business_nm
    , CAST(bu.description AS string)                                                                              AS description
    , CASE WHEN bu.system_object IS NULL THEN NULL ELSE transform(split(bu.system_object, ','), x -> trim(x)) END AS stm_object_tp_codes
FROM bu