/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_financial_ytd_chg_rpt
* Program name: Dtm Public Company Financial YTD Change Rpt
* Created by: duc.luxuan
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		duc.luxuan			Tao moi. Bang trung gian tinh % thay doi tu DAU NAM den cuoi ky
*									bao cao cho 9 chi tieu can doi ke toan (BCDKT): total_asset,
*									inventory, total_liability, equity, contributed_capital,
*									undistributed_profit, receivable, cash_and_equivalent, debt_to_equity.
*									Y tuong giong dtm_public_company_financial_yoy_rpt nhung so sanh voi
*									cot "So dau nam" (column_description_reference='2' tren BCDKT, doc qua
*									cac cot *_beginning cua _smy) thay vi cung ky nam truoc => dau ky va
*									cuoi ky nam CUNG 1 dong _smy, khong can join N/N-1 hay driving-key.
*									Chi phuc vu JOIN cho dtm_public_company_exchange_financial_summary_rpt
*									(doc nganh='ALL') va dtm_public_company_exchange_industry_financial_rpt
*									(doc nganh cu the) - KHONG co ClickHouse flat rieng.
*									Grain/universe giong het yoy_rpt de join khop: (san, nganh, rpt_year,
*									rpt_quarter), universe 4 san HOSE/HNX/UPCOM/OTC, 4 nhom (san x nganh),
*									(san, 'ALL'), ('ALL', nganh), ('ALL','ALL').
*									Chot voi user 2026-10-01:
*									  - Tu/mau SUM thang tung ve (phuong an a): khong gioi han tap cong ty
*									    co du ca 2 so - cong ty chua co so dau nam van duoc cong vao cuoi ky.
*									  - <metric>_ytd_chg (%) = (cur - bgn) / ABS(bgn) * 100; xu ly NULL theo
*									    BA confirm 2026-08-21 cua YoY: bgn NULL => NULL; cur NULL => -100.
*									  - debt_to_equity_ytd_diff = CHENH LECH TUYET DOI cua he so (cur - bgn),
*									    he so dau/cuoi ky deu tinh lai tu SUM(total_liability)/SUM(equity) -
*									    khong SUM/AVG debt_to_equity per-company. Thieu 1 trong 2 => NULL.
*									Bang moi => PHAI CREATE TABLE tren Iceberg truoc lan chay dau
*									(incremental_rebase raise loi neu bang chua ton tai).
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 8 cot *_ytd_chg + debt_to_equity_ytd_diff decimal(9,4) -> decimal(30,6).
*								Nguon: atm_fr_value.data_val doi decimal(20,2) -> decimal(38,8). Quy uoc: cot
*								chi tieu co so = (38,8), cot tinh tu phep chia = (30,6). Bang Iceberg KHONG doi
*								scale tai cho + INSERT theo vi tri => PHAI chay DDL
*								lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql TRUOC dbt run. KHONG --full-refresh.
* 2026-10-02		duc.luxuan			Sua thu tu phep tinh %: X / NULLIF(Y,0) * 100 -> X * 100 / NULLIF(Y,0) (8 cot *_ytd_chg).
*									  Spark ep scale ket qua phep chia decimal(38,x)/decimal(38,x) ve 6 => chia truoc
*									  roi *100 chi con 4 chu so thap phan dung (vd 3.215200 thay vi 3.215241).
* 2026-10-02		duc.luxuan			Chot voi BA: thay doi D/E tu dau nam la TOC DO THAY DOI (%), khong phai chenh lech
*									  tuyet doi. debt_to_equity_ytd_diff (cur - bgn) -> debt_to_equity_ytd_chg
*									  = (cur - bgn) * 100 / ABS(bgn), xu ly NULL giong cac cot *_ytd_chg khac
*									  (bgn NULL => NULL; cur NULL => -100). Doi ten cot => PHAI chay
*									  lakehouse_ubck_v1/ddl/20261002_gsdc_de_ytd_chg.sql TRUOC dbt run.
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
          public_company_dim_id,
          equity_listing_exchange_code,
          business_line_level_1_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_listing_exchange_code IN ('HOSE','HNX','UPCOM','OTC')
),

