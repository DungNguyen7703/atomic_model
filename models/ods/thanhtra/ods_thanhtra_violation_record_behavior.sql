/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_record_behavior
* Program name: ODS THANHTRA.VIOLATION_RECORD_BEHAVIOR
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
    , violation_record_id
    , violation_behavior_id
    , description
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , legal_basis
FROM {{ ref('stg_thanhtra_violation_record_behavior') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0