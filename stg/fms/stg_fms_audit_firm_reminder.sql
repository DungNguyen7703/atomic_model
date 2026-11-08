/*
*--------------------------------------------------------------------*
* Program code: stg_fms_audit_firm_reminder
* Program name: Staging FMS.AUDIT_FIRM_REMINDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                 AS id
    , CAST(target_type AS string)           AS target_type
    , HEX(audit_firm_id)                    AS audit_firm_id
    , HEX(auditor_id)                       AS auditor_id
    , CAST(document_no AS string)           AS document_no
    , CAST(document_date AS date)           AS document_date
    , CAST(gcn_no AS string)                AS gcn_no
    , CAST(content AS string)               AS content
    , CAST(implementation_status AS string) AS implementation_status
    , CAST(deleted AS int)                  AS deleted
    , CAST(date_created AS timestamp)       AS date_created
    , CAST(date_modified AS timestamp)      AS date_modified
    , CAST(created_by AS string)            AS created_by
    , CAST(modify_by AS string)             AS modify_by
    , CAST(description AS string)           AS description
FROM {{ source('source_fms', 'raw_audit_firm_reminder') }}