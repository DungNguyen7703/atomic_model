/*
*--------------------------------------------------------------------*
* Program code: stg_fms_pension_fund_history
* Program name: Staging FMS.PENSION_FUND_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , HEX(pension_fund_id)               AS pension_fund_id
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
FROM {{ source('source_fms', 'raw_pension_fund_history') }}