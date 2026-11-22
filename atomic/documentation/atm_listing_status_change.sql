/*
*--------------------------------------------------------------------*
* Program code: atm_listing_status_change
* Program name: Atomic Listing Status Change – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_listing_status_change_hnx_listing_status_change') }}
UNION ALL
SELECT * FROM {{ ref('atm_listing_status_change_hose_listing_status_change') }}
