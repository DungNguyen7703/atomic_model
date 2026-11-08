/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_net_trade_snpst
* Program name: Fact Foreign Net Trade Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - atm_securities_trade: incremental_rebase/append, KHONG co _hstr, loc
*   truc tiep theo trade_dt (xem chi tiet o dtm_fct_order_size_snpst.sql).
* - foreign_buy_val / foreign_sell_val tinh bang 1 lan quet SUM(CASE WHEN)
*   thay vi 2 CTE tach roi + JOIN, ket qua tuong duong nhung hieu qua hon
*   tren Spark.
* - buy_foreign_investor_tp_code / sell_foreign_investor_tp_code: '10','20'
*   theo dung danh sach ma NDTNN da chot trong yeu cau.
* - [2026-09-23] SUA LOI: filter market_id_code truoc day dung ('STO','STX',
*   'UPX') dung nguyen van chu 'STO' trong LLD (DTM_PTTT_fct_foreign_net_trade
*   _snpst.csv), nhung day la LOI COPY-PASTE cua thiet ke: doi chieu voi toan
*   bo cac fact co phieu khac trong PTTT (dtm_fct_order_size_snpst,
*   dtm_fct_proprietary_net_trade_snpst, dtm_fct_market_statistics_snpst) va
*   ca module GSTT (dtm_fct_stock_portfolio_snpst,
*   dtm_fct_investor_category_trading_snpst, ...) deu dung ma thuc te la
*   'STK' (khong ton tai 'STO' o bat ky noi nao khac trong repo), da sua lai
*   thanh 'STK' cho dung convention thuc te.
* 2026-10-13			tuan.nguyenvanb		Ap dung LLD commit 88a297c0 (O_PTTT_46): them dieu kien
*									board_tp_code IN ('G1','G2','G3','G4','G7','G8') vao se_tr (loai board
*									thoa thuan T1/T3/T4/T6). Khong doi cot/kieu du lieu nen khong can ALTER.
*--------------------------------------------------------------------*
* 2026-10-19			tuan.nguyenvanb		Ap dung LLD commit 05c7c2d3 (O_PTTT_51, BA STT 16): NDTNN theo ky tu thu 4 cua so tai khoan MUA/BAN
*									IN ('E','F') thay cho buy/sell_foreign_investor_tp_code IN ('10','20'); BO loc board G1..G8 (dao O_PTTT_46
*									theo BA - SQL BA khong loc board).
*									Khong doi ten/kieu/vi tri cot output nen khong can ALTER. market_id_code HOSE van 'STK' (LLD ghi 'STO').
*/

WITH se_tr AS (
    SELECT
        trade_dt
        , security_symbol_code
        , execution_val
        , buy_account_nbr
        , sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code IN ('STK','STX','UPX')
),

agg AS (
    SELECT
        se_tr.trade_dt
        , se_tr.security_symbol_code
        , SUM(CASE WHEN SUBSTR(se_tr.buy_account_nbr, 4, 1) IN ('E','F') THEN se_tr.execution_val ELSE 0 END)  AS foreign_buy_val
        , SUM(CASE WHEN SUBSTR(se_tr.sell_account_nbr, 4, 1) IN ('E','F') THEN se_tr.execution_val ELSE 0 END) AS foreign_sell_val
    FROM se_tr
    GROUP BY
        se_tr.trade_dt
        , se_tr.security_symbol_code
)

SELECT
    CAST(date_format(agg.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(agg.security_symbol_code AS string)               AS security_symbol_code,
    CAST(agg.foreign_buy_val AS decimal(23,2))             AS foreign_buy_val,
    CAST(agg.foreign_sell_val AS decimal(23,2))            AS foreign_sell_val,
    CAST(agg.foreign_buy_val - agg.foreign_sell_val AS decimal(23,2)) AS foreign_net_val
FROM agg
