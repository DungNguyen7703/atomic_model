/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_exam_sessions
* Program name: ODS NHNCK.EXAM_SESSIONS
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
    , name
    , code
    , year
    , session_
    , organizing_unit
    , application_start_date
    , application_end_date
    , exam_start_date
    , exam_end_date
    , file_path
    , noti_date
    , exam_locations
    , submission_methods
    , status
    , created_at
    , updated_at
    , created_by
    , updated_by
    , decision_id
    , bank_id
    , bank_account_number
    , bank_account_name
FROM {{ ref('stg_nhnck_exam_sessions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')