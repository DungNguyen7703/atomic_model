/*
*--------------------------------------------------------------------*
* Program code: stg_fms_bank_employ_history
* Program name: Staging FMS.BANK_EMPLOY_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , HEX(bank_employ_id)              AS bank_employ_id
    , HEX(bank_id)                     AS bank_id
    , HEX(event_type_id)               AS event_type_id
    , CAST(changed_field AS string)    AS changed_field
    , CAST(old_value AS string)        AS old_value
    , CAST(new_value AS string)        AS new_value
    , CAST(voucher_no AS string)       AS voucher_no
    , CAST(dec_date AS date)           AS dec_date
    , CAST(des_change AS string)       AS des_change
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_bank_employ_history') }}