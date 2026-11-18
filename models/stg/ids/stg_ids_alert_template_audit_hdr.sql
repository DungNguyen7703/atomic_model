/*
*--------------------------------------------------------------------*
* Program code: stg_ids_alert_template_audit_hdr
* Program name: Staging IDS.ALERT_TEMPLATE_AUDIT_HDR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(code AS string)           AS code
    , CAST(name AS string)           AS name
    , CAST(description AS string)    AS description
    , CAST(condition_type AS string) AS condition_type
    , CAST(active_flg AS int)        AS active_flg
    , CAST(delete_flg AS int)        AS delete_flg
    , CAST(created_date AS date)     AS created_date
    , CAST(created_by AS string)     AS created_by
    , CAST(updated_date AS date)     AS updated_date
    , CAST(updated_by AS string)     AS updated_by
FROM {{ source('source_ids', 'raw_alert_template_audit_hdr') }}