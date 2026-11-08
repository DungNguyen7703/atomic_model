/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Thêm nhánh FMS: TL_PROFILES, DISTRIBUTOR_AGENT
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_ip_postal_address_fims_investor') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fims_bankmoni') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fims_securitiescompany') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_agencies') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_for_brch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_insider') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_inves') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_represent') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_securities') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_stf_fg_brch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_bank_moni') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_tl_profiles') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_fms_distributor_agent') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_ids_company_profiles') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_nhnck_organizations') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_nhnck_professionals') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_nhnck_units') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_branch') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_info') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_insider_relation') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_related_person') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_rep_office') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_senior_personnel') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_shareholder') }}
UNION ALL
SELECT * FROM {{ ref('atm_ip_postal_address_scms_sc_firm_transaction_office') }}