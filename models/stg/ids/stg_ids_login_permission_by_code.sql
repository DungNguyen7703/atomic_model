/*
*--------------------------------------------------------------------*
* Program code: stg_ids_login_permission_by_code
* Program name: Staging IDS.LOGIN_PERMISSION_BY_CODE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(login_id AS bigint)           AS login_id
    , CAST(login_name AS string)         AS login_name
    , CAST(company_profile_id AS bigint) AS company_profile_id
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS date)         AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS date)         AS updated_date
    , CAST(af_profile_id AS bigint)      AS af_profile_id
FROM {{ source('source_ids', 'raw_login_permission_by_code') }}