/*
*--------------------------------------------------------------------*
* Program code: atm_sp_employment_status
* Program name: Atomic Securities Practitioner Employment Status
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_wo_hi AS (
    SELECT
        id
        , professional_id
        , organization_id
        , unit_name
        , workplace
        , start_date
        , end_date
        , position_id
        , position_name
        , awards
        , disciplines
    FROM {{ ref('ods_nhnck_professional_work_histories') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONAL_WORK_HISTORIES', "pr_wo_hi.id") }}  AS sp_employment_status_id
    , CAST(pr_wo_hi.id AS string)                                                            AS sp_employment_status_code
    , CAST('NHNCK_PROFESSIONAL_WORK_HISTORIES' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pr_wo_hi.professional_id") }} AS sp_id
    , CAST(pr_wo_hi.professional_id AS string)                                               AS sp_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "pr_wo_hi.organization_id") }} AS securities_organization_reference_id
    , CAST(pr_wo_hi.organization_id AS string)                                               AS securities_organization_reference_code
    , CAST(pr_wo_hi.unit_name AS string)                                                     AS department_nm
    , CAST(pr_wo_hi.workplace AS string)                                                     AS workplace_nm
    , CAST(pr_wo_hi.start_date AS date)                                                      AS employment_start_dt
    , CAST(pr_wo_hi.end_date AS date)                                                        AS employment_end_dt
    , CAST(pr_wo_hi.position_id AS string)                                                   AS position_code
    , CAST(pr_wo_hi.position_name AS string)                                                 AS position_nm
    , CAST(pr_wo_hi.awards AS string)                                                        AS awards
    , CAST(pr_wo_hi.disciplines AS string)                                                   AS disciplines
FROM pr_wo_hi