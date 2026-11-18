/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rolesmenus
* Program name: Staging FIMS.ROLESMENUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(rolesid AS decimal(18,2))   AS rolesid
    , CAST(menusid AS decimal(18,2)) AS menusid
FROM {{ source('source_fims', 'raw_rolesmenus') }}