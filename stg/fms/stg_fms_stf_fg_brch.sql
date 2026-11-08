/*
*--------------------------------------------------------------------*
* Program code: stg_fms_stf_fg_brch
* Program name: Staging FMS.STF_FG_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                       AS id
    , HEX(for_brch_id)                            AS for_brch_id
    , HEX(jobs_id)                                AS jobs_id
    , HEX(nat_id)                                 AS nat_id
    , CAST(staff_branch AS int)                   AS staff_branch
    , CAST(item_name AS string)                   AS item_name
    , CAST(sex AS int)                            AS sex
    , CAST(address AS string)                     AS address
    , CAST(record_status AS decimal(38,0))        AS record_status
    , CAST(id_code AS string)                     AS id_code
    , CAST(date_code AS date)                     AS date_code
    , CAST(issued_code AS string)                 AS issued_code
    , CAST(email AS string)                       AS email
    , CAST(represent AS int)                      AS represent
    , CAST(license AS string)                     AS license
    , CAST(license_date AS date)                  AS license_date
    , CAST(file_data AS string)                   AS file_data
    , CAST(note AS string)                        AS note
    , CAST(deleted AS int)                        AS deleted
    , CAST(created_by AS string)                  AS created_by
    , CAST(date_created AS date)                  AS date_created
    , CAST(date_modified AS date)                 AS date_modified
    , CAST(modify_by AS string)                   AS modify_by
    , CAST(isp AS int)                            AS isp
    , CAST(pl_email AS string)                    AS pl_email
    , CAST(data_migration AS int)                 AS data_migration
    , CAST(practice_cert_no AS string)            AS practice_cert_no
    , CAST(practice_cert_issue_date AS date)      AS practice_cert_issue_date
    , CAST(branch_director AS int)                AS branch_director
    , CAST(director_appoint_license_no AS string) AS director_appoint_license_no
    , CAST(director_approval_date AS date)        AS director_approval_date
    , CAST(license_end_date AS date)              AS license_end_date
FROM {{ source('source_fms', 'raw_stf_fg_brch') }}