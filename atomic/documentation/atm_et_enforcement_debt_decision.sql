/*
*--------------------------------------------------------------------*
* Program code: atm_et_enforcement_debt_decision
* Program name: Atomic Et Enforcement Debt Decision
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_KNT_TAX_ENFORCEMENT_DEBT.yaml (Fact Append -> incremental_rebase append). UAT chua co model KNT nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        taxpayer_tax_code
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
    FROM {{ ref('ods_knt_tax_enforcement_debt') }}
)

SELECT
    {{ generate_surrogate_key_bigint('KNT_TAX_ENFORCEMENT_DEBT', "src.decision_number") }}    AS et_enforcement_debt_decision_id
    , CAST(src.decision_number AS string)                                                       AS et_enforcement_debt_decision_code
    , CAST('KNT_TAX_ENFORCEMENT_DEBT' AS string)                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('KNT_TAX_REGISTRATION_INFO', "src.taxpayer_tax_code") }} AS et_registration_id
    , CAST(src.taxpayer_tax_code AS string)                                                     AS et_registration_code
    , CAST(src.taxpayer_name AS string)                                                         AS taxpayer_nm
    , CAST(src.tax_authority_code AS string)                                                    AS tax_authority_code
    , CAST(src.tax_authority_name AS string)                                                    AS tax_authority_nm
    , CAST(src.enforcement_method_code AS string)                                               AS enforcement_method_code
    , CAST(src.enforcement_method_name AS string)                                               AS enforcement_method_nm
    , CAST(src.e_transaction_code AS string)                                                    AS electronic_transaction_code
    , CAST(src.decision_date AS date)                                                           AS decision_dt
    , CAST(src.enforced_amount AS string)                                                       AS enforced_amt
    , CAST(src.enforced_entity_bank_account AS string)                                          AS enforced_entity_bank_account_nbr
    , CAST(src.account_opening_place AS string)                                                 AS account_opening_place
    , CAST(src.income_managing_entity_name AS string)                                           AS income_managing_entity_nm
    , CAST(src.income_managing_entity_address AS string)                                        AS income_managing_entity_adr
    , CAST(src.seized_assets AS string)                                                         AS seized_assets_description
    , CAST(src.asset_value AS string)                                                           AS asset_val
    , CAST(src.enforcement_date AS date)                                                        AS enforcement_dt
    , CAST(src.enforcement_location AS string)                                                  AS enforcement_location
    , CAST(src.asset_holder_name AS string)                                                     AS asset_holder_nm
    , CAST(src.asset_holder_code AS string)                                                     AS asset_holder_code
    , CAST(src.asset_holder_address AS string)                                                  AS asset_holder_adr
    , CAST(src.enforced_entity_business_line AS string)                                         AS enforced_entity_business_line_nm
    , CAST(src.decision_effective_from AS date)                                                 AS decision_effective_from_dt
    , CAST(src.decision_effective_to AS date)                                                   AS decision_effective_to_dt
    , CAST(src.direct_tax_authority_code AS string)                                             AS direct_tax_authority_code
    , CAST(src.direct_tax_authority_name AS string)                                             AS direct_tax_authority_nm
    , CAST(src.msg_packet_id AS string)                                                         AS message_packet_id
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                            AS data_dt
FROM src
