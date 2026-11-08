-- [FIRST-TIME] ft_dtm_foreign_investor_trading_detail_rpt: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_foreign_investor_trading_detail_rpt (config ft_target='foreign_investor_trading_detail_rpt', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_trading_detail_rpt
* Program name: Dtm Foreign Investor Trading Detail Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-26		nghia.le			[FIX] Dong bo LLD (sua 2026-10-20): them ORDER BY report_dt, account_nbr, symbol,
*									trade_direction_code, src_stm_code (grain 5 thanh phan) - dong bo voi daily.
* 2026-10-22		nghia.le			[FIRST-TIME NDTNN] Bond Order Book da co ban ft_ rieng (ft_atm_bond_order_book):
*									doi {{ ref('atm_bond_order_book') }} -> {{ ft_ref('ft_atm_bond_order_book') }}.
*									Foreign Investor van dung ref() thuong (full lich su, khong loc ngay) vi nguon
*									stg_fims_investor doc thang tu bang OLTP hien hanh (source_fims.raw_investor),
*									khong co lich su nhieu ngay o nguon nen chua the thiet ke ban ft_ rieng.
* 2026-10-21		nghia.le			[FIX] Dong bo LLD: bo sung filter stock_tp_code IN ('1','2','3','4','6') khi JOIN Securities
*									Dimension de lay symbol (LLD yeu cau loai bo ma CK khac 5 loai nay hoac khong co trong
*									Securities Dimension) - truoc do se_di thieu dieu kien nay, dong bo voi daily.
* 2026-10-21		nghia.le			Dong bo LLD 2026-10-21: them nhanh TPCP (Bond Order Book HNX Outright/Repo/Repo2) UNION ALL
*									vao ca 2 phia BUY/SELL; them cot investor_nm (LEFT JOIN atm_foreign_investor theo MSGD 6 ky
*									tu cuoi). Bond Order Book va Foreign Investor chua co ban ft_ rieng nen dung ref()
*									thuong (full lich su, khong loc ngay), giong pattern da ap dung o ft_dtm_foreign_investor_trading_statistics_rpt.
* 2026-10-18		nghia.le			[FIRST-TIME NDTNN] Securities Dimension doc _hstr THEO NGAY giao dich (ft_dtm_securities_dim) thay cho bang MAIN ACTIVE - khop daily.
* 2026-10-17		nghia.le			Dong bo LLD 2026-10-17: nhan dien NDTNN doi sang ky tu thu 4 cua so tai khoan
*									(SUBSTR(buy/sell_account_nbr,4,1) IN ('E','F')), thay Buy/Sell Foreign Investor
*									Type Code; execution_vol CAST bigint (truoc int) khop LLD/DDL.
* 2026-10-16		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao tu dtm_foreign_investor_trading_detail_rpt (daily):
*                                       - Bo loc trade_dt = etl_date (nap toan bo lich su ft_atm_securities_trade trong 1 lan,
*                                         moi ngay 1 partition report_dt nhu daily).
*                                       - dtm_securities_dim doc bang MAIN (ds_rcrd_st = 'ACTIVE') thay vi _hstr tai etl_date.
*                                       - JOIN co OR (HOSE symbol / HNX isin_code) chi chay tren tap (san, ma CK) khac nhau
*                                         (code_map), roi JOIN bang ve se_tr. Giu nguyen so dong dim khop cua tung ma.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt,
        security_symbol_code,
        src_stm_code,
        buy_account_nbr,
        buy_account_holder_nm,
        sell_account_nbr,
        sell_account_holder_nm,
        execution_vol,
        execution_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    -- [FT-ORIG]     AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

se_di AS (
    SELECT
        symbol,
        isin_code,
        stock_tp_code,
        ds_snpst_dt
    -- [FT-ORIG] FROM {{ ref('dtm_securities_dim') }}_hstr WHERE ds_snpst_dt = etl_date AND ds_rcrd_st = 'ACTIVE'
    FROM {{ ft_ref('ft_dtm_securities_dim') }}_hstr   -- [FT-NEW 2026-10-18] _hstr theo NGAY (khong doc MAIN) - khop daily
    WHERE ds_rcrd_st = 'ACTIVE'
        AND stock_tp_code IN ('1','2','3','4','6')
),

-- [FT-NEW] Lookup theo NGAY giao dich, tach 2 nhanh bang (HOSE theo symbol, HNX theo isin_code) thay cho 1 JOIN co OR.
code_map AS (
    SELECT
        cd.trade_dt,
        cd.src_stm_code,
        cd.security_symbol_code,
        se_di.symbol
    FROM (SELECT DISTINCT trade_dt, src_stm_code, security_symbol_code FROM se_tr WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE') cd
    INNER JOIN se_di
        ON  se_di.ds_snpst_dt = cd.trade_dt
        AND se_di.symbol = cd.security_symbol_code
    UNION ALL
    SELECT
        cd.trade_dt,
        cd.src_stm_code,
        cd.security_symbol_code,
        se_di.symbol
    FROM (SELECT DISTINCT trade_dt, src_stm_code, security_symbol_code FROM se_tr WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX') cd
    INNER JOIN se_di
        ON  se_di.ds_snpst_dt = cd.trade_dt
        AND se_di.isin_code = cd.security_symbol_code
),

se_tr_dim AS (
    SELECT
        se_tr.*,
        code_map.symbol
    FROM se_tr
    INNER JOIN code_map
        ON  code_map.trade_dt = se_tr.trade_dt
        AND code_map.src_stm_code = se_tr.src_stm_code
        AND code_map.security_symbol_code = se_tr.security_symbol_code
),

se_tr_buy AS (
    SELECT
        trade_dt,
        buy_account_nbr        AS account_nbr,
        symbol,
        'BUY'                  AS trade_direction_code,
        buy_account_holder_nm  AS account_holder_nm,
        execution_vol,
        execution_val,
        src_stm_code
    FROM se_tr_dim
    WHERE SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
),

se_tr_sell AS (
    SELECT
        trade_dt,
        sell_account_nbr        AS account_nbr,
        symbol,
        'SELL'                  AS trade_direction_code,
        sell_account_holder_nm  AS account_holder_nm,
        execution_vol,
        execution_val,
        src_stm_code
    FROM se_tr_dim
    WHERE SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
),

-- [FT-NEW 2026-10-22] Bond Order Book: da co ban ft_ rieng, doc qua ft_ref() (khong loc ngay, nap toan bo lich su).
bo_bo AS (
    SELECT
        trading_date,
        bond_code,
        buying_account_no,
        selling_account_no,
        order_bond_quantity,
        order_book_type,
        trading_value,
        first_settlement_value,
        src_stm_code
    FROM {{ ft_ref('ft_atm_bond_order_book') }}
    WHERE src_stm_code IN ('HNX_OUTRIGHT_ORDER_BOOK','HNX_REPO_ORDER_BOOK','HNX_REPO2_ORDER_BOOK')
    -- [FT-ORIG] AND trading_date = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

bo_bo_buy AS (
    SELECT
        trading_date        AS trade_dt,
        buying_account_no   AS account_nbr,
        bond_code           AS symbol,
        'BUY'               AS trade_direction_code,
        CAST(NULL AS string) AS account_holder_nm,
        order_bond_quantity AS execution_vol,
        CASE WHEN order_book_type = 'OUTRIGHT' THEN trading_value ELSE first_settlement_value END AS execution_val,
        src_stm_code
    FROM bo_bo
    WHERE SUBSTR(buying_account_no, 4, 1) IN ('E','F')
),

bo_bo_sell AS (
    SELECT
        trading_date         AS trade_dt,
        selling_account_no   AS account_nbr,
        bond_code            AS symbol,
        'SELL'               AS trade_direction_code,
        CAST(NULL AS string) AS account_holder_nm,
        order_bond_quantity  AS execution_vol,
        CASE WHEN order_book_type = 'OUTRIGHT' THEN trading_value ELSE first_settlement_value END AS execution_val,
        src_stm_code
    FROM bo_bo
    WHERE SUBSTR(selling_account_no, 4, 1) IN ('E','F')
),

se_tr_pv AS (
    SELECT * FROM se_tr_buy
    UNION ALL
    SELECT * FROM se_tr_sell
    UNION ALL
    SELECT * FROM bo_bo_buy
    UNION ALL
    SELECT * FROM bo_bo_sell
),

-- [FT-NEW] Foreign Investor: chua co atomic ft_ rieng, dung ref thuong (entity dang dimension, full load, khong snapshot theo ngay).
fo_in AS (
    SELECT
        foreign_investor_code,
        full_nm
    FROM {{ ref('atm_foreign_investor') }}
)

SELECT
    CAST(se_tr_pv.trade_dt AS date)                    AS report_dt,
    CAST(se_tr_pv.account_nbr AS string)               AS account_nbr,
    CAST(se_tr_pv.symbol AS string)                    AS symbol,
    CAST(se_tr_pv.trade_direction_code AS string)      AS trade_direction_code,
    CAST(se_tr_pv.account_holder_nm AS string)         AS account_holder_nm,
    CAST(MAX(fo_in.full_nm) AS string)                 AS investor_nm,
    CAST(SUM(se_tr_pv.execution_vol) AS bigint)        AS execution_vol,
    CAST(SUM(se_tr_pv.execution_val) AS decimal(23,2)) AS execution_val,
    CAST(se_tr_pv.src_stm_code AS string)              AS src_stm_code
FROM se_tr_pv
LEFT JOIN fo_in
    ON  SUBSTR(UPPER(TRIM(fo_in.foreign_investor_code)), -6) = SUBSTR(UPPER(TRIM(se_tr_pv.account_nbr)), -6)
GROUP BY se_tr_pv.trade_dt, se_tr_pv.account_nbr, se_tr_pv.symbol, se_tr_pv.trade_direction_code, se_tr_pv.account_holder_nm, se_tr_pv.src_stm_code
ORDER BY se_tr_pv.trade_dt, se_tr_pv.account_nbr, se_tr_pv.symbol, se_tr_pv.trade_direction_code, se_tr_pv.src_stm_code