-- _smy full-recompute moi ngay => partition snpst_dt_dim_id = etl_date da du moi ky.
financial_summary AS (
    SELECT
          public_company_dim_id,
          rpt_year,
          rpt_quarter,
          total_asset,
          total_asset_beginning,
          total_liability,
          total_liability_beginning,
          equity,
          equity_beginning,
          contributed_capital,
          contributed_capital_beginning,
          inventory,
          inventory_beginning,
          undistributed_profit,
          undistributed_profit_beginning,
          receivable,
          receivable_beginning,
          cash_and_equivalent,
          cash_and_equivalent_beginning
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

-- Universe = 4 san hop le (giong dtm_public_company_financial_yoy_rpt).
financial_summary_by_company AS (
    SELECT
          company.equity_listing_exchange_code,
          company.business_line_level_1_code,
          financial_summary.rpt_year,
          financial_summary.rpt_quarter,
          financial_summary.total_asset,
          financial_summary.total_asset_beginning,
          financial_summary.total_liability,
          financial_summary.total_liability_beginning,
          financial_summary.equity,
          financial_summary.equity_beginning,
          financial_summary.contributed_capital,
          financial_summary.contributed_capital_beginning,
          financial_summary.inventory,
          financial_summary.inventory_beginning,
          financial_summary.undistributed_profit,
          financial_summary.undistributed_profit_beginning,
          financial_summary.receivable,
          financial_summary.receivable_beginning,
          financial_summary.cash_and_equivalent,
          financial_summary.cash_and_equivalent_beginning
    FROM financial_summary
    INNER JOIN company
        ON company.public_company_dim_id = financial_summary.public_company_dim_id
),

-- Nhom (san cu the, nganh cu the).
detail_summary AS (
    SELECT
          equity_listing_exchange_code,
          business_line_level_1_code,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)                       AS total_asset_amt,
          SUM(total_asset_beginning)             AS total_asset_bgn_amt,
          SUM(total_liability)                   AS total_liability_amt,
          SUM(total_liability_beginning)         AS total_liability_bgn_amt,
          SUM(equity)                            AS equity_amt,
          SUM(equity_beginning)                  AS equity_bgn_amt,
          SUM(contributed_capital)               AS contributed_capital_amt,
          SUM(contributed_capital_beginning)     AS contributed_capital_bgn_amt,
          SUM(inventory)                         AS inventory_amt,
          SUM(inventory_beginning)               AS inventory_bgn_amt,
          SUM(undistributed_profit)              AS undistributed_profit_amt,
          SUM(undistributed_profit_beginning)    AS undistributed_profit_bgn_amt,
          SUM(receivable)                        AS receivable_amt,
          SUM(receivable_beginning)              AS receivable_bgn_amt,
          SUM(cash_and_equivalent)               AS cash_and_equivalent_amt,
          SUM(cash_and_equivalent_beginning)     AS cash_and_equivalent_bgn_amt,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                          AS debt_to_equity_ratio,
          SUM(total_liability_beginning) / NULLIF(SUM(equity_beginning), 0)      AS debt_to_equity_bgn_ratio
    FROM financial_summary_by_company
    GROUP BY
          equity_listing_exchange_code,
          business_line_level_1_code,
          rpt_year,
          rpt_quarter
),

