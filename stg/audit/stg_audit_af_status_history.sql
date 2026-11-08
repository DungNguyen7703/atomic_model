/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_status_history
* Program name: Staging AUDIT.AF_STATUS_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(af_profile_id AS int)             AS af_profile_id
    , CAST(status_type AS string)            AS status_type
    , CAST(suspension_status_type AS string) AS suspension_status_type
    , CAST(decision_no AS string)            AS decision_no
    , CAST(decision_date AS date)            AS decision_date
    , CAST(effective_from_date AS date)      AS effective_from_date
    , CAST(effective_to_date AS date)        AS effective_to_date
    , CAST(terminated_decision_date AS date) AS terminated_decision_date
    , CAST(reason AS string)                 AS reason
    , CAST(additional_desc AS string)        AS additional_desc
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(delete_flg AS int)                AS delete_flg
FROM {{ source('source_audit', 'raw_af_status_history') }}