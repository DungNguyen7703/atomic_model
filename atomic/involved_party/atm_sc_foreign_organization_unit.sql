/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit
* Program name: Atomic Securities Company Foreign Organization Unit
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model cha (multi source) theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH.yaml + lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE.yaml: UNION ALL 2 model con (khoi phuc tu git 77a9749^).
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_sc_foreign_organization_unit_scms_sc_firm_foreign_branch') }}
UNION ALL
SELECT * FROM {{ ref('atm_sc_foreign_organization_unit_scms_sc_firm_foreign_rep_office') }}
