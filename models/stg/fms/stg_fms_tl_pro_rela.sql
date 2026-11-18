/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tl_pro_rela
* Program name: Staging FMS.TL_PRO_RELA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , HEX(tlpro_id)                    AS tlpro_id
    , HEX(rela_id)                     AS rela_id
    , CAST(item_name AS string)        AS item_name
    , CAST(id_no AS string)            AS id_no
    , CAST(id_date AS date)            AS id_date
    , CAST(id_place AS string)         AS id_place
    , CAST(deleted AS int)             AS deleted
    , CAST(address AS string)          AS address
    , CAST(description AS string)      AS description
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_tl_pro_rela') }}