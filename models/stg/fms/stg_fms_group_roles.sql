/*
*--------------------------------------------------------------------*
* Program code: stg_fms_group_roles
* Program name: Staging FMS.GROUP_ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(roles_id)    AS roles_id
    , HEX(groups_id) AS groups_id
FROM {{ source('source_fms', 'raw_group_roles') }}