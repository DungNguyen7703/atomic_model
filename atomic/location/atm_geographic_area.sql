/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area
* Program name: Atomic Geographic Area
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_geographic_area_ecat_country') }}
UNION ALL
SELECT * FROM {{ ref('atm_geographic_area_ecat_province') }}
UNION ALL
SELECT * FROM {{ ref('atm_geographic_area_ecat_region') }}
UNION ALL
SELECT * FROM {{ ref('atm_geographic_area_ecat_ward') }}
