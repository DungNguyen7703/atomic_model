/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_post_cert_training_courses
* Program name: ODS NHNCK.POST_CERT_TRAINING_COURSES
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
    , course_code
    , course_name
    , class_code
    , status
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_post_cert_training_courses') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')