/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_data_permission
* Program name: Staging MRMS.RISK_INDICATOR_DATA_PERMISSION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(scope_type AS int)         AS scope_type
    , CAST(set_code AS int)           AS set_code
    , CAST(indicator_id AS string)    AS indicator_id
    , CAST(user_id AS string)         AS user_id
    , CAST(can_view_flag AS int)      AS can_view_flag
    , CAST(can_edit_flag AS int)      AS can_edit_flag
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_mrms', 'raw_risk_indicator_data_permission') }}