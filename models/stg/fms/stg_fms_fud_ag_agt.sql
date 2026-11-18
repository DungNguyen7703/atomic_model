/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fud_ag_agt
* Program name: Staging FMS.FUD_AG_AGT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                           AS id
    , HEX(fud_id)                     AS fud_id
    , HEX(ag_ty_id)                   AS ag_ty_id
    , HEX(agen_id)                    AS agen_id
    , HEX(agen_id_parent)             AS agen_id_parent
    , CAST(system_object_type AS int) AS system_object_type
FROM {{ source('source_fms', 'raw_fud_ag_agt') }}