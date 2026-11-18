/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_districts
* Program name: ODS NHNCK.DISTRICTS
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
    , province_id
    , district_code
    , district_name
    , created_at
    , created_by
    , updated_at
    , status
    , type
    , updated_by
    , ecatalog_id
FROM {{ ref('stg_nhnck_districts') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')