/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_audit_firm_representative
* Program name: Staging ECAT.APPROVED_AUDIT_FIRM_REPRESENTATIVE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(audit_firm_id AS string)           AS audit_firm_id
    , CAST(audit_firm_stable_id AS string)    AS audit_firm_stable_id
    , CAST(full_name AS string)               AS full_name
    , CAST(identity_no AS string)             AS identity_no
    , CAST(phone_no AS string)                AS phone_no
    , CAST(position_title_cd AS string)       AS position_title_cd
    , CAST(from_date AS timestamp)            AS from_date
    , CAST(to_date AS timestamp)              AS to_date
    , CAST(id_sync AS decimal(22,0))          AS id_sync
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS decimal(38,10))         AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(created_by AS string)              AS created_by
    , CAST(created_date AS timestamp)         AS created_date
    , CAST(updated_by AS string)              AS updated_by
    , CAST(updated_date AS timestamp)         AS updated_date
FROM {{ source('source_ecat', 'raw_approved_audit_firm_representative') }}