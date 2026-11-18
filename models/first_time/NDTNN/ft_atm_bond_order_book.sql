-- [FIRST-TIME] ft_atm_bond_order_book: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_bond_order_book (config ft_target='bond_order_book', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_bond_order_book
* Program name: Atomic Bond Order Book – Multi Source (HNX.OUTRIGHT_ORDER_BOOK, HNX.REPO_ORDER_BOOK, HNX.REPO2_ORDER_BOOK)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao tu atm_bond_order_book (daily): UNION ALL 3 ban ft_
*                                       ephemeral (outright/repo/repo2 order book), cho phep ft_dtm_foreign_investor_trading_detail_rpt
*                                       va ft_dtm_foreign_investor_trading_statistics_rpt doc qua ft_ref() thay vi ref() thuong.
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ft_ref('ft_atm_bond_order_book_hnx_outright_order_book') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_bond_order_book_hnx_repo_order_book') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_bond_order_book_hnx_repo2_order_book') }}
