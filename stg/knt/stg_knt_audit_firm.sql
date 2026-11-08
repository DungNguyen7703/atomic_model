/*
*--------------------------------------------------------------------*
* Program code: stg_knt_audit_firm
* Program name: Staging KNT.AUDIT_FIRM
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
    , CAST(decision_number AS string)        AS decision_number
    , CAST(decision_date AS date)            AS decision_date
    , CAST(name AS string)                   AS name
    , CAST(address AS string)                AS address
    , CAST(phone AS string)                  AS phone
    , CAST(fax AS string)                    AS fax
    , CAST(approval_year AS string)          AS approval_year
    , CAST(approved_auditor_count AS string) AS approved_auditor_count
    , CAST(tax_code AS string)               AS tax_code
    , CAST(msg_packet_id AS int)             AS msg_packet_id
    , CAST(business_reg_cert AS string)      AS business_reg_cert
    , CAST(guid AS string)                   AS guid
FROM {{ source('source_knt', 'raw_audit_firm') }}