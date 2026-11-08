/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_provinces
* Program name: ODS NHNCK.PROVINCES
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
    , country_id
    , province_code
    , province_name
    , created_at
    , created_by
    , updated_at
    , status
    , type
    , updated_by
    , ecatalog_id
FROM {{ ref('stg_nhnck_provinces') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')