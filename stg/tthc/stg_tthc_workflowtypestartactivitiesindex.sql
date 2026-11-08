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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(documentid AS int)           AS documentid
    , CAST(workflowtypeid AS string)    AS workflowtypeid
    , CAST(name AS string)              AS name
    , CAST(isenabled AS decimal(38,0))  AS isenabled
    , CAST(startactivityid AS string)   AS startactivityid
    , CAST(startactivityname AS string) AS startactivityname
FROM {{ source('source_tthc', 'raw_workflowtypestartactivitiesindex') }}