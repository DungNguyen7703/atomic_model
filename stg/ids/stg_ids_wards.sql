/*
*--------------------------------------------------------------------*
* Program code: stg_ids_wards
* Program name: Staging IDS.WARDS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)              AS id
    , CAST(ward_cd AS string)      AS ward_cd
    , CAST(ward_name_vn AS string) AS ward_name_vn
    , CAST(ward_name_en AS string) AS ward_name_en
    , CAST(created_by AS string)   AS created_by
    , CAST(created_date AS date)   AS created_date
    , CAST(updated_by AS string)   AS updated_by
    , CAST(updated_date AS date)   AS updated_date
    , CAST(description AS string)  AS description
    , CAST(active_flg AS int)      AS active_flg
    , CAST(status_flg AS int)      AS status_flg
    , CAST(province_cd AS string)  AS province_cd
    , CAST(system_cd AS string)    AS system_cd
FROM {{ source('source_ids', 'raw_wards') }}