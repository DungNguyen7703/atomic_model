/*
*--------------------------------------------------------------------*
* Program code: stg_fms_nhn_org_warning_snapshot
* Program name: Staging FMS.NHN_ORG_WARNING_SNAPSHOT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(target_id)                       AS target_id
    , CAST(license_no AS string)           AS license_no
    , CAST(tax_code AS string)             AS tax_code
    , CAST(warn_2company AS int)           AS warn_2company
    , CAST(warn_3year_nopractice AS int)   AS warn_3year_nopractice
    , CAST(warn_vphc AS int)               AS warn_vphc
    , CAST(revoke_reason AS string)        AS revoke_reason
    , CAST(practitioner_count AS bigint)   AS practitioner_count
    , CAST(warning_count AS bigint)        AS warning_count
    , CAST(source_updated_at AS timestamp) AS source_updated_at
    , CAST(deleted AS int)                 AS deleted
    , CAST(date_created AS timestamp)      AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS timestamp)     AS date_modified
    , CAST(modify_by AS string)            AS modify_by
FROM {{ source('source_fms', 'raw_nhn_org_warning_snapshot') }}