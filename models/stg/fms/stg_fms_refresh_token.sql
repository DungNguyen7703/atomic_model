/*
*--------------------------------------------------------------------*
* Program code: stg_fms_refresh_token
* Program name: Staging FMS.REFRESH_TOKEN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(expires_utc AS timestamp) AS expires_utc
    , CAST(token AS string)          AS token
    , HEX(users_id)                  AS users_id
FROM {{ source('source_fms', 'raw_refresh_token') }}