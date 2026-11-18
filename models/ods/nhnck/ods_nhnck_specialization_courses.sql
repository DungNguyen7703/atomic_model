/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_specialization_courses
* Program name: ODS NHNCK.SPECIALIZATION_COURSES
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
    , specialization_id
    , academic_year
    , course_code
    , course_name
    , created_at
    , created_by
    , updated_at
    , updated_by
    , status
    , exam_date_from
    , exam_date_to
    , address
    , province_id
FROM {{ ref('stg_nhnck_specialization_courses') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')