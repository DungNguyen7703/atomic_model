/*
*--------------------------------------------------------------------*
* Program code: stg_fims_usersmenus
* Program name: Staging FIMS.USERSMENUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(usersid AS decimal(18,2))   AS usersid
    , CAST(menusid AS decimal(18,2)) AS menusid
FROM {{ source('source_fims', 'raw_usersmenus') }}