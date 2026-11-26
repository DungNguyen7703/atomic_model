/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_listed_corporate_bond_snpst
* Program name: Dtm Fct Listed Corporate Bond Snapshot
* Created by: huy.pham
* Created date: 2026-10-28
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-07      huy.pham        [FULL HISTORY] Bo filter ngay cho sn, tr, lsi; lsi them
*                                 rpt_dt vao SELECT va JOIN (AND lsi.rpt_dt = j.snpst_dt).
*                                 Dim tham chieu giu nguyen 1 moc snapshot co dinh:
*                                 pc=2026-09-02, sc=2026-11-05, fmc=2026-10-15,
*                                 ind=2026-11-05.
* 2026-11-18      claude          [O_VP_87] Them 13 cot: NDTNN/tu doanh vol/val, khop lenh/
*                                 thoa thuan vol/val, yield_to_maturity_rate, floor_code,
*                                 ticker_symbol.
* 2026-11-16		claude			[BO SUNG theo LLD, O_VP_81] Them 2 cot output
*                                 moi: listed_bond_val (KL niem yet MDDS x menh
*                                 gia; decimal(23,2)) va remaining_term_days (so
*                                 ngay con lai den dao han tu ngay GD; int). Them
*                                 listed_share_count vao sn_all/sn/joined lam
*                                 trung gian tinh listed_bond_val.
* 2026-10-28      huy.pham        [MOI, theo LLD DTM_VP_fct_listed_corporate_bond_snpst.csv]
*                                 Fact snapshot TPDN niem yet cuoi ngay. Grain = 1 ma TP
*                                 (ISIN) / ngay GD. FULL OUTER JOIN So lenh HNX (market_id=
*                                 'HCX', noi ISIN) voi ban tin cuoi ngay MDDS (stock_tp='1',
*                                 rn=1 theo trading_time DESC, sequence DESC). KL luu hanh LEFT
*                                 JOIN theo ticker_symbol va ngay (HNX_LISTED_SECURITIES_LIST,
*                                 O_VP_15: rpt_dt khong trong khoa atomic).
*                                 Nganh theo CTPH: 3 ky tu dau ticker_symbol = equity_ticker
*                                 cua public_company; CTCK/CTQLQ mac dinh '07000' (O_VP_23).
*                                 Menh gia tinh nguoc tu gia tham chieu: 100000 * 10^ROUND(
*                                 LOG10(ref_price / 100000)) — chi dung tinh bond_outstanding_
*                                 val, khong luu rieng.
*--------------------------------------------------------------------*
*/

WITH sn_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        reference_price,
        maturity_dt,
        issue_dt,
        listed_share_count,
        floor_code,
        yield,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code = '1'
        -- [DAILY] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sn AS (
    SELECT ticker_symbol, isin_code, trading_dt, reference_price, maturity_dt, issue_dt, listed_share_count, floor_code, yield
    FROM sn_all
    WHERE rn = 1
),

tr AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol)                                                                          AS trading_vol,
        SUM(execution_val)                                                                          AS trading_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)       AS foreign_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)      AS foreign_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('E','F')      THEN execution_vol ELSE 0 END) AS foreign_buy_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('P','E','A')  THEN execution_vol ELSE 0 END) AS proprietary_buy_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('P','E','A')  THEN execution_val ELSE 0 END) AS proprietary_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')      THEN execution_vol ELSE 0 END) AS foreign_sell_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A')  THEN execution_vol ELSE 0 END) AS proprietary_sell_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A')  THEN execution_val ELSE 0 END) AS proprietary_sell_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END)  AS order_matching_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END)  AS order_matching_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END)  AS negotiated_trade_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END)  AS negotiated_trade_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
        AND market_id_code = 'HCX'
        -- [DAILY] AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY security_symbol_code, trade_dt
),

