/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_foreign_branch
* Program name: Staging ECAT.FOREIGN_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(parent_company_name AS string)          AS parent_company_name
    , CAST(parent_company_address AS string)       AS parent_company_address
    , CAST(parent_business_license AS string)      AS parent_business_license
    , CAST(parent_license_issue_date AS timestamp) AS parent_license_issue_date
    , CAST(parent_license_issuer AS string)        AS parent_license_issuer
    , CAST(branch_name AS string)                  AS branch_name
    , CAST(branch_address AS string)               AS branch_address
    , CAST(branch_license AS string)               AS branch_license
    , CAST(branch_license_issue_date AS timestamp) AS branch_license_issue_date
    , CAST(branch_license_issuer AS string)        AS branch_license_issuer
    , CAST(head_representative AS string)          AS head_representative
    , CAST(nationality_id AS string)               AS nationality_id
    , CAST(nationality_version_id AS string)       AS nationality_version_id
    , CAST(document_type_id AS string)             AS document_type_id
    , CAST(document_type_version_id AS string)     AS document_type_version_id
    , CAST(document_number AS string)              AS document_number
    , CAST(decision_date AS timestamp)             AS decision_date
    , CAST(valid_application_date AS timestamp)    AS valid_application_date
    , CAST(change_reason AS string)                AS change_reason
    , CAST(attachment_file AS string)              AS attachment_file
    , CAST(operation_status AS int)                AS operation_status
    , CAST(note AS string)                         AS note
    , CAST(status AS int)                          AS status
    , CAST(active_reason AS string)                AS active_reason
    , CAST(deleted AS int)                         AS deleted
    , CAST(deleted_reason AS string)               AS deleted_reason
    , CAST(version AS int)                         AS version
    , CAST(effective_start_date AS timestamp)      AS effective_start_date
    , CAST(effective_end_date AS timestamp)        AS effective_end_date
    , CAST(old_id AS string)                       AS old_id
    , CAST(stable_id AS string)                    AS stable_id
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(updated_at AS timestamp)                AS updated_at
    , CAST(created_by_id AS string)                AS created_by_id
    , CAST(created_by_name AS string)              AS created_by_name
    , CAST(updated_by_id AS string)                AS updated_by_id
    , CAST(updated_by_name AS string)              AS updated_by_name
    , CAST(document_type AS string)                AS document_type
FROM {{ source('source_ecat', 'raw_foreign_branch') }}