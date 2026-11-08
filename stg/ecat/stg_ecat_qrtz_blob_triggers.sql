/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_blob_triggers
* Program name: Staging ECAT.QRTZ_BLOB_TRIGGERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)      AS sched_name
    , CAST(trigger_name AS string)  AS trigger_name
    , CAST(trigger_group AS string) AS trigger_group
    , CAST(blob_data AS string)     AS blob_data
FROM {{ source('source_ecat', 'raw_qrtz_blob_triggers') }}