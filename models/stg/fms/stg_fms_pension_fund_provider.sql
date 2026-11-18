/*
*--------------------------------------------------------------------*
* Program code: stg_fms_pension_fund_provider
* Program name: Staging FMS.PENSION_FUND_PROVIDER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(pension_fund_id)     AS pension_fund_id
    , HEX(pension_provider_id) AS pension_provider_id
FROM {{ source('source_fms', 'raw_pension_fund_provider') }}