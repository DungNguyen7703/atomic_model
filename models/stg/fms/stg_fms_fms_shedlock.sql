/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fms_shedlock
* Program name: Staging FMS.FMS_SHEDLOCK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(name AS string)            AS name
    , CAST(lock_until AS timestamp) AS lock_until
    , CAST(locked_at AS timestamp)  AS locked_at
    , CAST(locked_by AS string)     AS locked_by
FROM {{ source('source_fms', 'raw_fms_shedlock') }}