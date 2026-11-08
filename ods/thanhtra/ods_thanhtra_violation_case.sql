/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_case
* Program name: ODS THANHTRA.VIOLATION_CASE
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
    , source_category
    , source_unit_id
    , source_unit_name
    , inspection_team_id
    , examination_team_id
    , assigned_officer_id
    , assigned_officer_name
    , supervising_leader_id
    , supervising_leader_name
    , status
    , bond_issuer_code
    , market_type
    , bond_code
    , processing_progress
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_violation_case') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0