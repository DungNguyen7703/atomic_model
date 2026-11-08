/*
*--------------------------------------------------------------------*
* Program code: atm_sp_organization_employment_report
* Program name: Atomic Securities Practitioner Organization Employment Report
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH or_re AS (
    SELECT
        id
        , created_at
        , organization_id
        , professional_id
        , certificate_record_id
        , certificate_id
        , parent_report_id
        , full_name
        , birth_date
        , identity_number
        , position
        , department
        , workplace
        , certificate_number
        , issue_date
        , hire_date
        , termination_date
        , report_date
        , disciplines
        , description
        , notes
        , business_department
        , file_path
        , file_path_termination
        , sync_id
        , status_organization
        , sync_created_at
        , sync_updated_at
        , status
    FROM {{ ref('ods_nhnck_organization_reports') }}
    WHERE created_at >= TO_TIMESTAMP('{{ var("etl_date") }}')
        AND created_at <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
),

cert AS (
    SELECT
        id
        , certificate_code
    FROM {{ ref('ods_nhnck_certificates') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATION_REPORTS', "or_re.id") }}                     AS sp_organization_employment_rpt_id
    , CAST(or_re.id AS string)                                                                        AS sp_organization_employment_rpt_code
    , CAST('NHNCK_ORGANIZATION_REPORTS' AS string)                                                    AS src_stm_code
    , CAST(or_re.created_at AS date)                                                                  AS data_dt
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "or_re.organization_id") }}             AS securities_organization_reference_id
    , CAST(or_re.organization_id AS string)                                                           AS securities_organization_reference_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "or_re.professional_id") }}             AS sp_id
    , CAST(or_re.professional_id AS string)                                                           AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "or_re.certificate_record_id") }} AS sp_license_certificate_document_id
    , CAST(or_re.certificate_record_id AS string)                                                     AS sp_license_certificate_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATES', "cert.certificate_code") }}              AS sp_license_certificate_tp_id
    , CAST(or_re.certificate_id AS string)                                                            AS sp_license_certificate_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATION_REPORTS', "or_re.parent_report_id") }}     AS parent_sp_organization_employment_rpt_id
    , CAST(or_re.parent_report_id AS string)                                                          AS parent_sp_organization_employment_rpt_code
    , CAST(or_re.full_name AS string)                                                                 AS practitioner_nm_at_rpt
    , CAST(or_re.birth_date AS date)                                                                  AS practitioner_birth_dt_at_rpt
    , CAST(or_re.identity_number AS string)                                                           AS practitioner_identity_nbr_at_rpt
    , CAST(or_re.position AS string)                                                                  AS practitioner_position_at_rpt
    , CAST(or_re.department AS string)                                                                AS practitioner_department_at_rpt
    , CAST(or_re.workplace AS string)                                                                 AS practitioner_workplace_at_rpt
    , CAST(or_re.certificate_number AS string)                                                        AS certificate_nbr_at_rpt
    , CAST(or_re.issue_date AS date)                                                                  AS certificate_issue_dt_at_rpt
    , CAST(or_re.hire_date AS date)                                                                   AS hire_dt
    , CAST(or_re.termination_date AS date)                                                            AS termination_dt
    , CAST(or_re.report_date AS date)                                                                 AS rpt_dt
    , CAST(or_re.disciplines AS string)                                                               AS disciplines
    , CAST(or_re.description AS string)                                                               AS description
    , CAST(or_re.notes AS string)                                                                     AS notes
    , CAST(or_re.business_department AS string)                                                       AS business_department_nm
    , CAST(or_re.file_path AS string)                                                                 AS rpt_file_path
    , CAST(or_re.file_path_termination AS string)                                                     AS termination_file_path
    , CAST(or_re.sync_id AS string)                                                                   AS external_sync_id
    , CAST(or_re.status_organization AS string)                                                       AS organization_status_code_at_rpt
    , CAST(or_re.sync_created_at AS timestamp)                                                        AS sync_created_tms
    , CAST(or_re.sync_updated_at AS timestamp)                                                        AS sync_updated_tms
    , CAST(or_re.status AS string)                                                                    AS status_code
FROM or_re
    LEFT JOIN cert ON or_re.CERTIFICATE_ID = cert.ID