/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_distributor_agent
* Program name: Staging FMS.DT_SC_DISTRIBUTOR_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)                 AS dts_id
    , HEX(distributor_agent_id) AS distributor_agent_id
FROM {{ source('source_fms', 'raw_dt_sc_distributor_agent') }}