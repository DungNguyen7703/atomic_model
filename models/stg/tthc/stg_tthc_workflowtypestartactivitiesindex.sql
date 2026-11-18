/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_workflowtypestartactivitiesindex
* Program name: Staging TTHC.WORKFLOWTYPESTARTACTIVITIESINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo staging_tthc.sql, brd_TTHC.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(documentid AS int)           AS documentid
    , CAST(workflowtypeid AS string)    AS workflowtypeid
    , CAST(name AS string)              AS name
    , CAST(isenabled AS int)            AS isenabled
    , CAST(startactivityid AS string)   AS startactivityid
    , CAST(startactivityname AS string) AS startactivityname
FROM {{ source('source_tthc', 'raw_workflowtypestartactivitiesindex') }}