/*
*--------------------------------------------------------------------*
* Program code: stg_fms_auditor
* Program name: Staging FMS.AUDITOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , HEX(audit_firm_id)               AS audit_firm_id
    , CAST(full_name AS string)        AS full_name
    , CAST(cert_no AS string)          AS cert_no
    , CAST(cert_date AS date)          AS cert_date
    , CAST(gcn_no AS string)           AS gcn_no
    , CAST(approval_date AS date)      AS approval_date
    , CAST(revocation_date AS date)    AS revocation_date
    , CAST(email AS string)            AS email
    , CAST(description AS string)      AS description
    , CAST(record_status AS int)       AS record_status
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(created_by AS string)       AS created_by
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_auditor') }}