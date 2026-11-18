/*
*--------------------------------------------------------------------*
* Program code: atm_sc_organization_unit
* Program name: Atomic Securities Company Organization Unit
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_sc_organization_unit_scms_sc_firm_branch') }}
UNION ALL
SELECT * FROM {{ ref('atm_sc_organization_unit_scms_sc_firm_rep_office') }}
UNION ALL
SELECT * FROM {{ ref('atm_sc_organization_unit_scms_sc_firm_transaction_office') }}
