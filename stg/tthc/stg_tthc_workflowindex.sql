/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_workflowindex
* Program name: Staging TTHC.WORKFLOWINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(documentid AS int)                 AS documentid
    , CAST(workflowtypeid AS string)          AS workflowtypeid
    , CAST(workflowid AS string)              AS workflowid
    , CAST(workflowstatus AS string)          AS workflowstatus
    , CAST(createdutc AS string)              AS createdutc
    , CAST(pauseddurationms AS decimal(19,0)) AS pauseddurationms
    , CAST(definitionversion AS int)          AS definitionversion
FROM {{ source('source_tthc', 'raw_workflowindex') }}