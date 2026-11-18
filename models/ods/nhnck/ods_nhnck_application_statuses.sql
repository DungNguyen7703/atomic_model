/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_statuses
* Program name: ODS NHNCK.APPLICATION_STATUSES
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
    , status_code
    , status_name
    , label
    , description
    , sort_order
    , is_active
    , is_original_data
    , created_by
    , updated_by
    , created_at
    , updated_at
FROM {{ ref('stg_nhnck_application_statuses') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')