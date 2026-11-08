/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_certificates
* Program name: ODS NHNCK.CERTIFICATES
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
    , certificate_code
    , certificate_name
    , description
    , created_at
    , updated_at
    , is_displayed
    , sort_order
    , is_original_data
    , processing_days
    , status
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_certificates') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')