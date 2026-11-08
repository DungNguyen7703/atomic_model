/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_legal_representative
* Program name: Staging AUDIT.AF_LEGAL_REPRESENTATIVE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(af_profile_id AS int)           AS af_profile_id
    , CAST(full_name AS string)            AS full_name
    , CAST(identity_no AS string)          AS identity_no
    , CAST(phone_no AS string)             AS phone_no
    , CAST(position_title_cd AS string)    AS position_title_cd
    , CAST(appointment_start_date AS date) AS appointment_start_date
    , CAST(appointment_end_date AS date)   AS appointment_end_date
    , CAST(created_by AS string)           AS created_by
    , CAST(created_date AS date)           AS created_date
    , CAST(updated_by AS string)           AS updated_by
    , CAST(updated_date AS date)           AS updated_date
    , CAST(delete_flg AS int)              AS delete_flg
FROM {{ source('source_audit', 'raw_af_legal_representative') }}