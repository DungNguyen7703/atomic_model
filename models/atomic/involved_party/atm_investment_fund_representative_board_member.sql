/*
*--------------------------------------------------------------------*
* Program code: atm_investment_fund_representative_board_member
* Program name: Atomic Investment Fund Representative Board Member
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Sync LLD Atomic FMS UAT 20261006 (lld_FMS_REPRESENT.yaml): job_title_code -> cl_fms_job_id/code
*										(nguon thuc te REPRESENT.JOB_ID — LLD ghi JOBS_ID); bo province_nm (PROVINCE da map sang IP Alt
*										Identification.issue_place), active_status_flag; *_description -> education_level_nm,
*										professional_qualification_nm, other_experience, other_concurrent_position
*--------------------------------------------------------------------*
*/

WITH repr AS (
    SELECT
        id
        , fund_id
        , job_id
        , nat_id
        , item_name
        , position
        , education
        , prof_qualifi
        , other_exp
        , other_position
        , description
        , member_type
    FROM {{ ref('ods_fms_represent') }}
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fms_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_REPRESENT', "repr.id") }}     AS investment_fund_representative_board_member_id
    , CAST(repr.id AS string)                                           AS investment_fund_representative_board_member_code
    , CAST('FMS_REPRESENT' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "repr.fund_id") }}  AS investment_fund_id
    , CAST(repr.fund_id AS string)                                      AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_JOBS', "repr.job_id") }}    AS cl_fms_job_id
    , CAST(repr.job_id AS string)                                       AS cl_fms_job_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }} AS nationality_id
    , CAST(nati.sname AS string)                                        AS nationality_code
    , CAST(repr.item_name AS string)                                    AS board_member_full_nm
    , CAST(repr.position AS string)                                     AS current_position_title
    , CAST(repr.education AS string)                                    AS education_level_nm
    , CAST(repr.prof_qualifi AS string)                                 AS professional_qualification_nm
    , CAST(repr.other_exp AS string)                                    AS other_experience
    , CAST(repr.other_position AS string)                               AS other_concurrent_position
    , CAST(repr.description AS string)                                  AS description
    , CAST(repr.member_type AS string)                                  AS board_member_tp_code
FROM repr
    LEFT JOIN nati ON repr.NAT_ID = nati.ID