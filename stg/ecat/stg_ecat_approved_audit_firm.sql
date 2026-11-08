/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_audit_firm
* Program name: Staging ECAT.APPROVED_AUDIT_FIRM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(audit_firm_cd AS string)            AS audit_firm_cd
    , CAST(full_name_vi AS string)             AS full_name_vi
    , CAST(full_name_en AS string)             AS full_name_en
    , CAST(short_name AS string)               AS short_name
    , CAST(eligibility_cert_no AS string)      AS eligibility_cert_no
    , CAST(address AS string)                  AS address
    , CAST(phone_no AS bigint)                 AS phone_no
    , CAST(fax_no AS bigint)                   AS fax_no
    , CAST(website AS string)                  AS website
    , CAST(approval_decision_no AS string)     AS approval_decision_no
    , CAST(approval_date AS timestamp)         AS approval_date
    , CAST(foreign_audit_member_flg AS int)    AS foreign_audit_member_flg
    , CAST(membership_start_date AS timestamp) AS membership_start_date
    , CAST(active AS int)                      AS active
    , CAST(active_reason AS string)            AS active_reason
    , CAST(deleted AS int)                     AS deleted
    , CAST(deleted_reason AS string)           AS deleted_reason
    , CAST(version AS int)                     AS version
    , CAST(effective_start_date AS timestamp)  AS effective_start_date
    , CAST(effective_end_date AS timestamp)    AS effective_end_date
    , CAST(old_id AS string)                   AS old_id
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(stable_id AS string)                AS stable_id
    , CAST(created_by AS string)               AS created_by
    , CAST(created_date AS timestamp)          AS created_date
    , CAST(last_updated_by AS string)          AS last_updated_by
    , CAST(last_updated_date AS timestamp)     AS last_updated_date
    , CAST(business_reg_no AS string)          AS business_reg_no
    , CAST(paid_in_capital AS bigint)          AS paid_in_capital
FROM {{ source('source_ecat', 'raw_approved_audit_firm') }}