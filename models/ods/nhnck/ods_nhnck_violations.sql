/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_violations
* Program name: ODS NHNCK.VIOLATIONS
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
    , professional_id
    , full_name
    , birth_date
    , identity_number
    , note
    , created_by
    , created_at
    , decision_id
    , type
    , status
    , updated_by
    , updated_at
FROM {{ ref('stg_nhnck_violations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')