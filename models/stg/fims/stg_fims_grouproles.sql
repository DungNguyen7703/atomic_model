/*
*--------------------------------------------------------------------*
* Program code: stg_fims_grouproles
* Program name: Staging FIMS.GROUPROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(rolesid AS decimal(18,2))    AS rolesid
    , CAST(groupsid AS decimal(18,2)) AS groupsid
FROM {{ source('source_fims', 'raw_grouproles') }}