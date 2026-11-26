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
* 2026-11-18      claude          [O_VP_87] Them 4 cot KL/GT khop lenh va thoa thuan.
* 2026-11-07      huy.pham        [FULL HISTORY] Bo filter ngay cho sn_all, se_tr_sn_di, se_tr.
*                                 dtm_security_trading_snpst_dim_hstr chua du lat cat lich su —
*                                 thay bang se_tr_sn_di tu atm_security_trading_snapshot (cung
*                                 nguon voi dim, trai key inline). sn_all bo sung isin_code va
*                                 trading_dt de lam nguon chung cho ca sn va se_tr_sn_di.
*                                 JOIN se_tr_sn_di va sn them dieu kien ngay theo trade_dt.
*                                 Dim tham chieu giu nguyen 1 moc snapshot co dinh:
*                                 pc=2026-09-02, sc=2026-11-05, fmc=2026-10-15, ind=2026-11-05.
* 2026-11-19      claude          [O_VP_87, K_VP_518] Them derivative_term: ky han phai sinh
*                                 theo maturity_month_year. FBX = 3 thang cuoi quy; Chi so = 4
*                                 ky (gan nhat, tiep theo, 2 cuoi quy). Them floor_code,
*                                 product_group_id, underlying_symbol, maturity_month_year vao
*                                 sn_all; tinh derivative_term bang dense_rank theo
*                                 (trading_dt, underlying_symbol ORDER BY maturity_month_year).
* 2026-11-20      claude          [SUA] Doi driving table tu se_tr_grp sang sn_all x
*                                 investor_group de lay ca ma khong phat sinh GD (zero-fill).
*                                 security_trading_snpst_dim_id chuyen vao sn_all; bo
*                                 se_tr_sn_di; volumes COALESCE(...,0); security_symbol_code
*                                 va market_id_code derive tu floor_code; src_stm_code
*                                 COALESCE(g.src_stm_code, derive tu floor_code).
*--------------------------------------------------------------------*
*/

WITH sn_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        stock_tp_code,
        floor_code,
        product_group_id,
        underlying_symbol,
        maturity_month_year,
        trading_dt,
        CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'ticker_symbol') }} AS string) AS security_trading_snpst_dim_id,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        -- [DAILY] AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sn AS (
    SELECT
        ticker_symbol,
        stock_tp_code,
        trading_dt,
        CASE
            WHEN floor_code <> '03' OR maturity_month_year IS NULL THEN NULL
            WHEN product_group_id = 'FBX' THEN
                CASE dense_rank() OVER (PARTITION BY trading_dt, underlying_symbol ORDER BY maturity_month_year)
                    WHEN 1 THEN 'Tháng cuối quý gần nhất'
                    WHEN 2 THEN 'Tháng cuối quý tiếp theo 1'
                    WHEN 3 THEN 'Tháng cuối quý tiếp theo 2'
                END
            ELSE
                CASE dense_rank() OVER (PARTITION BY trading_dt, underlying_symbol ORDER BY maturity_month_year)
                    WHEN 1 THEN 'Tháng gần nhất'
                    WHEN 2 THEN 'Tháng tiếp theo'
                    WHEN 3 THEN 'Tháng cuối quý gần nhất'
                    WHEN 4 THEN 'Tháng cuối quý tiếp theo 1'
                END
        END AS derivative_term
    FROM sn_all
    WHERE rn = 1
),

