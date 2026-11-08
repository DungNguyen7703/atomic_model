/*
*--------------------------------------------------------------------*
* Program code: stg_fms_branchs
* Program name: Staging FMS.BRANCHS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                AS id
    , CAST(date_created AS date)           AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS date)          AS date_modified
    , CAST(modify_by AS string)            AS modify_by
    , HEX(sec_id)                          AS sec_id
    , CAST(item_name AS string)            AS item_name
    , CAST(br_type AS int)                 AS br_type
    , CAST(address AS string)              AS address
    , CAST(telephone AS string)            AS telephone
    , CAST(fax AS string)                  AS fax
    , HEX(tl_id)                           AS tl_id
    , CAST(host_office AS int)             AS host_office
    , CAST(description AS string)          AS description
    , CAST(content AS string)              AS content
    , CAST(dorf AS int)                    AS dorf
    , CAST(file_name AS string)            AS file_name
    , CAST(file_data AS string)            AS file_data
    , CAST(stop_date AS date)              AS stop_date
    , CAST(active_date AS date)            AS active_date
    , CAST(decision AS string)             AS decision
    , CAST(decision_date AS date)          AS decision_date
    , CAST(br_idowner AS string)           AS br_idowner
    , CAST(deleted AS int)                 AS deleted
    , CAST(tl_name AS string)              AS tl_name
    , CAST(voucher_no AS string)           AS voucher_no
    , CAST(voucher_date AS date)           AS voucher_date
    , CAST(des_change AS string)           AS des_change
    , CAST(record_status AS decimal(18,2)) AS record_status
    , CAST(data_migration AS int)          AS data_migration
FROM {{ source('source_fms', 'raw_branchs') }}