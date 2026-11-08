/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_trading_detail_rpt
* Program name: Dtm Foreign Investor Trading Detail Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date    User    Description
* 2026-10-26  nghia.le  [FIX] Dong bo LLD (sua 2026-10-20): them ORDER BY report_dt, account_nbr, symbol,
*         trade_direction_code, src_stm_code (grain 5 thanh phan) - truoc do thieu ORDER BY.
* 2026-10-21  nghia.le  [FIX] Dong bo LLD: bo sung filter stock_tp_code IN ('1','2','3','4','6') khi JOIN Securities
*         Dimension de lay symbol (LLD yeu cau loai bo ma CK khac 5 loai nay hoac khong co trong Securities
*         Dimension) - truoc do se_di thieu dieu kien nay.
* 2026-10-21  nghia.le  Dong bo LLD 2026-10-21: them nhanh TPCP (Bond Order Book HNX Outright/Repo/Repo2, symbol = bond_code
*         truc tiep, khong qua Securities Dimension) UNION ALL vao ca 2 phia BUY/SELL; them cot investor_nm
*         (LEFT JOIN atm_foreign_investor theo SUBSTR(UPPER(TRIM(foreign_investor_code)),-6) = SUBSTR(UPPER(TRIM(account_nbr)),-6)).
* 2026-10-17  nghia.le  Dong bo LLD 2026-10-17: nhan dien NDTNN doi sang ky tu thu 4 cua so tai khoan
*         (SUBSTR(buy/sell_account_nbr,4,1) IN ('E','F')), thay Buy/Sell Foreign Investor Type Code;
*         execution_vol CAST bigint (truoc int) khop LLD/DDL.
* 2026-10-01  nghia.le  Dong bo LLD 2026-10-01 (SQL BA): filter HOSE <> '00',
*         HNX IN ('10','20'); symbol qua INNER JOIN securities_dim
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
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

se_di AS (
    SELECT
        symbol,
        isin_code,
        stock_tp_code
    FROM {{ ref('dtm_securities_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND stock_tp_code IN ('1','2','3','4','6')
),

se_tr_dim AS (
    SELECT
        se_tr.*,
        se_di.symbol
    FROM se_tr
    JOIN se_di
        ON  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND se_di.symbol = se_tr.security_symbol_code)
        OR  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND se_di.isin_code = se_tr.security_symbol_code)
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
    FROM {{ ref('atm_bond_order_book') }}
    WHERE src_stm_code IN ('HNX_OUTRIGHT_ORDER_BOOK','HNX_REPO_ORDER_BOOK','HNX_REPO2_ORDER_BOOK')
        AND trading_date = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
