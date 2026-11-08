/*
*--------------------------------------------------------------------*
* Program code: stg_tthc_audit_audittraileventindex
* Program name: Staging TTHC.AUDIT_AUDITTRAILEVENTINDEX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo TTHC_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(documentid AS int)            AS documentid
    , CAST(eventid AS string)            AS eventid
    , CAST(category AS string)           AS category
    , CAST(name AS string)               AS name
    , CAST(correlationid AS string)      AS correlationid
    , CAST(userid AS string)             AS userid
    , CAST(normalizedusername AS string) AS normalizedusername
    , CAST(createdutc AS string)         AS createdutc
FROM {{ source('source_tthc', 'raw_audit_audittraileventindex') }}