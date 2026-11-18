/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_behavior
* Program name: ODS THANHTRA.VIOLATION_BEHAVIOR
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
    , name
    , description
    , primary_penalty_type_id
    , min_fine_amount
    , max_fine_amount
    , remedial_measure
    , status
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , legal_document
    , violation_clause
FROM {{ ref('stg_thanhtra_violation_behavior') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0