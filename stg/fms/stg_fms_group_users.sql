/*
*--------------------------------------------------------------------*
* Program code: stg_fms_group_users
* Program name: Staging FMS.GROUP_USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(groups_id)  AS groups_id
    , HEX(users_id) AS users_id
FROM {{ source('source_fms', 'raw_group_users') }}