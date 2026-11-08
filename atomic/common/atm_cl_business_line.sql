/*
*--------------------------------------------------------------------*
* Program code: atm_cl_business_line
* Program name: Atomic Classification Business Line
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_cl_business_line_ecat_business_line_level_1') }}
UNION ALL
SELECT * FROM {{ ref('atm_cl_business_line_ecat_business_line_level_2') }}
