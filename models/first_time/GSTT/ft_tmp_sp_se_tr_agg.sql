/*
*--------------------------------------------------------------------*
* Program code: ft_tmp_sp_se_tr_agg
* Program name: Bang tam first-time cua ft_dtm_fct_stock_portfolio_snpst
*--------------------------------------------------------------------*
* Modified management
* Date			User				Description
* 2026-11-09		tuan.nguyenvanb		[TACH BANG TAM, khong doi logic] se_tr_agg (1 lan quet atm_securities_trade)
*                                       Cat NGUYEN VAN cac CTE tu ft_dtm_fct_stock_portfolio_snpst de moi cau lenh co ke hoach thuc thi nho (1 cau qua lon lam driver Spark treo).
*                                       Bang tam first-time (materialized table, ghi de moi lan chay), CHI phuc vu model ft_dtm_fct_stock_portfolio_snpst - phai chay TRUOC model do.
*--------------------------------------------------------------------*
*/

WITH -- [TOI UU 2026-10-24, chi ban first_time] 9 CTE se_tr_mt, se_tr_mt_matched, se_tr_dv, se_tr_dv_ng, se_tr_ng, se_tr_ng_frn, se_tr_dv_frn,
-- se_tr_bd, se_tr_bd_ng truoc day moi CTE quet lai ft_atm_securities_trade ca nam -> gop thanh 1 lan quet (se_tr_agg) bang
-- SUM(CASE WHEN dieu_kien THEN ... END) (khong ELSE 0 o lop ngoai -> nhom khong co giao dich van ra NULL nhu LEFT JOIN cu).
-- Dieu kien loc/cong thuc tung cot GIU NGUYEN; da doi chieu ket qua cu/moi tren du lieu mau (ke ca NULL vs 0). Ban goc cac CTE nam trong khoi comment jinja ben duoi.
se_tr_agg AS (
    SELECT
        security_symbol_code,
        trade_dt,
        -- se_tr_mt (khop lenh co phieu/CCQ, gom ca thoa thuan)
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN execution_vol END)                                                            AS total_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN execution_val END)                                                            AS total_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END END) AS foreign_buy_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END END) AS foreign_sell_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_val ELSE 0 END END) AS foreign_buy_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_val ELSE 0 END END) AS foreign_sell_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E') THEN execution_vol ELSE 0 END END)  AS proprietary_buy_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E') THEN execution_vol ELSE 0 END END) AS proprietary_sell_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E') THEN execution_val ELSE 0 END END)  AS proprietary_buy_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') THEN CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E') THEN execution_val ELSE 0 END END) AS proprietary_sell_val,
        -- se_tr_mt_matched (khop lenh thuan, loai tru thoa thuan)
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS total_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS total_matched_val,
        -- se_tr_dv (phai sinh)
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS total_derivative_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS total_derivative_val,
        -- se_tr_ng (thoa thuan co phieu/CCQ)
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS total_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS total_negotiated_val,
        -- se_tr_ng_frn (mua rong NDTNN thoa thuan)
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END END)
            - SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END END) AS foreign_net_negotiated_vol,
        -- se_tr_dv_frn (NDTNN phai sinh)
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END END)
            - SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END END) AS foreign_net_derivative_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('F','E') THEN execution_vol ELSE 0 END END)  AS foreign_buy_derivative_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
                 THEN CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('F','E') THEN execution_vol ELSE 0 END END) AS foreign_sell_derivative_vol,
        -- se_tr_bd (trai phieu)
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS bond_trading_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS bond_trading_val,
        -- se_tr_dv_ng (thoa thuan phai sinh)
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS total_derivative_negotiated_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS total_derivative_negotiated_val,
        -- se_tr_bd_ng (thoa thuan trai phieu)
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol END) AS bond_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val END) AS bond_negotiated_val,
        -- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc a] Lo chan / lo le x khop lenh / thoa thuan x co phieu, phai sinh, trai phieu (cung 1 lan quet)
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS round_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS round_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_vol END) AS odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_val END) AS odd_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_vol END) AS odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_val END) AS odd_lot_negotiated_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS derivative_round_lot_matched_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS derivative_round_lot_matched_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS derivative_round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS derivative_round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G4') THEN execution_vol END) AS derivative_odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G4') THEN execution_val END) AS derivative_odd_lot_matched_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T4') THEN execution_vol END) AS derivative_odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T4') THEN execution_val END) AS derivative_odd_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS bond_round_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS bond_round_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS bond_round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS bond_round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G4') THEN execution_vol END) AS bond_odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G4') THEN execution_val END) AS bond_odd_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T4') THEN execution_vol END) AS bond_odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T4') THEN execution_val END) AS bond_odd_lot_negotiated_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO','DVX','BDO','HCX')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
)

SELECT * FROM se_tr_agg
