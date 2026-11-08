/*
*--------------------------------------------------------------------*
* Program code: atm_securities_trade
* Program name: Atomic Securities Trade
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_securities_trade_ordertrade_trade_book_hnx') }}
UNION ALL
SELECT * FROM {{ ref('atm_securities_trade_ordertrade_trade_book_hose') }}
