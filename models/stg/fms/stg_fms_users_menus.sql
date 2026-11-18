/*
*--------------------------------------------------------------------*
* Program code: stg_fms_users_menus
* Program name: Staging FMS.USERS_MENUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(users_id)   AS users_id
    , HEX(menus_id) AS menus_id
FROM {{ source('source_fms', 'raw_users_menus') }}