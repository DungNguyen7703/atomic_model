/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_post_cert_training_results
* Program name: ODS NHNCK.POST_CERT_TRAINING_RESULTS
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
    , professional_id
    , training_course_id
    , start_date
    , end_date
    , training_hours
    , result_status
    , classification_result
    , note
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_post_cert_training_results') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')