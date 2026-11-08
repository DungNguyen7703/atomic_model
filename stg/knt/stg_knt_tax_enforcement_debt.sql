/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_enforcement_debt
* Program name: Staging KNT.TAX_ENFORCEMENT_DEBT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                AS id
    , CAST(taxpayer_tax_code AS string)              AS taxpayer_tax_code
    , CAST(taxpayer_name AS string)                  AS taxpayer_name
    , CAST(tax_authority_code AS string)             AS tax_authority_code
    , CAST(tax_authority_name AS string)             AS tax_authority_name
    , CAST(enforcement_method_code AS string)        AS enforcement_method_code
    , CAST(enforcement_method_name AS string)        AS enforcement_method_name
    , CAST(e_transaction_code AS string)             AS e_transaction_code
    , CAST(decision_number AS string)                AS decision_number
    , CAST(decision_date AS date)                    AS decision_date
    , CAST(enforced_amount AS string)                AS enforced_amount
    , CAST(enforced_entity_bank_account AS string)   AS enforced_entity_bank_account
    , CAST(account_opening_place AS string)          AS account_opening_place
    , CAST(income_managing_entity_name AS string)    AS income_managing_entity_name
    , CAST(income_managing_entity_address AS string) AS income_managing_entity_address
    , CAST(seized_assets AS string)                  AS seized_assets
    , CAST(asset_value AS string)                    AS asset_value
    , CAST(enforcement_date AS date)                 AS enforcement_date
    , CAST(enforcement_location AS string)           AS enforcement_location
    , CAST(asset_holder_name AS string)              AS asset_holder_name
    , CAST(asset_holder_code AS string)              AS asset_holder_code
    , CAST(asset_holder_address AS string)           AS asset_holder_address
    , CAST(enforced_entity_business_line AS string)  AS enforced_entity_business_line
    , CAST(decision_effective_from AS date)          AS decision_effective_from
    , CAST(decision_effective_to AS date)            AS decision_effective_to
    , CAST(msg_packet_id AS int)                     AS msg_packet_id
    , CAST(direct_tax_authority_code AS string)      AS direct_tax_authority_code
    , CAST(direct_tax_authority_name AS string)      AS direct_tax_authority_name
FROM {{ source('source_knt', 'raw_tax_enforcement_debt') }}