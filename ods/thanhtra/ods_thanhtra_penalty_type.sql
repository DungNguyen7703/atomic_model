/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_penalty_type
* Program name: ODS THANHTRA.PENALTY_TYPE
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
    , category
    , description
    , status
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , legal_basis
FROM {{ ref('stg_thanhtra_penalty_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0