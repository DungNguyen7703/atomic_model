/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_examination_team_target
* Program name: ODS THANHTRA.EXAMINATION_TEAM_TARGET
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
    , target_type
    , target_reference_id
    , target_name
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , account_number
    , securities_company_name
    , address
    , citizen_id
    , business_registration_number
    , legal_rep_name
    , legal_rep_citizen_id
    , start_date
    , end_date
FROM {{ ref('stg_thanhtra_examination_team_target') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0