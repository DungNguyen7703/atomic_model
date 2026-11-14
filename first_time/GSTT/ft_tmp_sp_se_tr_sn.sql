/*
*--------------------------------------------------------------------*
* Program code: ft_tmp_sp_se_tr_sn
* Program name: Bang tam first-time cua ft_dtm_fct_stock_portfolio_snpst
*--------------------------------------------------------------------*
* Modified management
* Date			User				Description
* 2026-11-09		tuan.nguyenvanb		[TACH BANG TAM, khong doi logic] se_tr_sn_all (ban tin cuoi ngay tu snapshot) + se_tr_sn
*                                       Cat NGUYEN VAN cac CTE tu ft_dtm_fct_stock_portfolio_snpst de moi cau lenh co ke hoach thuc thi nho (1 cau qua lon lam driver Spark treo).
*                                       Bang tam first-time (materialized table, ghi de moi lan chay), CHI phuc vu model ft_dtm_fct_stock_portfolio_snpst - phai chay TRUOC model do.
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    -- [TOI UU 2026-10-24, chi ban first_time] Thay row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) + rn = 1
    -- bang max_by(struct(...), struct(trading_time, sequence)) + GROUP BY: van lay dong co (trading_time, sequence) lon nhat moi (ticker, ngay),
    -- nhung la hash aggregate (gop truoc khi shuffle) thay vi sort toan bo bang snapshot ca nam.
    SELECT
        ticker_symbol AS symbol,
        ds_snpst_dt AS trading_dt,   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt (first_time: ds_snpst_dt = ngay giao dich)
        latest.trading_time AS trading_time,
        latest.close_price AS close_price,
        latest.reference_price AS reference_price,
        latest.high_price AS high_price,
        latest.low_price AS low_price,
        latest.open_price AS open_price,
        latest.ceiling_price AS ceiling_price,
        latest.floor_price AS floor_price,
        latest.vol_weighted_average_price AS vol_weighted_average_price,
        latest.floor_code AS floor_code,
        latest.stock_tp_code AS stock_tp_code,
        latest.underlying_symbol AS underlying_symbol,
        latest.isin_code AS isin_code
    FROM (
        SELECT
            ticker_symbol,
            ds_snpst_dt,
            max_by(
                struct(trading_time, close_price, reference_price, high_price, low_price, open_price, ceiling_price, floor_price, vol_weighted_average_price, floor_code, stock_tp_code, underlying_symbol, isin_code),
                struct(trading_time, sequence)
            ) AS latest
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
        GROUP BY ticker_symbol, ds_snpst_dt
    ) t
),

-- [SUA 2026-09-11 theo logic test moi] atm_securities_trade (nguon so lenh/khop lenh) dung
-- KHAC khoa dinh danh giua 2 san: HNX/UPCOM/FDS (floor_code 02/04/03) dung issue_code = ISIN
-- (xem atm_securities_trade_ordertrade_trade_book_hnx.sql: security_symbol_code = issue_code),
-- con HOSE (floor_code 10) dung symbol thuong (atm_...hose.sql: security_symbol_code = symbol).
-- Truoc day toan bo cac JOIN ben duoi deu dung symbol - DUNG cho HOSE nhung SAI cho HNX/UPCOM/
-- FDS (so nham ticker voi ISIN -> LEFT JOIN ra NULL toan bo du lieu khop lenh cua cac san nay).
-- Tuong tu, JOIN toi Public Company (nganh/cong ty) cho chung quyen (stock_tp_code='4') phai
-- dung underlying_symbol (ma co so) thay vi ma CW cua chinh no.
se_tr_sn AS (
    SELECT
        symbol,
        trading_dt,
        close_price,
        reference_price,
        high_price,
        low_price,
        open_price,
        ceiling_price,
        floor_price,
        vol_weighted_average_price,
        floor_code,
        stock_tp_code,
        CASE WHEN floor_code IN ('02','04','03') THEN isin_code ELSE symbol END AS trade_join_symbol,
        -- [SUA 2026-09-14] Bo nhanh trai phieu (stock_tp_code='1') khoi day - trai phieu
        -- gio join Nganh rieng qua 3 ky tu dau symbol (xem JOIN pu_co o SELECT cuoi), khong
        -- con nhet issuer_nm vao day de so voi equity_ticker_symbol (sai kieu du lieu).
        CASE
            WHEN stock_tp_code = '4' THEN underlying_symbol
            ELSE symbol
        END AS company_join_symbol
    FROM se_tr_sn_all
)

SELECT * FROM se_tr_sn
