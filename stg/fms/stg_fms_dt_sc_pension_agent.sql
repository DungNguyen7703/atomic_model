/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_pension_agent
* Program name: Staging FMS.DT_SC_PENSION_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)             AS dts_id
    , HEX(pension_agent_id) AS pension_agent_id
FROM {{ source('source_fms', 'raw_dt_sc_pension_agent') }}