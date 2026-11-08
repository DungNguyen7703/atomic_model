/*
*--------------------------------------------------------------------*
* Program code: ods_fms_status
* Program name: ODS FMS.STATUS
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
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , type_sec
    , active
    , submit_report
    , description
    , icon
    , color
    , deleted
    , code
FROM {{ ref('stg_fms_status') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND active = 1