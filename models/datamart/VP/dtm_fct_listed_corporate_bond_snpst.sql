/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_listed_corporate_bond_snpst
* Program name: Dtm Fct Listed Corporate Bond Snapshot
* Created by: huy.pham
* Created date: 2026-10-28
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
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
    SELECT ticker_symbol, isin_code, trading_dt, reference_price, maturity_dt, issue_dt
    FROM sn_all
    WHERE rn = 1
),

tr AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol)                                                                          AS trading_vol,
        SUM(execution_val)                                                                          AS trading_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)    AS foreign_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)   AS foreign_sell_val
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
        AND rpt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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

-- CTCK: mac dinh nganh '07000' neu 3 ky tu dau ticker la ma CTCK dai chung
sc AS (
    SELECT DISTINCT securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

-- CTQLQ: mac dinh nganh '07000' neu 3 ky tu dau ticker la ma CTQLQ
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
        AND src_stm_code = 'ECAT_BUSINESS_LINE_LEVEL_1'
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
        (sn.ticker_symbol IS NOT NULL)                     AS listed_indicator
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
    AS decimal(23,2))                                                                  AS bond_outstanding_val
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
