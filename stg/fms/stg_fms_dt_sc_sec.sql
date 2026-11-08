/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_sec
* Program name: Staging FMS.DT_SC_SEC
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(sec_id)   AS sec_id
    , HEX(dts_id) AS dts_id
FROM {{ source('source_fms', 'raw_dt_sc_sec') }}