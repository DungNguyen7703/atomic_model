/*
*--------------------------------------------------------------------*
* Program code: stg_knt_auditor
* Program name: Staging KNT.AUDITOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(audit_firm_id AS int)             AS audit_firm_id
    , CAST(auditor_name AS string)           AS auditor_name
    , CAST(practice_cert_number AS string)   AS practice_cert_number
    , CAST(approval_date AS date)            AS approval_date
    , CAST(approval_revocation_date AS date) AS approval_revocation_date
FROM {{ source('source_knt', 'raw_auditor') }}