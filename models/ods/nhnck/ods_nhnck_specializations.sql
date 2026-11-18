/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_specializations
* Program name: ODS NHNCK.SPECIALIZATIONS
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
    , specialization_code
    , specialization_name
    , reference
    , created_at
    , created_by
    , updated_at
    , is_active
    , is_original_data
    , status
    , mcdt_code
    , updated_by
FROM {{ ref('stg_nhnck_specializations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')