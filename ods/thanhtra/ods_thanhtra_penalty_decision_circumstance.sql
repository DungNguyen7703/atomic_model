/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_decision_circumstance
* Program name: ODS THANHTRA.PENALTY_DECISION_CIRCUMSTANCE
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
    , circumstance_type
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , content
    , penalty_decision_subject_behavior_id
FROM {{ ref('stg_thanhtra_penalty_decision_circumstance') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0