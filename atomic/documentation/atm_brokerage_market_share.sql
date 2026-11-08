/*
*--------------------------------------------------------------------*
* Program code: atm_brokerage_market_share
* Program name: Atomic Brokerage Market Share – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_brokerage_market_share_hnx_brokerage_market_share') }}
UNION ALL
SELECT * FROM {{ ref('atm_brokerage_market_share_hose_brokerage_market_share') }}
