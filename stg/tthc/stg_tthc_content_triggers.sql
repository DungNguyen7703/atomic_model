/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_content_triggers
* Program name: Staging TTHC.CONTENT_TRIGGERS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(name AS string)                  AS name
    , CAST(description AS string)           AS description
    , CAST(contenttype AS string)           AS contenttype
    , CAST(eventtype AS string)             AS eventtype
    , CAST(enabled AS int)                  AS enabled
    , CAST(conditionenabled AS int)         AS conditionenabled
    , CAST(conditionexpression AS string)   AS conditionexpression
    , CAST(executioncount AS decimal(19,0)) AS executioncount
    , CAST(successcount AS decimal(19,0))   AS successcount
    , CAST(failurecount AS decimal(19,0))   AS failurecount
    , CAST(lastexecutedat AS string)        AS lastexecutedat
    , CAST(version AS int)                  AS version
    , CAST(createdat AS string)             AS createdat
    , CAST(updatedat AS string)             AS updatedat
    , CAST(createdby AS string)             AS createdby
    , CAST(updatedby AS string)             AS updatedby
FROM {{ source('source_tthc', 'raw_content_triggers') }}