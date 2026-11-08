/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_info
* Program name: Atomic Listed Share Info – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_listed_share_info_vsdc_outstanding_shares') }}
UNION ALL
SELECT * FROM {{ ref('atm_listed_share_info_hnx_listed_securities_list') }}
UNION ALL
SELECT * FROM {{ ref('atm_listed_share_info_hose_listed_securities_list') }}
