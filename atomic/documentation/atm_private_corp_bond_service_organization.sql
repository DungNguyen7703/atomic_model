/*
*--------------------------------------------------------------------*
* Program code: atm_private_corp_bond_service_organization
* Program name: Atomic Private Corp Bond Service Organization
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_HNX_PRIVATE_CORP_BOND_SERVICE_ORGS.yaml (UAT chua co): entity private_corp_bond_service_organization, snapshot nhu cac entity HNX khac.
*--------------------------------------------------------------------*
*/

WITH x AS (
    SELECT
        bond_code
        , issuer_name
        , issued_volume
        , secured_asset
        , collateral_type
        , advisory_org
        , registrar_depository_org
        , issuance_agent_org
        , bondholder_representative_org
        , underwriting_guarantor_org
        , collateral_value
        , business_no
        , report_year
        , report_month
        , report_day
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_private_corp_bond_service_orgs') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_SERVICE_ORGS', "x.bond_code") }} AS private_corp_bond_service_organization_id
    , CAST('HNX_PRIVATE_CORP_BOND_SERVICE_ORGS' AS string) AS src_stm_code
    , CAST(x.bond_code AS string) AS bond_code
    , CAST(x.issuer_name AS string) AS issuer_nm
    , CAST(x.issued_volume AS bigint) AS issued_bond_vol
    , CAST(x.secured_asset AS string) AS secured_asset
    , CAST(x.collateral_type AS string) AS collateral_tp
    , CAST(x.advisory_org AS string) AS advisory_organization_nm
    , CAST(x.registrar_depository_org AS string) AS registrar_depository_organization_nm
    , CAST(x.issuance_agent_org AS string) AS issuance_agent_organization_nm
    , CAST(x.bondholder_representative_org AS string) AS bondholder_representative_organization_nm
    , CAST(x.underwriting_guarantor_org AS string) AS underwriting_guarantor_organization_nm
    , CAST(x.collateral_value AS decimal(23,2)) AS collateral_val
    , CAST(x.business_no AS string) AS business_registration_nbr
    , CAST(x.report_year AS int) AS rpt_year
    , CAST(x.report_month AS int) AS rpt_month
    , CAST(x.report_day AS int) AS rpt_day
FROM x
