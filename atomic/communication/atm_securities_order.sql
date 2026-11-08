/*
*--------------------------------------------------------------------*
* Program code: atm_securities_order
* Program name: Atomic Securities Order
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_securities_order_ordertrade_order_book_hnx') }}
UNION ALL
SELECT * FROM {{ ref('atm_securities_order_ordertrade_order_book_hose') }}
