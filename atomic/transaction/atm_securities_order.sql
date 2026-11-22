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

SELECT * FROM {{ ref('atm_securities_order_hnx_order_book') }}
UNION ALL
SELECT * FROM {{ ref('atm_securities_order_hose_order_book') }}
