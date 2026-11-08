/*
*--------------------------------------------------------------------*
* Program code: stg_fims_groupusers
* Program name: Staging FIMS.GROUPUSERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(groupsid AS decimal(18,2))  AS groupsid
    , CAST(usersid AS decimal(18,2)) AS usersid
FROM {{ source('source_fims', 'raw_groupusers') }}