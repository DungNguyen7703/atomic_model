/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_custodian_bank
* Program name: Staging ECAT.CUSTODIAN_BANK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name_vn AS string)                 AS name_vn
    , CAST(name_en AS string)                 AS name_en
    , CAST(short_name AS string)              AS short_name
    , CAST(type AS int)                       AS type
    , CAST(address AS string)                 AS address
    , CAST(phone_number AS string)            AS phone_number
    , CAST(fax AS string)                     AS fax
    , CAST(email AS string)                   AS email
    , CAST(website AS string)                 AS website
    , CAST(cert_no AS string)                 AS cert_no
    , CAST(voucher_no AS string)              AS voucher_no
    , CAST(dec_date AS timestamp)             AS dec_date
    , CAST(status AS int)                     AS status
    , CAST(file_data AS string)               AS file_data
    , CAST(file_name AS string)               AS file_name
    , CAST(note AS string)                    AS note
    , CAST(active AS int)                     AS active
    , CAST(deleted AS int)                    AS deleted
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(old_id AS string)                  AS old_id
    , CAST(version AS int)                    AS version
    , CAST(stable_id AS string)               AS stable_id
FROM {{ source('source_ecat', 'raw_custodian_bank') }}