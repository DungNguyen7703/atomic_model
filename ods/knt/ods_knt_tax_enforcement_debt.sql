/*
*--------------------------------------------------------------------*
* Program code: ods_knt_tax_enforcement_debt
* Program name: ODS KNT.TAX_ENFORCEMENT_DEBT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-12		ngoc.pham		Bo cot data_dt khoi SELECT cho khop DDL (Truncate then Insert)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , taxpayer_tax_code
    , taxpayer_name
    , tax_authority_code
    , tax_authority_name
    , enforcement_method_code
    , enforcement_method_name
    , e_transaction_code
    , decision_number
    , decision_date
    , enforced_amount
    , enforced_entity_bank_account
    , account_opening_place
    , income_managing_entity_name
    , income_managing_entity_address
    , seized_assets
    , asset_value
    , enforcement_date
    , enforcement_location
    , asset_holder_name
    , asset_holder_code
    , asset_holder_address
    , enforced_entity_business_line
    , decision_effective_from
    , decision_effective_to
    , msg_packet_id
    , direct_tax_authority_code
    , direct_tax_authority_name
FROM {{ ref('stg_knt_tax_enforcement_debt') }}