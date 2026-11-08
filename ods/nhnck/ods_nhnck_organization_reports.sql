/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_organization_reports
* Program name: ODS NHNCK.ORGANIZATION_REPORTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , organization_id
    , professional_id
    , certificate_id
    , certificate_record_id
    , full_name
    , birth_date
    , identity_number
    , position
    , department
    , workplace
    , hire_date
    , termination_date
    , certificate_number
    , issue_date
    , disciplines
    , description
    , report_date
    , sync_id
    , sync_created_at
    , sync_updated_at
    , type
    , parent_report_id
    , status
    , status_organization
    , file_path
    , file_path_termination
    , business_department
    , notes
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_organization_reports') }}
WHERE created_at >= TO_TIMESTAMP('{{ var("etl_date") }}')
  AND created_at <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
