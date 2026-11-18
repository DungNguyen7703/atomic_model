/*
*--------------------------------------------------------------------*
* Program code: atm_ra_organization_unit
* Program name: Atomic Regulatory Authority Organization Unit
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_ra_organization_unit_nhnck_departments') }}
UNION ALL
SELECT * FROM {{ ref('atm_ra_organization_unit_nhnck_units') }}