-- Nhom (san cu the, nganh='ALL') - doc boi dtm_public_company_exchange_financial_summary_rpt.
exchange_summary AS (
    SELECT
          equity_listing_exchange_code,
          CAST('ALL' AS string) AS business_line_level_1_code,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)                       AS total_asset_amt,
          SUM(total_asset_beginning)             AS total_asset_bgn_amt,
          SUM(total_liability)                   AS total_liability_amt,
          SUM(total_liability_beginning)         AS total_liability_bgn_amt,
          SUM(equity)                            AS equity_amt,
          SUM(equity_beginning)                  AS equity_bgn_amt,
          SUM(contributed_capital)               AS contributed_capital_amt,
          SUM(contributed_capital_beginning)     AS contributed_capital_bgn_amt,
          SUM(inventory)                         AS inventory_amt,
          SUM(inventory_beginning)               AS inventory_bgn_amt,
          SUM(undistributed_profit)              AS undistributed_profit_amt,
          SUM(undistributed_profit_beginning)    AS undistributed_profit_bgn_amt,
          SUM(receivable)                        AS receivable_amt,
          SUM(receivable_beginning)              AS receivable_bgn_amt,
          SUM(cash_and_equivalent)               AS cash_and_equivalent_amt,
          SUM(cash_and_equivalent_beginning)     AS cash_and_equivalent_bgn_amt,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                          AS debt_to_equity_ratio,
          SUM(total_liability_beginning) / NULLIF(SUM(equity_beginning), 0)      AS debt_to_equity_bgn_ratio
    FROM financial_summary_by_company
    GROUP BY
          equity_listing_exchange_code,
          rpt_year,
          rpt_quarter
),

-- Nhom (san='ALL', nganh cu the) - doc boi dtm_public_company_exchange_industry_financial_rpt.
industry_summary AS (
    SELECT
          CAST('ALL' AS string) AS equity_listing_exchange_code,
          business_line_level_1_code,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)                       AS total_asset_amt,
          SUM(total_asset_beginning)             AS total_asset_bgn_amt,
          SUM(total_liability)                   AS total_liability_amt,
          SUM(total_liability_beginning)         AS total_liability_bgn_amt,
          SUM(equity)                            AS equity_amt,
          SUM(equity_beginning)                  AS equity_bgn_amt,
          SUM(contributed_capital)               AS contributed_capital_amt,
          SUM(contributed_capital_beginning)     AS contributed_capital_bgn_amt,
          SUM(inventory)                         AS inventory_amt,
          SUM(inventory_beginning)               AS inventory_bgn_amt,
          SUM(undistributed_profit)              AS undistributed_profit_amt,
          SUM(undistributed_profit_beginning)    AS undistributed_profit_bgn_amt,
          SUM(receivable)                        AS receivable_amt,
          SUM(receivable_beginning)              AS receivable_bgn_amt,
          SUM(cash_and_equivalent)               AS cash_and_equivalent_amt,
          SUM(cash_and_equivalent_beginning)     AS cash_and_equivalent_bgn_amt,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                          AS debt_to_equity_ratio,
          SUM(total_liability_beginning) / NULLIF(SUM(equity_beginning), 0)      AS debt_to_equity_bgn_ratio
    FROM financial_summary_by_company
    GROUP BY
          business_line_level_1_code,
          rpt_year,
          rpt_quarter
),

-- Nhom (san='ALL', nganh='ALL') - dong rollup toan thi truong cua exchange_financial_summary_rpt.
market_summary AS (
    SELECT
          CAST('ALL' AS string) AS equity_listing_exchange_code,
          CAST('ALL' AS string) AS business_line_level_1_code,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)                       AS total_asset_amt,
          SUM(total_asset_beginning)             AS total_asset_bgn_amt,
          SUM(total_liability)                   AS total_liability_amt,
          SUM(total_liability_beginning)         AS total_liability_bgn_amt,
          SUM(equity)                            AS equity_amt,
          SUM(equity_beginning)                  AS equity_bgn_amt,
          SUM(contributed_capital)               AS contributed_capital_amt,
          SUM(contributed_capital_beginning)     AS contributed_capital_bgn_amt,
          SUM(inventory)                         AS inventory_amt,
          SUM(inventory_beginning)               AS inventory_bgn_amt,
          SUM(undistributed_profit)              AS undistributed_profit_amt,
          SUM(undistributed_profit_beginning)    AS undistributed_profit_bgn_amt,
          SUM(receivable)                        AS receivable_amt,
          SUM(receivable_beginning)              AS receivable_bgn_amt,
          SUM(cash_and_equivalent)               AS cash_and_equivalent_amt,
          SUM(cash_and_equivalent_beginning)     AS cash_and_equivalent_bgn_amt,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                          AS debt_to_equity_ratio,
          SUM(total_liability_beginning) / NULLIF(SUM(equity_beginning), 0)      AS debt_to_equity_bgn_ratio
    FROM financial_summary_by_company
    GROUP BY
          rpt_year,
          rpt_quarter
),

