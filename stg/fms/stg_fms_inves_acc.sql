/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inves_acc
* Program name: Staging FMS.INVES_ACC
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(inves_id)                      AS inves_id
    , CAST(account AS string)            AS account
    , CAST(record_status AS int)         AS record_status
    , CAST(contract_no AS string)        AS contract_no
    , CAST(acc_place AS string)          AS acc_place
    , CAST(date_report AS date)          AS date_report
    , CAST(deleted AS int)               AS deleted
    , CAST(ad_scale AS decimal(18,2))    AS ad_scale
    , CAST(act_scale AS decimal(18,2))   AS act_scale
    , CAST(list_value AS decimal(18,2))  AS list_value
    , CAST(manager_fee AS decimal(18,2)) AS manager_fee
    , CAST(data_migration AS int)        AS data_migration
FROM {{ source('source_fms', 'raw_inves_acc') }}