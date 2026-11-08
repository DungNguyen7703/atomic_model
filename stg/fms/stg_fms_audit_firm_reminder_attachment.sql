/*
*--------------------------------------------------------------------*
* Program code: stg_fms_audit_firm_reminder_attachment
* Program name: Staging FMS.AUDIT_FIRM_REMINDER_ATTACHMENT
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
    , HEX(reminder_id)                 AS reminder_id
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(created_by AS string)       AS created_by
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_audit_firm_reminder_attachment') }}