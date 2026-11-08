/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_units
* Program name: ODS NHNCK.UNITS
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
    , parent_id
    , level_
    , unit_code
    , unit_name
    , address
    , phone_number
    , email
    , fax
    , description
    , created_at
    , created_by
    , updated_at
    , status
    , updated_by
FROM {{ ref('stg_nhnck_units') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')