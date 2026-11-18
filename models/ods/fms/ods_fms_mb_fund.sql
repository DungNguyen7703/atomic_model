/*
*--------------------------------------------------------------------*
* Program code: ods_fms_mb_fund
* Program name: ODS FMS.MB_FUND
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
    , fund_id
    , nat_id
    , st_id
    , item_name
    , dorf
    , record_status
    , mb_id
    , fn_code
    , id_no
    , id_date
    , province
    , country
    , address
    , capital
    , hold_qtty
    , hold_percent
    , hold_date
    , frepresent_date
    , mb_type
    , represent_job
    , represent_name
    , srepresent_date
    , deleted
    , data_migration
FROM {{ ref('stg_fms_mb_fund') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')