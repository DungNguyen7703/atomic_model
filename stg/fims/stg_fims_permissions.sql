/*
*--------------------------------------------------------------------*
* Program code: stg_fims_permissions
* Program name: Staging FIMS.PERMISSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)          AS id
    , CAST(module_id AS string) AS module_id
    , CAST(form_id AS string)   AS form_id
    , CAST(role_code AS string) AS role_code
    , CAST(can_view AS int)     AS can_view
    , CAST(can_create AS int)   AS can_create
    , CAST(can_edit AS int)     AS can_edit
    , CAST(can_delete AS int)   AS can_delete
FROM {{ source('source_fims', 'raw_permissions') }}