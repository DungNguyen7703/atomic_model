/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_decision_violation_record
* Program name: ODS THANHTRA.PENALTY_DECISION_VIOLATION_RECORD
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
    , penalty_decision_id
    , violation_record_id
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_penalty_decision_violation_record') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0