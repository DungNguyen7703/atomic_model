/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_violation_snapshot
* Program name: Staging SCMS.ALERT_VIOLATION_SNAPSHOT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                         AS id
    , CAST(sc_firm_alert_violation_id AS decimal(19,0)) AS sc_firm_alert_violation_id
    , CAST(alert_run_id AS decimal(19,0))               AS alert_run_id
    , CAST(formula_snapshot AS string)                  AS formula_snapshot
    , CAST(condition_snapshot AS string)                AS condition_snapshot
    , CAST(created_at AS timestamp)                     AS created_at
FROM {{ source('source_scms', 'raw_alert_violation_snapshot') }}