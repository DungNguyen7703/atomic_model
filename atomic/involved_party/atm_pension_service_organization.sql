/*
*--------------------------------------------------------------------*
* Program code: atm_pension_service_organization
* Program name: Atomic Pension Service Organization
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model cha (UNION ALL) theo lld_FMS_PENSION_AGENT / lld_FMS_PENSION_PROVIDER.
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_pension_service_organization_fms_pension_agent') }}
UNION ALL
SELECT * FROM {{ ref('atm_pension_service_organization_fms_pension_provider') }}
