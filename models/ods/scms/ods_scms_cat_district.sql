/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_district
* Program name: ODS SCMS.CAT_DISTRICT
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
    , province_id
    , district_code
    , district_name
    , note
    , created_by
    , created_at
    , record_status
FROM {{ ref('stg_scms_cat_district') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')