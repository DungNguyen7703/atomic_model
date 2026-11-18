/*
*--------------------------------------------------------------------*
* Program code: atm_custodian_bank
* Program name: Atomic Custodian Bank
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_custodian_bank_fims_bankmoni') }}
UNION ALL
SELECT * FROM {{ ref('atm_custodian_bank_fms_bank_moni') }}
