/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_departments
* Program name: ODS NHNCK.DEPARTMENTS
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
    , unit_id
    , department_code
    , department_name
    , sort_order
    , description
    , status
    , ecatalog_id
FROM {{ ref('stg_nhnck_departments') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')