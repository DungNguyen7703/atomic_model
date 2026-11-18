/*
*--------------------------------------------------------------------*
* Program code: atm_share_auction_result
* Program name: Atomic Share Auction Result – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_share_auction_result_hnx_share_auction') }}
UNION ALL
SELECT * FROM {{ ref('atm_share_auction_result_hose_share_auction') }}
