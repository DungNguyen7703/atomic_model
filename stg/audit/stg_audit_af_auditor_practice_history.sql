/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_auditor_practice_history
* Program name: Staging AUDIT.AF_AUDITOR_PRACTICE_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(af_auditor_profile_id AS int)    AS af_auditor_profile_id
    , CAST(practice_from_date AS date)      AS practice_from_date
    , CAST(practice_to_date AS date)        AS practice_to_date
    , CAST(practice_organization_id AS int) AS practice_organization_id
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
FROM {{ source('source_audit', 'raw_af_auditor_practice_history') }}