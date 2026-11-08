/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_enforcement_invoice
* Program name: Staging KNT.TAX_ENFORCEMENT_INVOICE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(taxpayer_tax_code AS string)             AS taxpayer_tax_code
    , CAST(taxpayer_name AS string)                 AS taxpayer_name
    , CAST(direct_tax_authority_code AS string)     AS direct_tax_authority_code
    , CAST(direct_tax_authority_name AS string)     AS direct_tax_authority_name
    , CAST(enforcement_method_code AS string)       AS enforcement_method_code
    , CAST(enforcement_method_name AS string)       AS enforcement_method_name
    , CAST(e_transaction_code AS string)            AS e_transaction_code
    , CAST(decision_number AS string)               AS decision_number
    , CAST(decision_date AS date)                   AS decision_date
    , CAST(enforced_entity_business_line AS string) AS enforced_entity_business_line
    , CAST(decision_effective_from AS date)         AS decision_effective_from
    , CAST(decision_effective_to AS date)           AS decision_effective_to
    , CAST(notice_taxpayer_tax_code AS string)      AS notice_taxpayer_tax_code
    , CAST(notice_taxpayer_name AS string)          AS notice_taxpayer_name
    , CAST(notice_code AS string)                   AS notice_code
    , CAST(notice_name AS string)                   AS notice_name
    , CAST(basis_decision_number AS string)         AS basis_decision_number
    , CAST(basis_decision_date AS date)             AS basis_decision_date
    , CAST(notice_debt_amount AS string)            AS notice_debt_amount
    , CAST(notice_debt_date AS date)                AS notice_debt_date
    , CAST(validity_flag AS string)                 AS validity_flag
    , CAST(msg_packet_id AS int)                    AS msg_packet_id
    , CAST(guid AS string)                          AS guid
FROM {{ source('source_knt', 'raw_tax_enforcement_invoice') }}