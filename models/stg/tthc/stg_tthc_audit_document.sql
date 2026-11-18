/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_audit_document
* Program name: Staging TTHC.AUDIT_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)         AS id
    , CAST(type AS string)    AS type
    , CAST(content AS string) AS content
    , CAST(version AS int)    AS version
FROM {{ source('source_tthc', 'raw_audit_document') }}