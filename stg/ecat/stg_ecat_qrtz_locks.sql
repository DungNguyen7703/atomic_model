/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_locks
* Program name: Staging ECAT.QRTZ_LOCKS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)  AS sched_name
    , CAST(lock_name AS string) AS lock_name
FROM {{ source('source_ecat', 'raw_qrtz_locks') }}