lsi AS (
    -- [DAILY] SELECT ticker_symbol, outstanding_share_quantity
    SELECT ticker_symbol, outstanding_share_quantity,
           MAKE_DATE(rpt_year, rpt_month, rpt_day) AS rpt_dt  -- [FULL HISTORY] them rpt_dt de JOIN theo ngay
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
        -- [DAILY] AND MAKE_DATE(rpt_year, rpt_month, rpt_day) = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    WHERE ds_snpst_dt = to_date('2026-09-02','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc AS (
    SELECT equity_ticker_symbol, business_line_level_1_code
    FROM pc_all
    WHERE rn = 1
),

-- CTCK: mac dinh nganh '07000' neu 3 ky tu dau ticker la ma CTCK dai chung
sc AS (
    SELECT DISTINCT securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

-- CTQLQ: mac dinh nganh '07000' neu 3 ky tu dau ticker la ma CTQLQ
fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-10-15','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

joined AS (
    SELECT
        COALESCE(tr.security_symbol_code, sn.isin_code)    AS security_symbol_code,
        COALESCE(tr.trade_dt, sn.trading_dt)               AS snpst_dt,
        sn.ticker_symbol,
        sn.reference_price,
        sn.maturity_dt,
        sn.issue_dt,
        tr.trading_vol,
        tr.trading_val,
        tr.foreign_buy_val,
        tr.foreign_sell_val,
        sn.listed_share_count                              AS listed_share_count,
        (sn.ticker_symbol IS NOT NULL)                     AS listed_indicator,
        tr.foreign_buy_vol,
        tr.proprietary_buy_vol,
        tr.proprietary_buy_val,
        tr.foreign_sell_vol,
        tr.proprietary_sell_vol,
        tr.proprietary_sell_val,
        tr.order_matching_vol,
        tr.order_matching_val,
        tr.negotiated_trade_vol,
        tr.negotiated_trade_val,
        sn.floor_code,
        CASE WHEN sn.yield = -9999 THEN NULL ELSE sn.yield END AS yield_to_maturity_rate
    FROM tr
    FULL OUTER JOIN sn
        ON  sn.isin_code  = tr.security_symbol_code
        AND sn.trading_dt = tr.trade_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('fct_listed_corporate_bond_snpst', "CONCAT(date_format(j.snpst_dt,'yyyyMMdd'), '|', j.security_symbol_code)") }} AS string) AS listed_corporate_bond_snpst_id,
    CAST(date_format(j.snpst_dt, 'yyyyMMdd') AS string)                                AS snpst_dt_dim_id,
    CAST(ind.industry_dim_id AS string)                                                AS industry_dim_id,
    CAST(j.security_symbol_code AS string)                                             AS security_symbol_code,
    CAST(j.listed_indicator AS boolean)                                                AS listed_indicator,
    CAST(ROUND(months_between(j.maturity_dt, j.issue_dt) / 12, 2) AS decimal(23,2))    AS issue_term_years,
    CAST(months_between(j.maturity_dt, j.snpst_dt) / 12 AS decimal(23,6))              AS remaining_term_years,
    CAST(j.trading_vol AS bigint)                                                      AS trading_vol,
    CAST(j.trading_val AS decimal(23,2))                                               AS trading_val,
    CAST(j.foreign_buy_val AS decimal(23,2))                                           AS foreign_buy_val,
    CAST(j.foreign_sell_val AS decimal(23,2))                                          AS foreign_sell_val,
    CAST(lsi.outstanding_share_quantity AS bigint)                                     AS outstanding_bond_quantity,
    CAST(
        lsi.outstanding_share_quantity
        * 100000
        * POWER(10, ROUND(LOG10(NULLIF(j.reference_price, 0) / 100000)))
    AS decimal(23,2))                                                                  AS bond_outstanding_val,
    CAST(
        j.listed_share_count
        * 100000
        * POWER(10, ROUND(LN(NULLIF(j.reference_price, 0) / 100000) / LN(10)))
    AS decimal(23,2))                                                                  AS listed_bond_val,
    CAST(DATEDIFF(j.maturity_dt, j.snpst_dt) AS int)                                  AS remaining_term_days,
    CAST(j.foreign_buy_vol AS bigint)                                                 AS foreign_buy_vol,
    CAST(j.proprietary_buy_vol AS bigint)                                             AS proprietary_buy_vol,
    CAST(j.proprietary_buy_val AS decimal(23,2))                                      AS proprietary_buy_val,
    CAST(j.foreign_sell_vol AS bigint)                                                AS foreign_sell_vol,
    CAST(j.proprietary_sell_vol AS bigint)                                            AS proprietary_sell_vol,
    CAST(j.proprietary_sell_val AS decimal(23,2))                                     AS proprietary_sell_val,
    CAST(j.order_matching_vol AS bigint)                                              AS order_matching_vol,
    CAST(j.order_matching_val AS decimal(23,2))                                       AS order_matching_val,
    CAST(j.negotiated_trade_vol AS bigint)                                            AS negotiated_trade_vol,
    CAST(j.negotiated_trade_val AS decimal(23,2))                                     AS negotiated_trade_val,
    CAST(j.yield_to_maturity_rate AS decimal(8,5))                                    AS yield_to_maturity_rate,
    CAST(j.floor_code AS string)                                                      AS floor_code,
    CAST(j.ticker_symbol AS string)                                                   AS ticker_symbol
