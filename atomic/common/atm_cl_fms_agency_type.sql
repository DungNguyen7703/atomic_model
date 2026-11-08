/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_agency_type
* Program name: Atomic Classification FMS Agency Type
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo theo thiết kế dm_atm_cl_fms_agency_type-FMS.AGENCY_TYPE.yaml (draft)
*--------------------------------------------------------------------*
*/

WITH ag_ty AS (
    SELECT
        id
        , item_name
        , description
    FROM {{ ref('ods_fms_agency_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_AGENCY_TYPE', "ag_ty.id") }}     AS cl_fms_agency_tp_id
    , CAST(ag_ty.id AS string)                                             AS cl_fms_agency_tp_code
    , CAST('FMS_AGENCY_TYPE' AS string)                                    AS src_stm_code
    , CAST(ag_ty.item_name AS string)                                      AS cl_fms_agency_tp_nm
    , CAST(ag_ty.description AS string)                                    AS description
FROM ag_ty
