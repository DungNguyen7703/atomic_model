/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_simprop_triggers
* Program name: Staging ECAT.QRTZ_SIMPROP_TRIGGERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)          AS sched_name
    , CAST(trigger_name AS string)      AS trigger_name
    , CAST(trigger_group AS string)     AS trigger_group
    , CAST(str_prop_1 AS string)        AS str_prop_1
    , CAST(str_prop_2 AS string)        AS str_prop_2
    , CAST(str_prop_3 AS string)        AS str_prop_3
    , CAST(int_prop_1 AS bigint)        AS int_prop_1
    , CAST(int_prop_2 AS bigint)        AS int_prop_2
    , CAST(long_prop_1 AS bigint)       AS long_prop_1
    , CAST(long_prop_2 AS bigint)       AS long_prop_2
    , CAST(dec_prop_1 AS decimal(13,4)) AS dec_prop_1
    , CAST(dec_prop_2 AS decimal(13,4)) AS dec_prop_2
    , CAST(bool_prop_1 AS string)       AS bool_prop_1
    , CAST(bool_prop_2 AS string)       AS bool_prop_2
FROM {{ source('source_ecat', 'raw_qrtz_simprop_triggers') }}