/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_public_company
* Program name: Staging ECAT.PUBLIC_COMPANY
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
    , CAST(code AS string)                     AS code
    , CAST(company_name_vn AS string)          AS company_name_vn
    , CAST(company_name_en AS string)          AS company_name_en
    , CAST(exchange AS string)                 AS exchange
    , CAST(security_id AS string)              AS security_id
    , CAST(listed_flag AS int)                 AS listed_flag
    , CAST(business_line_id AS string)         AS business_line_id
    , CAST(isin_code AS string)                AS isin_code
    , CAST(auto_approval_flg AS int)           AS auto_approval_flg
    , CAST(company_login AS string)            AS company_login
    , CAST(parent_company_flag AS int)         AS parent_company_flag
    , CAST(security_type_id AS string)         AS security_type_id
    , CAST(report_type AS string)              AS report_type
    , CAST(public_company_form_cd AS string)   AS public_company_form_cd
    , CAST(fy_start_date AS timestamp)         AS fy_start_date
    , CAST(approver_comment AS string)         AS approver_comment
    , CAST(active AS int)                      AS active
    , CAST(deleted AS int)                     AS deleted
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(effective_start_date AS timestamp)  AS effective_start_date
    , CAST(effective_end_date AS timestamp)    AS effective_end_date
    , CAST(active_reason AS string)            AS active_reason
    , CAST(deleted_reason AS string)           AS deleted_reason
    , CAST(old_id AS string)                   AS old_id
    , CAST(version AS int)                     AS version
    , CAST(stable_id AS string)                AS stable_id
    , CAST(security_version_id AS string)      AS security_version_id
    , CAST(security_type_version_id AS string) AS security_type_version_id
    , CAST(business_line_version_id AS string) AS business_line_version_id
    , CAST(created_by_user_name AS string)     AS created_by_user_name
    , CAST(created_date AS timestamp)          AS created_date
    , CAST(updated_by_user_name AS string)     AS updated_by_user_name
    , CAST(updated_date AS timestamp)          AS updated_date
FROM {{ source('source_ecat', 'raw_public_company') }}