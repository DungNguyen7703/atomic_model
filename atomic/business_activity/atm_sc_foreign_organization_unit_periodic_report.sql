/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit_periodic_report
* Program name: Atomic Securities Company Foreign Organization Unit Periodic Report
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model cha (multi source) theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERIODIC_REPORT.yaml + lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE_PERIODIC_REPORT.yaml: UNION ALL 2 model con (khoi phuc tu git 77a9749^).
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_sc_foreign_organization_unit_periodic_report_scms_sc_firm_foreign_branch_periodic_report') }}
UNION ALL
SELECT * FROM {{ ref('atm_sc_foreign_organization_unit_periodic_report_scms_sc_firm_foreign_rep_office_periodic_report') }}
