/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_sc_fr
* Program name: Staging FMS.DT_SC_FR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(fr_id)    AS fr_id
    , HEX(dts_id) AS dts_id
FROM {{ source('source_fms', 'raw_dt_sc_fr') }}