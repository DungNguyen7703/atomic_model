/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_fnd
* Program name: Staging FMS.DT_SC_FND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(fnd_id)   AS fnd_id
    , HEX(dts_id) AS dts_id
FROM {{ source('source_fms', 'raw_dt_sc_fnd') }}