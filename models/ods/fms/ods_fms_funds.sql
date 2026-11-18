/*
*--------------------------------------------------------------------*
* Program code: ods_fms_funds
* Program name: ODS FMS.FUNDS
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
    , ename
    , short_name
    , id_no
    , id_date
    , capital
    , total_qtty
    , description
    , cer_code
    , type_of_fund_no
    , type_of_fund_mnp
    , type_of_fund_dent
    , deleted
    , time_of_fund
    , ftype_id
    , sec_id
    , bank_id
    , status_id
    , voucher_no
    , nav
    , nav_ccq
    , file_name
    , file_data
    , dec_date
    , par_value
    , inves_strategy
    , deschange
    , data_migration
    , id_db_old
    , listing_date
    , number_fund_cer_first
    , stock_exchange
    , open_fund_type
FROM {{ ref('stg_fms_funds') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0  