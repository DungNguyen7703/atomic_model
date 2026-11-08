/*
*--------------------------------------------------------------------*
* Program code: stg_fms_roles_menus
* Program name: Staging FMS.ROLES_MENUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(roles_id)   AS roles_id
    , HEX(menus_id) AS menus_id
FROM {{ source('source_fms', 'raw_roles_menus') }}