/*
*--------------------------------------------------------------------*
* Program code: stg_knt_high_risk_enterprise
* Program name: Staging KNT.HIGH_RISK_ENTERPRISE
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
    , CAST(enterprise_code AS string)        AS enterprise_code
    , CAST(enterprise_name AS string)        AS enterprise_name
    , CAST(hq_address AS string)             AS hq_address
    , CAST(managing_tax_authority AS string) AS managing_tax_authority
    , CAST(risk_assessment_year AS string)   AS risk_assessment_year
    , CAST(msg_packet_id AS int)             AS msg_packet_id
FROM {{ source('source_knt', 'raw_high_risk_enterprise') }}