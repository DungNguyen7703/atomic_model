/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_examination_result_notice
* Program name: ODS THANHTRA.EXAMINATION_RESULT_NOTICE
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
    , examination_team_id
    , notice_number
    , issued_date
    , announced_date
    , target_type
    , target_reference_id
    , target_name
    , content
    , recommendation
    , execution_status
    , execution_description
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_examination_result_notice') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0