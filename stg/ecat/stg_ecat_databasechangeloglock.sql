/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_databasechangeloglock
* Program name: Staging ECAT.DATABASECHANGELOGLOCK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(locked AS int)            AS locked
    , CAST(lockgranted AS timestamp) AS lockgranted
    , CAST(lockedby AS string)       AS lockedby
FROM {{ source('source_ecat', 'raw_databasechangeloglock') }}