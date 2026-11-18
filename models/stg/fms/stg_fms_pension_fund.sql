/*
*--------------------------------------------------------------------*
* Program code: stg_fms_pension_fund
* Program name: Staging FMS.PENSION_FUND
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
    , HEX(sec_id)                      AS sec_id
    , CAST(business_cert_no AS string) AS business_cert_no
    , CAST(item_name AS string)        AS item_name
    , CAST(name_en AS string)          AS name_en
    , CAST(short_name AS string)       AS short_name
    , HEX(custodian_bank_id)           AS custodian_bank_id
    , HEX(supervisor_bank_id)          AS supervisor_bank_id
    , HEX(status_id)                   AS status_id
    , CAST(note AS string)             AS note
    , CAST(file_name AS string)        AS file_name
    , CAST(file_data AS string)        AS file_data
    , CAST(deleted AS int)             AS deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_pension_fund') }}