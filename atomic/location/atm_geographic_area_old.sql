/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area_old
* Program name: Atomic Geographic Area Old
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_geographic_area_old_ecat_district_old') }}
UNION ALL
SELECT * FROM {{ ref('atm_geographic_area_old_ecat_province_old') }}
UNION ALL
SELECT * FROM {{ ref('atm_geographic_area_old_ecat_ward_old') }}
