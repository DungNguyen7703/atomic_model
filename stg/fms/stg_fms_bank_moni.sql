/*
*--------------------------------------------------------------------*
* Program code: stg_fms_bank_moni
* Program name: Staging FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , HEX(status_id)              AS status_id
    , CAST(item_name AS string)   AS item_name
    , CAST(en_name AS string)     AS en_name
    , CAST(short_name AS string)  AS short_name
    , CAST(address AS string)     AS address
    , CAST(phone AS string)       AS phone
    , CAST(fax AS string)         AS fax
    , CAST(email AS string)       AS email
    , CAST(website AS string)     AS website
    , CAST(cert_no AS string)     AS cert_no
    , CAST(note AS string)        AS note
    , CAST(record_type AS string) AS record_type
    , CAST(deleted AS int)        AS deleted
    , CAST(file_name AS string)   AS file_name
    , CAST(file_data AS string)   AS file_data
    , CAST(voucher_no AS string)  AS voucher_no
    , CAST(dec_date AS date)      AS dec_date
    , CAST(des_change AS string)  AS des_change
    , CAST(data_migration AS int) AS data_migration
    , CAST(id_db_old AS string)   AS id_db_old
    , CAST(bank_code AS string)   AS bank_code
    , CAST(province_id AS string) AS province_id
    , CAST(ward_id AS string)     AS ward_id
FROM {{ source('source_fms', 'raw_bank_moni') }}