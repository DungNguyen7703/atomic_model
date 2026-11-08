/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_other_agent
* Program name: Staging FMS.DT_SC_OTHER_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(dts_id)           AS dts_id
    , HEX(other_agent_id) AS other_agent_id
FROM {{ source('source_fms', 'raw_dt_sc_other_agent') }}