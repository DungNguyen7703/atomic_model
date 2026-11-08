/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tot_st_tg
* Program name: Staging FMS.TOT_ST_TG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(tg_oid)      AS tg_oid
    , HEX(st_tg_oid) AS st_tg_oid
FROM {{ source('source_fms', 'raw_tot_st_tg') }}