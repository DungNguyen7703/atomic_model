/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_examination_team
* Program name: ODS THANHTRA.EXAMINATION_TEAM
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
    , code
    , examination_annual_plan_id
    , unit_id
    , unit_name
    , plan_year
    , form_type
    , start_date
    , end_date
    , duration_days
    , decision_number
    , decision_date
    , decision_name
    , announcement_date
    , content
    , examination_period_from
    , examination_period_to
    , anti_money_laundering
    , abnormal_transaction_check
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , created_by_ban_role
FROM {{ ref('stg_thanhtra_examination_team') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0