/*
*--------------------------------------------------------------------*
* Program code: stg_fms_self_set_pd
* Program name: Staging FMS.SELF_SET_PD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , HEX(sec_id)                 AS sec_id
    , HEX(bkm_id)                 AS bkm_id
    , HEX(fr_br_id)               AS fr_br_id
    , HEX(fud_id)                 AS fud_id
    , HEX(rpt_id)                 AS rpt_id
    , CAST(sent AS int)           AS sent
FROM {{ source('source_fms', 'raw_self_set_pd') }}