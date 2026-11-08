/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_workflowblockingactivitiesindex
* Program name: Staging TTHC.WORKFLOWBLOCKINGACTIVITIESINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(documentid AS int)                AS documentid
    , CAST(activityid AS string)             AS activityid
    , CAST(activityname AS string)           AS activityname
    , CAST(activityisstart AS decimal(38,0)) AS activityisstart
    , CAST(workflowtypeid AS string)         AS workflowtypeid
    , CAST(workflowid AS string)             AS workflowid
    , CAST(workflowcorrelationid AS string)  AS workflowcorrelationid
FROM {{ source('source_tthc', 'raw_workflowblockingactivitiesindex') }}