combined_summary AS (
    SELECT * FROM detail_summary
    UNION ALL
    SELECT * FROM exchange_summary
    UNION ALL
    SELECT * FROM industry_summary
    UNION ALL
    SELECT * FROM market_summary
)

SELECT
     CAST(equity_listing_exchange_code AS string)                          AS equity_listing_exchange_code,
     CAST(business_line_level_1_code AS string)                            AS business_line_level_1_code,
     CAST(rpt_year AS int)                                                 AS rpt_year,
     CAST(rpt_quarter AS int)                                              AS rpt_quarter,
     CASE WHEN total_asset_bgn_amt IS NULL THEN NULL
          WHEN total_asset_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((total_asset_amt - total_asset_bgn_amt) * 100 / NULLIF(ABS(total_asset_bgn_amt), 0) AS decimal(30,6)) END AS total_asset_ytd_chg,
     CASE WHEN inventory_bgn_amt IS NULL THEN NULL
          WHEN inventory_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((inventory_amt - inventory_bgn_amt) * 100 / NULLIF(ABS(inventory_bgn_amt), 0) AS decimal(30,6)) END AS inventory_ytd_chg,
     CASE WHEN total_liability_bgn_amt IS NULL THEN NULL
          WHEN total_liability_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((total_liability_amt - total_liability_bgn_amt) * 100 / NULLIF(ABS(total_liability_bgn_amt), 0) AS decimal(30,6)) END AS total_liability_ytd_chg,
     CASE WHEN equity_bgn_amt IS NULL THEN NULL
          WHEN equity_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((equity_amt - equity_bgn_amt) * 100 / NULLIF(ABS(equity_bgn_amt), 0) AS decimal(30,6)) END AS equity_ytd_chg,
     CASE WHEN contributed_capital_bgn_amt IS NULL THEN NULL
          WHEN contributed_capital_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((contributed_capital_amt - contributed_capital_bgn_amt) * 100 / NULLIF(ABS(contributed_capital_bgn_amt), 0) AS decimal(30,6)) END AS contributed_capital_ytd_chg,
     CASE WHEN undistributed_profit_bgn_amt IS NULL THEN NULL
          WHEN undistributed_profit_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((undistributed_profit_amt - undistributed_profit_bgn_amt) * 100 / NULLIF(ABS(undistributed_profit_bgn_amt), 0) AS decimal(30,6)) END AS undistributed_profit_ytd_chg,
     CASE WHEN receivable_bgn_amt IS NULL THEN NULL
          WHEN receivable_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((receivable_amt - receivable_bgn_amt) * 100 / NULLIF(ABS(receivable_bgn_amt), 0) AS decimal(30,6)) END AS receivable_ytd_chg,
     CASE WHEN cash_and_equivalent_bgn_amt IS NULL THEN NULL
          WHEN cash_and_equivalent_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cash_and_equivalent_amt - cash_and_equivalent_bgn_amt) * 100 / NULLIF(ABS(cash_and_equivalent_bgn_amt), 0) AS decimal(30,6)) END AS cash_and_equivalent_ytd_chg,
     CASE WHEN debt_to_equity_bgn_ratio IS NULL THEN NULL
          WHEN debt_to_equity_ratio IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((debt_to_equity_ratio - debt_to_equity_bgn_ratio) * 100 / NULLIF(ABS(debt_to_equity_bgn_ratio), 0) AS decimal(30,6)) END AS debt_to_equity_ytd_chg,
     CAST('IDS' AS string)                                                 AS src_stm_code,
     Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd') AS rpt_dt
FROM combined_summary
