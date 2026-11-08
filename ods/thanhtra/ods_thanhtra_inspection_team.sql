/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_team
* Program name: ODS THANHTRA.INSPECTION_TEAM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_INSPECTION_TEAM.yaml] them cot criminal_transfer, criminal_transfer_note (cuoi, sau verification_minutes_sign_date).
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , inspection_annual_plan_id
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
    , inspection_period_from
    , inspection_period_to
    , anti_money_laundering
    , abnormal_transaction_check
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , verification_minutes_sign_date
    , criminal_transfer
    , criminal_transfer_note
FROM {{ ref('stg_thanhtra_inspection_team') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0