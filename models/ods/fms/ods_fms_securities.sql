/*
*--------------------------------------------------------------------*
* Program code: ods_fms_securities
* Program name: ODS FMS.SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Them country_id, province_id, ward_id (LLD Atomic FMS SECURITIES_IP_Postal_Address)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , status_id
    , item_name
    , tname
    , ename
    , short_name
    , code
    , address
    , telephone
    , fax
    , website
    , id_no
    , id_date
    , id_add
    , capital
    , total_qtty
    , business_type
    , borf_flag
    , insider_id
    , description
    , stock_code
    , market
    , email
    , national
    , sec_id
    , fr_date
    , to_date
    , stop_date
    , active_date
    , record_type
    , deleted
    , pepresent_ative
    , public_id
    , file_name
    , file_data
    , org_name
    , tr_code
    , listed
    , public_listed
    , reg_date
    , fin_date
    , dec_date
    , voucher_no
    , direc_name
    , deput_name
    , des_change
    , activ_other
    , foreign_type
    , org_national
    , org_id_no
    , real_business_type
    , par_id
    , real_active_date
    , reg_no
    , ct_id
    , data_migration
    , id_db_old
    , event_type_id
    , bank_id
    , province_id
    , ward_id
    , country_id
FROM {{ ref('stg_fms_securities') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0 