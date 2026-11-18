/*
*--------------------------------------------------------------------*
* Program code: atm_sp_organization_annual_report
* Program name: Atomic Securities Practitioner Organization Annual Report
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_ORGANIZATION_REPORT_YEARLYS.
*--------------------------------------------------------------------*
*/

WITH or_re_ye AS (
    SELECT
        id
        , organization_id
        , name
        , submission_date
        , year
        , type
        , file_path
        , status
    FROM {{ ref('ods_nhnck_organization_report_yearlys') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATION_REPORT_YEARLYS', "or_re_ye.id") }} AS sp_organization_annual_rpt_id
    , CAST(or_re_ye.id AS string)                                                             AS sp_organization_annual_rpt_code
    , CAST('NHNCK_ORGANIZATION_REPORT_YEARLYS' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "or_re_ye.organization_id") }}  AS securities_organization_reference_id
    , CAST(or_re_ye.organization_id AS string)                                                AS securities_organization_reference_code
    , CAST(or_re_ye.name AS string)                                                           AS rpt_nm
    , CAST(or_re_ye.year AS string)                                                           AS rpt_year
    , CAST(or_re_ye.type AS string)                                                           AS rpt_tp_code
    , CAST(or_re_ye.submission_date AS date)                                                  AS submission_dt
    , CAST(or_re_ye.file_path AS string)                                                      AS rpt_file_path
    , CAST(or_re_ye.status AS string)                                                         AS status_code
FROM or_re_ye