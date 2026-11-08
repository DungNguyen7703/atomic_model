/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fund_history
* Program name: Staging FMS.FUND_HISTORY
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
    , HEX(fund_id)                       AS fund_id
    , CAST(date_change AS date)          AS date_change
    , CAST(action AS string)             AS action
    , CAST(adjustment_license AS string) AS adjustment_license
    , CAST(license_date AS date)         AS license_date
    , CAST(prev_value AS string)         AS prev_value
    , CAST(value_change AS string)       AS value_change
    , CAST(reason AS string)             AS reason
    , CAST(file_data AS string)          AS file_data
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
FROM {{ source('source_fms', 'raw_fund_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')