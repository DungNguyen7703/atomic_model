/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_simprop_triggers
* Program name: Staging MRMS.QRTZ_SIMPROP_TRIGGERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)         AS sched_name
    , CAST(trigger_name AS string)       AS trigger_name
    , CAST(trigger_group AS string)      AS trigger_group
    , CAST(str_prop_1 AS string)         AS str_prop_1
    , CAST(str_prop_2 AS string)         AS str_prop_2
    , CAST(str_prop_3 AS string)         AS str_prop_3
    , CAST(int_prop_1 AS int)            AS int_prop_1
    , CAST(int_prop_2 AS int)            AS int_prop_2
    , CAST(long_prop_1 AS decimal(19,0)) AS long_prop_1
    , CAST(long_prop_2 AS decimal(19,0)) AS long_prop_2
    , CAST(dec_prop_1 AS decimal(13,4))  AS dec_prop_1
    , CAST(dec_prop_2 AS decimal(13,4))  AS dec_prop_2
    , CAST(bool_prop_1 AS string)        AS bool_prop_1
    , CAST(bool_prop_2 AS string)        AS bool_prop_2
FROM {{ source('source_mrms', 'raw_qrtz_simprop_triggers') }}