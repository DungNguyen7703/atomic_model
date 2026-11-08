/*
*--------------------------------------------------------------------*
* Program code: stg_tms_compliance_template_share
* Program name: Staging TMS.COMPLIANCE_TEMPLATE_SHARE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(template_id AS string)     AS template_id
    , CAST(user_id AS string)         AS user_id
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_compliance_template_share') }}