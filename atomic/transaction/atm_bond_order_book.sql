/*
*--------------------------------------------------------------------*
* Program code: atm_bond_order_book
* Program name: Atomic Bond Order Book – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_bond_order_book_hnx_outright_order_book') }}
UNION ALL
SELECT * FROM {{ ref('atm_bond_order_book_hnx_repo_order_book') }}
UNION ALL
SELECT * FROM {{ ref('atm_bond_order_book_hnx_repo2_order_book') }}
