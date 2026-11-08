/*
*--------------------------------------------------------------------*
* Program code: atm_securities_company
* Program name: Atomic Securities Company
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_securities_company_fims_securitiescompany') }}
UNION ALL
SELECT * FROM {{ ref('atm_securities_company_scms_sc_firm_info') }}
