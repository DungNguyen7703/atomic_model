/*
*--------------------------------------------------------------------*
* Program code: stg_fms_menus
* Program name: Staging FMS.MENUS
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
    , CAST(title AS string)       AS title
    , CAST(icon AS string)        AS icon
    , CAST(url AS string)         AS url
    , HEX(parent_id)              AS parent_id
    , CAST(menu_type AS int)      AS menu_type
    , CAST(sort_order AS bigint)  AS sort_order
    , CAST(access AS string)      AS access
    , CAST(active AS int)         AS active
    , CAST(access_url AS string)  AS access_url
    , CAST(code AS string)        AS code
FROM {{ source('source_fms', 'raw_menus') }}