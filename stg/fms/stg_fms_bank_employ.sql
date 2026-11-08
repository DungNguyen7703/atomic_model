/*
*--------------------------------------------------------------------*
* Program code: stg_fms_bank_employ
* Program name: Staging FMS.BANK_EMPLOY
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
    , HEX(bank_id)                AS bank_id
    , CAST(item_name AS string)   AS item_name
    , CAST(id_no AS string)       AS id_no
    , CAST(id_date AS date)       AS id_date
    , CAST(cert_no AS string)     AS cert_no
    , CAST(cert_law AS string)    AS cert_law
    , CAST(cert_audit AS string)  AS cert_audit
    , CAST(cert_date AS date)     AS cert_date
    , CAST(record_status AS int)  AS record_status
    , CAST(deleted AS int)        AS deleted
    , CAST(position AS string)    AS position
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_bank_employ') }}