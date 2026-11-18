/*
*--------------------------------------------------------------------*
* Program code: atm_mdds_order_book
* Program name: Atomic MDDS Order Book – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_mdds_order_book_hnx_mdds_order_book') }}
UNION ALL
SELECT * FROM {{ ref('atm_mdds_order_book_hose_mdds_order_book') }}
