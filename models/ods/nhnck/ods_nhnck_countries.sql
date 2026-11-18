/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_countries
* Program name: ODS NHNCK.COUNTRIES
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
    , country_code
    , country_name
    , is_default
    , created_at
    , created_by
    , updated_at
    , status
    , updated_by
    , ecatalog_id
FROM {{ ref('stg_nhnck_countries') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')