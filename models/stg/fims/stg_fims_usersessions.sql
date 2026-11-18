/*
*--------------------------------------------------------------------*
* Program code: stg_fims_usersessions
* Program name: Staging FIMS.USERSESSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))         AS id
    , CAST(status AS int)             AS status
    , CAST(username AS string)        AS username
    , CAST(destroyusername AS string) AS destroyusername
    , CAST(clientip AS string)        AS clientip
    , CAST(dnsname AS string)         AS dnsname
    , CAST(datelogined AS date)       AS datelogined
    , CAST(description AS string)     AS description
FROM {{ source('source_fims', 'raw_usersessions') }}