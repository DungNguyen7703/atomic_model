/*
*--------------------------------------------------------------------*
* Program code: ods_fms_inves_acc
* Program name: ODS FMS.INVES_ACC
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
    , inves_id
    , account
    , record_status
    , contract_no
    , acc_place
    , date_report
    , deleted
    , ad_scale
    , act_scale
    , list_value
    , manager_fee
    , data_migration
FROM {{ ref('stg_fms_inves_acc') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')