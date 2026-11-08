/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_exam_session_fees
* Program name: ODS NHNCK.EXAM_SESSION_FEES
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
    , exam_session_id
    , certificate_id
    , fee_exam
    , fee_appeal
    , status
    , created_at
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_exam_session_fees') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')