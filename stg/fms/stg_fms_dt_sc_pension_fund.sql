/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_pension_fund
* Program name: Staging FMS.DT_SC_PENSION_FUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)            AS dts_id
    , HEX(pension_fund_id) AS pension_fund_id
FROM {{ source('source_fms', 'raw_dt_sc_pension_fund') }}