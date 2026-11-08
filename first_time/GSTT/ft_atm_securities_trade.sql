-- [FIRST-TIME] ft_atm_securities_trade: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_securities_trade (config ft_target='securities_trade', macro macros/first_time).
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

SELECT * FROM {{ ft_ref('ft_atm_securities_trade_ordertrade_trade_book_hnx') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_securities_trade_ordertrade_trade_book_hose') }}
