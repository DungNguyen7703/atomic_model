/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fud_tagt
* Program name: Staging FMS.FUD_TAGT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(fn_t_id)     AS fn_t_id
    , HEX(agen_t_id) AS agen_t_id
FROM {{ source('source_fms', 'raw_fud_tagt') }}