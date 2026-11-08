/*
*--------------------------------------------------------------------*
* Program code: ods_fms_agencies
* Program name: ODS FMS.AGENCIES
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
    , short_name
    , ename
    , decision
    , decision_date
    , decision_place
    , address
    , telephone
    , fax
    , record_status
    , deleted
    , content
    , stop_date
    , active_date
    , data_migration
    , list_distribution_staff
    , number_reg_fund_cer
FROM {{ ref('stg_fms_agencies') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')