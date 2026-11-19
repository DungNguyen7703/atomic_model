/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_private_corp_bond_service_orgs
* Program name: ODS HNX.PRIVATE_CORP_BOND_SERVICE_ORGS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao ODS theo LLD lld_HNX_PRIVATE_CORP_BOND_SERVICE_ORGS.yaml (UAT chua co). Cot nguon = source_columns cua LLD; can xac nhan bang hnx_stg.private_corp_bond_service_orgs ton tai.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(bond_code AS string) AS bond_code
    , CAST(issuer_name AS string) AS issuer_name
    , CAST(issued_volume AS bigint) AS issued_volume
    , CAST(secured_asset AS string) AS secured_asset
    , CAST(collateral_type AS string) AS collateral_type
    , CAST(advisory_org AS string) AS advisory_org
    , CAST(registrar_depository_org AS string) AS registrar_depository_org
    , CAST(issuance_agent_org AS string) AS issuance_agent_org
    , CAST(bondholder_representative_org AS string) AS bondholder_representative_org
    , CAST(underwriting_guarantor_org AS string) AS underwriting_guarantor_org
    , CAST(collateral_value AS decimal(23,2)) AS collateral_value
    , CAST(business_no AS string) AS business_no
    , CAST(report_year AS int) AS report_year
    , CAST(report_month AS int) AS report_month
    , CAST(report_day AS int) AS report_day
FROM {{ source('source_hnx', 'raw_private_corp_bond_service_orgs') }}
