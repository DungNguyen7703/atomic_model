/*
*--------------------------------------------------------------------*
* Program code: atm_dr_structure
* Program name: Atomic Dynamic Report Structure - Multi Source
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Chuyển sang multi-source (UNION ALL model ephemeral theo nguồn), giống atm_ip_alternative_identification.
*                                       Nhánh: FMS_ITEM_LIST, SCMS_ITEM_LIST.
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_dr_structure_fms_item_list') }}
UNION ALL
SELECT * FROM {{ ref('atm_dr_structure_scms_item_list') }}
