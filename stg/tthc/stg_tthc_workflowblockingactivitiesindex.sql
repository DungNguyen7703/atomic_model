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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); kieu decimal(38,0) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                    AS id
    , CAST(documentid AS bigint)            AS documentid
    , CAST(activityid AS string)             AS activityid
    , CAST(activityname AS string)           AS activityname
    , CAST(activityisstart AS int)          AS activityisstart
    , CAST(workflowtypeid AS string)         AS workflowtypeid
    , CAST(workflowid AS string)             AS workflowid
    , CAST(workflowcorrelationid AS string)  AS workflowcorrelationid
FROM {{ source('source_tthc', 'raw_workflowblockingactivitiesindex') }}