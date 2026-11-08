-- [FIRST-TIME] ft_atm_securities_order: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_securities_order (config ft_target='securities_order', macro macros/first_time).
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

SELECT * FROM {{ ft_ref('ft_atm_securities_order_ordertrade_order_book_hnx') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_securities_order_ordertrade_order_book_hose') }}
