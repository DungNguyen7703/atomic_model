/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_group_trading_snpst
* Program name: Dtm Fct Investor Group Trading Snpst
* Created by: huy.pham
* Created date: 2026-10-27
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-27      huy.pham        [MOI, theo LLD DTM_QLKD_fct_investor_group_trading_snpst.csv]
*                                 Fact giao dich theo nhom nha dau tu (ALL / FOREIGN /
*                                 PROPRIETARY). Grain = 1 dong / ma CK | hop dong / ngay GD /
*                                 san / investor_group_code. Nguon: atm_securities_trade
*                                 (ORDERTRADE_TRADE_BOOK_HOSE + HNX), filter market_id IN
*                                 (STK,STX,UPX,DVX). Nhan dang nhom: ky tu thu 4 so TK —
*                                 FOREIGN = E/F, PROPRIETARY = P/E/A, ALL = tong khop.
*                                 Cac nhom KHONG loai tru nhau (TK loai E tinh ca FOREIGN va
*                                 PROPRIETARY). Co phieu: chi giu khi co ban tin MDDS
*                                 (dtm_security_trading_snpst_dim); phai sinh DVX giu lai ca
*                                 khi khong co ban tin MDDS (O_VP_10). ELSE 0 thay NULL cua
*                                 SUM(CASE) khi nhom khong co GD (O_VP_11, Vuong chap nhan).
*                                 HOSE: noi qua symbol; HNX/UPX/DVX: noi qua isin_code
*                                 (Vuong chot 2026-10-25).
* 2026-10-29      huy.pham        [O_VP_37] Them industry_dim_id: chi ap dung cho co phieu
*                                 (MDDS stock_tp_code='2'); CTCK/CTQLQ mac dinh '07000';
*                                 NULL cho phai sinh, CCQ, chung quyen, ma chua xac dinh nganh.
*                                 Them src_stm_code vao grain va PK (tranh trung khoa khi nhieu
*                                 nguon), them vao GROUP BY va SELECT.
*--------------------------------------------------------------------*
*/

WITH sn_all AS (
    SELECT
        ticker_symbol,
        stock_tp_code,
        trading_dt,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sn AS (
    SELECT ticker_symbol, stock_tp_code
    FROM sn_all
    WHERE rn = 1
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        isin_code,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

se_tr AS (
    SELECT
        src_stm_code,
        security_symbol_code,
        trade_dt,
        market_id_code,
        execution_vol,
        execution_val,
        buy_account_nbr,
        sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE', 'ORDERTRADE_TRADE_BOOK_HNX')
        AND trade_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND market_id_code IN ('STK', 'STX', 'UPX', 'DVX')
),

investor_group AS (
    SELECT investor_group_code
    FROM (VALUES ('ALL'), ('FOREIGN'), ('PROPRIETARY')) AS t(investor_group_code)
),

se_tr_grp AS (
    SELECT
        t.src_stm_code,
        t.security_symbol_code,
        t.trade_dt,
        t.market_id_code,
        g.investor_group_code,
        SUM(CASE g.investor_group_code
            WHEN 'ALL'         THEN t.execution_vol
            WHEN 'FOREIGN'     THEN CASE WHEN SUBSTR(t.buy_account_nbr, 4, 1) IN ('E','F')     THEN t.execution_vol ELSE 0 END
            WHEN 'PROPRIETARY' THEN CASE WHEN SUBSTR(t.buy_account_nbr, 4, 1) IN ('P','E','A') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS buy_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL'         THEN t.execution_val
            WHEN 'FOREIGN'     THEN CASE WHEN SUBSTR(t.buy_account_nbr, 4, 1) IN ('E','F')     THEN t.execution_val ELSE 0 END
            WHEN 'PROPRIETARY' THEN CASE WHEN SUBSTR(t.buy_account_nbr, 4, 1) IN ('P','E','A') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS buy_val,
        SUM(CASE g.investor_group_code
            WHEN 'ALL'         THEN t.execution_vol
            WHEN 'FOREIGN'     THEN CASE WHEN SUBSTR(t.sell_account_nbr, 4, 1) IN ('E','F')     THEN t.execution_vol ELSE 0 END
            WHEN 'PROPRIETARY' THEN CASE WHEN SUBSTR(t.sell_account_nbr, 4, 1) IN ('P','E','A') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS sell_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL'         THEN t.execution_val
            WHEN 'FOREIGN'     THEN CASE WHEN SUBSTR(t.sell_account_nbr, 4, 1) IN ('E','F')     THEN t.execution_val ELSE 0 END
            WHEN 'PROPRIETARY' THEN CASE WHEN SUBSTR(t.sell_account_nbr, 4, 1) IN ('P','E','A') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS sell_val
    FROM se_tr t
    CROSS JOIN investor_group g
    GROUP BY t.src_stm_code, t.security_symbol_code, t.trade_dt, t.market_id_code, g.investor_group_code
),

pc_all AS (
    SELECT
        equity_ticker_symbol,
        business_line_level_1_code,
        ROW_NUMBER() OVER (
            PARTITION BY equity_ticker_symbol
            ORDER BY CAST(public_company_code AS bigint) ASC
        ) AS rn
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc AS (
    SELECT equity_ticker_symbol, business_line_level_1_code
    FROM pc_all
    WHERE rn = 1
),

sc AS (
    SELECT DISTINCT securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_BUSINESS_LINE_LEVEL_1'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK', "CONCAT(date_format(g.trade_dt,'yyyyMMdd'), '|', g.security_symbol_code, '|', g.market_id_code, '|', g.investor_group_code, '|', g.src_stm_code)") }} AS string) AS investor_group_trading_snpst_id,
    CAST(date_format(g.trade_dt, 'yyyyMMdd') AS string)     AS snpst_dt_dim_id,
    CAST(d.security_trading_snpst_dim_id AS string)         AS security_trading_snpst_dim_id,
    CAST(ind.industry_dim_id AS string)                     AS industry_dim_id,
    CAST(g.security_symbol_code AS string)                  AS security_symbol_code,
    CAST(g.market_id_code AS string)                        AS market_id_code,
    CAST(g.investor_group_code AS string)                   AS investor_group_code,
    CAST(g.buy_vol AS bigint)                               AS buy_vol,
    CAST(g.buy_val AS decimal(23,2))                        AS buy_val,
    CAST(g.sell_vol AS bigint)                              AS sell_vol,
    CAST(g.sell_val AS decimal(23,2))                       AS sell_val,
    CAST(g.src_stm_code AS string)                          AS src_stm_code
FROM se_tr_grp g
LEFT JOIN se_tr_sn_di d
    ON  (g.market_id_code = 'STK'                    AND d.symbol    = g.security_symbol_code)
    OR  (g.market_id_code IN ('STX', 'UPX', 'DVX')  AND d.isin_code = g.security_symbol_code)
LEFT JOIN sn
    ON  sn.ticker_symbol = d.symbol
LEFT JOIN pc
    ON  pc.equity_ticker_symbol = d.symbol
LEFT JOIN sc
    ON  sc.securities_code = d.symbol
LEFT JOIN fmc
    ON  fmc.stock_ticker_code = d.symbol
LEFT JOIN ind
    ON  ind.industry_code = CASE
            WHEN sn.stock_tp_code = '2'
            THEN CASE
                    WHEN sc.securities_code IS NOT NULL OR fmc.stock_ticker_code IS NOT NULL
                    THEN '07000'
                    ELSE pc.business_line_level_1_code
                END
        END
WHERE g.market_id_code = 'DVX'
   OR d.security_trading_snpst_dim_id IS NOT NULL
