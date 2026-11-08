/*
*--------------------------------------------------------------------*
* Program code: stg_fms_user_sessions
* Program name: Staging FMS.USER_SESSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , CAST(record_status AS int)        AS record_status
    , CAST(user_name AS string)         AS user_name
    , CAST(destroy_user_name AS string) AS destroy_user_name
    , CAST(client_ip AS string)         AS client_ip
    , CAST(dns_name AS string)          AS dns_name
    , CAST(date_logined AS date)        AS date_logined
    , CAST(description AS string)       AS description
FROM {{ source('source_fms', 'raw_user_sessions') }}