/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_exam_details
* Program name: ODS NHNCK.EXAM_DETAILS
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
    , certificate_id
    , exam_session_id
    , sequence_number
    , exam_number
    , law_score
    , law_result
    , specialization_score
    , specialization_result
    , result
    , note
    , created_at
    , updated_at
    , created_by
    , updated_by
    , application_id
FROM {{ ref('stg_nhnck_exam_details') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')