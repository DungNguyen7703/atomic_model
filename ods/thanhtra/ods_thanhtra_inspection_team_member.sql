/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_team_member
* Program name: ODS THANHTRA.INSPECTION_TEAM_MEMBER
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
    , inspection_team_id
    , user_id
    , user_full_name
    , user_account
    , department_id
    , department_name
    , role_in_team
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_inspection_team_member') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0