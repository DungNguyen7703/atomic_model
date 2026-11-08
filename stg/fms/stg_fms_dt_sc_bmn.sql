/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_bmn
* Program name: Staging FMS.DT_SC_BMN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(bmn_id)   AS bmn_id
    , HEX(dts_id) AS dts_id
FROM {{ source('source_fms', 'raw_dt_sc_bmn') }}