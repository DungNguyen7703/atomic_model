/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_transfer_agent
* Program name: Staging FMS.DT_SC_TRANSFER_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)              AS dts_id
    , HEX(transfer_agent_id) AS transfer_agent_id
FROM {{ source('source_fms', 'raw_dt_sc_transfer_agent') }}