/*
*--------------------------------------------------------------------*
* Program code: ods_fms_bank_moni
* Program name: ODS FMS.BANK_MONI
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
    , status_id
    , item_name
    , en_name
    , short_name
    , address
    , phone
    , fax
    , email
    , website
    , cert_no
    , note
    , record_type
    , deleted
    , file_name
    , file_data
    , voucher_no
    , dec_date
    , des_change
    , data_migration
    , id_db_old
    , bank_code
    , province_id
    , ward_id
FROM {{ ref('stg_fms_bank_moni') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0