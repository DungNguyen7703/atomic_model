/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_decisions
* Program name: ODS NHNCK.DECISIONS
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
    , decision_number
    , title
    , reference
    , decision_content
    , signed_date
    , signatory
    , position
    , decision_unit
    , file_name
    , file_path
    , created_at
    , created_by
    , updated_at
    , decision_type_id
    , status
    , content
    , is_active
    , updated_by
FROM {{ ref('stg_nhnck_decisions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND is_active = 1
    AND status = 1