se_tr AS (
    SELECT
        src_stm_code,
        security_symbol_code,
        trade_dt,
        market_id_code,
        board_tp_code,
        execution_vol,
        execution_val,
        buy_account_nbr,
        sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE', 'ORDERTRADE_TRADE_BOOK_HNX')
        -- [DAILY] AND trade_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
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
            ELSE 0 END)                                                                         AS sell_val,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS order_matching_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS order_matching_val,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS negotiated_trade_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS negotiated_trade_val
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
    WHERE ds_snpst_dt = to_date('2026-09-02', 'yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
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
    WHERE ds_snpst_dt = to_date('2026-11-05', 'yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-10-15', 'yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05', 'yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK', "CONCAT(date_format(s.trading_dt,'yyyyMMdd'), '|', CASE s.floor_code WHEN '10' THEN s.ticker_symbol ELSE s.isin_code END, '|', CASE s.floor_code WHEN '10' THEN 'STK' WHEN '02' THEN 'STX' WHEN '04' THEN 'UPX' WHEN '03' THEN 'DVX' END, '|', ig.investor_group_code, '|', COALESCE(g.src_stm_code, CASE s.floor_code WHEN '10' THEN 'ORDERTRADE_TRADE_BOOK_HOSE' ELSE 'ORDERTRADE_TRADE_BOOK_HNX' END))") }} AS string) AS investor_group_trading_snpst_id,
    CAST(date_format(s.trading_dt, 'yyyyMMdd') AS string)   AS snpst_dt_dim_id,
    CAST(s.security_trading_snpst_dim_id AS string)         AS security_trading_snpst_dim_id,
    CAST(ind.industry_dim_id AS string)                     AS industry_dim_id,
    CAST(CASE s.floor_code WHEN '10' THEN s.ticker_symbol ELSE s.isin_code END AS string)                                                          AS security_symbol_code,
    CAST(CASE s.floor_code WHEN '10' THEN 'STK' WHEN '02' THEN 'STX' WHEN '04' THEN 'UPX' WHEN '03' THEN 'DVX' END AS string)                     AS market_id_code,
    CAST(ig.investor_group_code AS string)                  AS investor_group_code,
    CAST(COALESCE(g.buy_vol,  0) AS bigint)                 AS buy_vol,
    CAST(COALESCE(g.buy_val,  0) AS decimal(23,2))          AS buy_val,
    CAST(COALESCE(g.sell_vol, 0) AS bigint)                 AS sell_vol,
    CAST(COALESCE(g.sell_val, 0) AS decimal(23,2))          AS sell_val,
    CAST(COALESCE(g.src_stm_code, CASE s.floor_code WHEN '10' THEN 'ORDERTRADE_TRADE_BOOK_HOSE' ELSE 'ORDERTRADE_TRADE_BOOK_HNX' END) AS string)   AS src_stm_code,
    CAST(COALESCE(g.order_matching_vol,  0) AS bigint)      AS order_matching_vol,
    CAST(COALESCE(g.order_matching_val,  0) AS decimal(23,2)) AS order_matching_val,
    CAST(COALESCE(g.negotiated_trade_vol,0) AS bigint)      AS negotiated_trade_vol,
    CAST(COALESCE(g.negotiated_trade_val,0) AS decimal(23,2)) AS negotiated_trade_val,
    CAST(sn.derivative_term AS string)                      AS derivative_term
FROM (SELECT * FROM sn_all WHERE rn = 1) s
CROSS JOIN investor_group ig
LEFT JOIN se_tr_grp g
    ON  g.trade_dt            = s.trading_dt
    AND g.investor_group_code = ig.investor_group_code
    AND (
            (s.floor_code = '10' AND g.security_symbol_code = s.ticker_symbol AND g.market_id_code = 'STK')
         OR (s.floor_code = '02' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'STX')
         OR (s.floor_code = '04' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'UPX')
         OR (s.floor_code = '03' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'DVX')
    )
LEFT JOIN sn
    ON  sn.ticker_symbol = s.ticker_symbol
    AND sn.trading_dt    = s.trading_dt
LEFT JOIN pc
    ON  pc.equity_ticker_symbol = s.ticker_symbol
LEFT JOIN sc
    ON  sc.securities_code = s.ticker_symbol
LEFT JOIN fmc
    ON  fmc.stock_ticker_code = s.ticker_symbol
LEFT JOIN ind
    ON  ind.industry_code = CASE
            WHEN s.stock_tp_code = '2'
            THEN CASE
                    WHEN sc.securities_code IS NOT NULL OR fmc.stock_ticker_code IS NOT NULL
                    THEN '07000'
                    ELSE pc.business_line_level_1_code
                END
        END

