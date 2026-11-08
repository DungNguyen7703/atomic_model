/*
*--------------------------------------------------------------------*
* Program code: stg_fms_agencies
* Program name: Staging FMS.AGENCIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                   AS id
    , CAST(date_created AS date)              AS date_created
    , CAST(created_by AS string)              AS created_by
    , CAST(date_modified AS date)             AS date_modified
    , CAST(modify_by AS string)               AS modify_by
    , CAST(item_name AS string)               AS item_name
    , CAST(short_name AS string)              AS short_name
    , CAST(ename AS string)                   AS ename
    , CAST(decision AS string)                AS decision
    , CAST(decision_date AS date)             AS decision_date
    , CAST(decision_place AS string)          AS decision_place
    , CAST(address AS string)                 AS address
    , CAST(telephone AS string)               AS telephone
    , CAST(fax AS string)                     AS fax
    , CAST(record_status AS int)              AS record_status
    , CAST(deleted AS int)                    AS deleted
    , CAST(content AS string)                 AS content
    , CAST(stop_date AS date)                 AS stop_date
    , CAST(active_date AS date)               AS active_date
    , CAST(data_migration AS int)             AS data_migration
    , CAST(list_distribution_staff AS string) AS list_distribution_staff
    , CAST(number_reg_fund_cer AS string)     AS number_reg_fund_cer
FROM {{ source('source_fms', 'raw_agencies') }}