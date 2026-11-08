/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_re_exams
* Program name: ODS NHNCK.APPLICATION_RE_EXAMS
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
    , application_id
    , exam_detail_id
    , re_application_id
    , status
    , created_at
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_application_re_exams') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')