/*
*--------------------------------------------------------------------*
* [DAILY] Code chay hang ngay — thay the toan bo phan WITH...SELECT
* phia tren khi chuyen sang che do incremental theo etl_date.
* Luu y: sn_all la driving table; se_tr_sn_di da bo (security_trading_snpst_dim_id
* compute truc tiep trong sn_all).
*--------------------------------------------------------------------*

WITH sn_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        stock_tp_code,
        floor_code,
        product_group_id,
        underlying_symbol,
        maturity_month_year,
        trading_dt,
        CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', 'ticker_symbol') }} AS string) AS security_trading_snpst_dim_id,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sn AS (
    SELECT
        ticker_symbol,
        stock_tp_code,
        trading_dt,
        CASE
            WHEN floor_code <> '03' OR maturity_month_year IS NULL THEN NULL
            WHEN product_group_id = 'FBX' THEN
                CASE dense_rank() OVER (PARTITION BY trading_dt, underlying_symbol ORDER BY maturity_month_year)
                    WHEN 1 THEN 'Tháng cuối quý gần nhất'
                    WHEN 2 THEN 'Tháng cuối quý tiếp theo 1'
                    WHEN 3 THEN 'Tháng cuối quý tiếp theo 2'
                END
            ELSE
                CASE dense_rank() OVER (PARTITION BY trading_dt, underlying_symbol ORDER BY maturity_month_year)
                    WHEN 1 THEN 'Tháng gần nhất'
                    WHEN 2 THEN 'Tháng tiếp theo'
                    WHEN 3 THEN 'Tháng cuối quý gần nhất'
                    WHEN 4 THEN 'Tháng cuối quý tiếp theo 1'
                END
        END AS derivative_term
    FROM sn_all
    WHERE rn = 1
),

se_tr AS (
    SELECT
        src_stm_code,
        security_symbol_code,
        trade_dt,
        market_id_code,
        board_tp_code,
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
            ELSE 0 END)                                                                         AS sell_val,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS order_matching_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS order_matching_val,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN t.execution_vol ELSE 0 END
            ELSE 0 END)                                                                         AS negotiated_trade_vol,
        SUM(CASE g.investor_group_code
            WHEN 'ALL' THEN CASE WHEN t.board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN t.execution_val ELSE 0 END
            ELSE 0 END)                                                                         AS negotiated_trade_val
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
        AND src_stm_code = 'IDS_CATEGORIES'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('ORDERTRADE_TRADE_BOOK', "CONCAT(date_format(s.trading_dt,'yyyyMMdd'), '|', CASE s.floor_code WHEN '10' THEN s.ticker_symbol ELSE s.isin_code END, '|', CASE s.floor_code WHEN '10' THEN 'STK' WHEN '02' THEN 'STX' WHEN '04' THEN 'UPX' WHEN '03' THEN 'DVX' END, '|', ig.investor_group_code, '|', COALESCE(g.src_stm_code, CASE s.floor_code WHEN '10' THEN 'ORDERTRADE_TRADE_BOOK_HOSE' ELSE 'ORDERTRADE_TRADE_BOOK_HNX' END))") }} AS string) AS investor_group_trading_snpst_id,
    CAST(date_format(s.trading_dt, 'yyyyMMdd') AS string)   AS snpst_dt_dim_id,
    CAST(s.security_trading_snpst_dim_id AS string)         AS security_trading_snpst_dim_id,
    CAST(ind.industry_dim_id AS string)                     AS industry_dim_id,
    CAST(CASE s.floor_code WHEN '10' THEN s.ticker_symbol ELSE s.isin_code END AS string)                                                          AS security_symbol_code,
    CAST(CASE s.floor_code WHEN '10' THEN 'STK' WHEN '02' THEN 'STX' WHEN '04' THEN 'UPX' WHEN '03' THEN 'DVX' END AS string)                     AS market_id_code,
    CAST(ig.investor_group_code AS string)                  AS investor_group_code,
    CAST(COALESCE(g.buy_vol,  0) AS bigint)                 AS buy_vol,
    CAST(COALESCE(g.buy_val,  0) AS decimal(23,2))          AS buy_val,
    CAST(COALESCE(g.sell_vol, 0) AS bigint)                 AS sell_vol,
    CAST(COALESCE(g.sell_val, 0) AS decimal(23,2))          AS sell_val,
    CAST(COALESCE(g.src_stm_code, CASE s.floor_code WHEN '10' THEN 'ORDERTRADE_TRADE_BOOK_HOSE' ELSE 'ORDERTRADE_TRADE_BOOK_HNX' END) AS string)   AS src_stm_code,
    CAST(COALESCE(g.order_matching_vol,  0) AS bigint)      AS order_matching_vol,
    CAST(COALESCE(g.order_matching_val,  0) AS decimal(23,2)) AS order_matching_val,
    CAST(COALESCE(g.negotiated_trade_vol,0) AS bigint)      AS negotiated_trade_vol,
    CAST(COALESCE(g.negotiated_trade_val,0) AS decimal(23,2)) AS negotiated_trade_val,
    CAST(sn.derivative_term AS string)                      AS derivative_term
FROM (SELECT * FROM sn_all WHERE rn = 1) s
CROSS JOIN investor_group ig
LEFT JOIN se_tr_grp g
    ON  g.trade_dt            = s.trading_dt
    AND g.investor_group_code = ig.investor_group_code
    AND (
            (s.floor_code = '10' AND g.security_symbol_code = s.ticker_symbol AND g.market_id_code = 'STK')
         OR (s.floor_code = '02' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'STX')
         OR (s.floor_code = '04' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'UPX')
         OR (s.floor_code = '03' AND g.security_symbol_code = s.isin_code     AND g.market_id_code = 'DVX')
    )
LEFT JOIN sn
    ON  sn.ticker_symbol = s.ticker_symbol
LEFT JOIN pc
    ON  pc.equity_ticker_symbol = s.ticker_symbol
LEFT JOIN sc
    ON  sc.securities_code = s.ticker_symbol
LEFT JOIN fmc
    ON  fmc.stock_ticker_code = s.ticker_symbol
LEFT JOIN ind
    ON  ind.industry_code = CASE
            WHEN s.stock_tp_code = '2'
            THEN CASE
                    WHEN sc.securities_code IS NOT NULL OR fmc.stock_ticker_code IS NOT NULL
                    THEN '07000'
                    ELSE pc.business_line_level_1_code
                END
        END

*--------------------------------------------------------------------*
*/
