/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_specialization_course_details
* Program name: ODS NHNCK.SPECIALIZATION_COURSE_DETAILS
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
    , specialization_course_id
    , professional_id
    , exam_number
    , full_name
    , birth_date
    , permanent_country_id
    , permanent_province_id
    , permanent_district_id
    , place_of_birth
    , identity_type
    , identity_number
    , identity_issue_date
    , identity_issue_place
    , created_at
    , created_by
    , updated_at
    , updated_by
    , description
    , exam_score
    , result
    , status
    , note
    , specialization_id
    , assignee_id
FROM {{ ref('stg_nhnck_specialization_course_details') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')