FROM joined j
LEFT JOIN lsi
    ON  lsi.ticker_symbol = j.ticker_symbol
    AND lsi.rpt_dt         = j.snpst_dt  -- [FULL HISTORY] khop ngay; [DAILY] xoa dong nay va xoa rpt_dt khoi lsi
LEFT JOIN pc
    ON  pc.equity_ticker_symbol = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN sc
    ON  sc.securities_code = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN fmc
    ON  fmc.stock_ticker_code = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN ind
    ON  ind.industry_code = CASE
            WHEN sc.securities_code IS NOT NULL OR fmc.stock_ticker_code IS NOT NULL
            THEN '07000'
            ELSE pc.business_line_level_1_code
        END

/*
*--------------------------------------------------------------------*
* [DAILY] Code chay hang ngay — thay the toan bo phan WITH...SELECT
* phia tren khi chuyen sang che do incremental theo etl_date.
* Luu y:
*   - sn_all / tr / lsi: bat lai filter ngay = etl_date
*   - lsi: xoa rpt_dt khoi SELECT, xoa dieu kien ngay trong JOIN
*   - Dim CTEs (pc_all, sc, fmc, ind): doi fixed date -> etl_date
*--------------------------------------------------------------------*

WITH sn_all AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        reference_price,
        maturity_dt,
        issue_dt,
        listed_share_count,
        floor_code,
        yield,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code = '1'
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sn AS (
    SELECT ticker_symbol, isin_code, trading_dt, reference_price, maturity_dt, issue_dt, listed_share_count, floor_code, yield
    FROM sn_all
    WHERE rn = 1
),

tr AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol)                                                                          AS trading_vol,
        SUM(execution_val)                                                                          AS trading_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)       AS foreign_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)      AS foreign_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('E','F')      THEN execution_vol ELSE 0 END) AS foreign_buy_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('P','E','A')  THEN execution_vol ELSE 0 END) AS proprietary_buy_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1)  IN ('P','E','A')  THEN execution_val ELSE 0 END) AS proprietary_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')      THEN execution_vol ELSE 0 END) AS foreign_sell_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A')  THEN execution_vol ELSE 0 END) AS proprietary_sell_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E','A')  THEN execution_val ELSE 0 END) AS proprietary_sell_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END)  AS order_matching_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END)  AS order_matching_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END)  AS negotiated_trade_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END)  AS negotiated_trade_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
        AND market_id_code = 'HCX'
        AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY security_symbol_code, trade_dt
),

lsi AS (
    SELECT ticker_symbol, outstanding_share_quantity
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
        AND MAKE_DATE(rpt_year, rpt_month, rpt_day) = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

joined AS (
    SELECT
        COALESCE(tr.security_symbol_code, sn.isin_code)    AS security_symbol_code,
        COALESCE(tr.trade_dt, sn.trading_dt)               AS snpst_dt,
        sn.ticker_symbol,
        sn.reference_price,
        sn.maturity_dt,
        sn.issue_dt,
        tr.trading_vol,
        tr.trading_val,
        tr.foreign_buy_val,
        tr.foreign_sell_val,
        sn.listed_share_count                              AS listed_share_count,
        (sn.ticker_symbol IS NOT NULL)                     AS listed_indicator,
        tr.foreign_buy_vol,
        tr.proprietary_buy_vol,
        tr.proprietary_buy_val,
        tr.foreign_sell_vol,
        tr.proprietary_sell_vol,
        tr.proprietary_sell_val,
        tr.order_matching_vol,
        tr.order_matching_val,
        tr.negotiated_trade_vol,
        tr.negotiated_trade_val,
        sn.floor_code,
        CASE WHEN sn.yield = -9999 THEN NULL ELSE sn.yield END AS yield_to_maturity_rate
    FROM tr
    FULL OUTER JOIN sn
        ON  sn.isin_code  = tr.security_symbol_code
        AND sn.trading_dt = tr.trade_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('fct_listed_corporate_bond_snpst', "CONCAT(date_format(j.snpst_dt,'yyyyMMdd'), '|', j.security_symbol_code)") }} AS string) AS listed_corporate_bond_snpst_id,
    CAST(date_format(j.snpst_dt, 'yyyyMMdd') AS string)                                AS snpst_dt_dim_id,
    CAST(ind.industry_dim_id AS string)                                                AS industry_dim_id,
    CAST(j.security_symbol_code AS string)                                             AS security_symbol_code,
    CAST(j.listed_indicator AS boolean)                                                AS listed_indicator,
    CAST(ROUND(months_between(j.maturity_dt, j.issue_dt) / 12, 2) AS decimal(23,2))  AS issue_term_years,
    CAST(months_between(j.maturity_dt, j.snpst_dt) / 12 AS decimal(23,6))            AS remaining_term_years,
    CAST(j.trading_vol AS bigint)                                                      AS trading_vol,
    CAST(j.trading_val AS decimal(23,2))                                               AS trading_val,
    CAST(j.foreign_buy_val AS decimal(23,2))                                           AS foreign_buy_val,
    CAST(j.foreign_sell_val AS decimal(23,2))                                          AS foreign_sell_val,
    CAST(lsi.outstanding_share_quantity AS bigint)                                     AS outstanding_bond_quantity,
    CAST(
        lsi.outstanding_share_quantity
        * 100000
        * POWER(10, ROUND(LOG10(NULLIF(j.reference_price, 0) / 100000)))
    AS decimal(23,2))                                                                  AS bond_outstanding_val,
    CAST(
        j.listed_share_count
        * 100000
        * POWER(10, ROUND(LN(NULLIF(j.reference_price, 0) / 100000) / LN(10)))
    AS decimal(23,2))                                                                  AS listed_bond_val,
    CAST(DATEDIFF(j.maturity_dt, j.snpst_dt) AS int)                                  AS remaining_term_days,
    CAST(j.foreign_buy_vol AS bigint)                                                 AS foreign_buy_vol,
    CAST(j.proprietary_buy_vol AS bigint)                                             AS proprietary_buy_vol,
    CAST(j.proprietary_buy_val AS decimal(23,2))                                      AS proprietary_buy_val,
    CAST(j.foreign_sell_vol AS bigint)                                                AS foreign_sell_vol,
    CAST(j.proprietary_sell_vol AS bigint)                                            AS proprietary_sell_vol,
    CAST(j.proprietary_sell_val AS decimal(23,2))                                     AS proprietary_sell_val,
    CAST(j.order_matching_vol AS bigint)                                              AS order_matching_vol,
    CAST(j.order_matching_val AS decimal(23,2))                                       AS order_matching_val,
    CAST(j.negotiated_trade_vol AS bigint)                                            AS negotiated_trade_vol,
    CAST(j.negotiated_trade_val AS decimal(23,2))                                     AS negotiated_trade_val,
    CAST(j.yield_to_maturity_rate AS decimal(8,5))                                    AS yield_to_maturity_rate,
    CAST(j.floor_code AS string)                                                      AS floor_code,
    CAST(j.ticker_symbol AS string)                                                   AS ticker_symbol
FROM joined j
LEFT JOIN lsi
    ON  lsi.ticker_symbol = j.ticker_symbol
LEFT JOIN pc
    ON  pc.equity_ticker_symbol = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN sc
    ON  sc.securities_code = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN fmc
    ON  fmc.stock_ticker_code = SUBSTR(j.ticker_symbol, 1, 3)
LEFT JOIN ind
    ON  ind.industry_code = CASE
            WHEN sc.securities_code IS NOT NULL OR fmc.stock_ticker_code IS NOT NULL
            THEN '07000'
            ELSE pc.business_line_level_1_code
        END

*--------------------------------------------------------------------*
*/
