/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Thêm nhánh FMS: AGENCIES, TL_PROFILES, DISTRIBUTOR_AGENT
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS] Them nhanh SCMS: BANK, SC_FIRM_FOREIGN_BRANCH, SC_FIRM_FOREIGN_BRANCH_PERSONNEL, SC_FIRM_FOREIGN_REP_OFFICE, SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL, SC_FIRM_MAJOR_SHAREHOLDER_RELATION, SC_FIRM_REP_OFFICE, SC_FIRM_TRANSACTION_OFFICE
*--------------------------------------------------------------------*
*/
SELECT * FROM {{ ref('atm_ip_alternative_identification_fims_bankmoni') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fims_investor') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fims_securitiescompany') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fims_tradingrepresentative') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_ids_company_profiles') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_ids_company_relationship') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_ids_identity') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_for_brch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_funds') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_insider') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_inves') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_mb_fund') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_represent') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_securities') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_stf_fg_brch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_bank_moni') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_agencies') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_tl_profiles') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_fms_distributor_agent') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_nhnck_identity_info_c06s') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_nhnck_professionals') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_branch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_info') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_insider_relation') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_related_person') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_senior_personnel') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_shareholder') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_shareholder_relation') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_shareholder_representative') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_bank') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_foreign_branch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_foreign_branch_personnel') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_foreign_rep_office') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_foreign_rep_office_personnel') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_major_shareholder_relation') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_rep_office') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_alternative_identification_scms_sc_firm_transaction_office') }}
