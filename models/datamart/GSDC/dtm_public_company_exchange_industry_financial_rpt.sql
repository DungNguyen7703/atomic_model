/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_exchange_industry_financial_rpt
* Program name: Dtm Public Company Exchange Industry Financial Rpt
* Created by:
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30						Tao moi: bao cao chi so tai chinh co ban theo CA 2 chieu san x nganh
*										(cross-tab), cung bo chi so voi
*										dtm_public_company_exchange_financial_summary_rpt. Grain:
*										(equity_listing_exchange_code, business_line_level_1_code,
*										rpt_year, rpt_quarter), gom 2 nhom:
*										  - (san cu the, nganh cu the): detail_summary, GROUP BY ca 2 chieu.
*										  - (san='ALL', nganh cu the): industry_summary, GROUP BY nganh.
*										Ca 2 nhom dung CHUNG universe 4 san HOSE/HNX/UPCOM/OTC de
*										"toan san" = tong cong "tung san" cho tung nganh (nhat quan voi
*										dtm_public_company_financial_yoy_rpt). ROA/ROE tinh lai tu
*										SUM(net_profit)/SUM(TSBQ|VCSHBQ), khong SUM/AVG roa/roe per-company.
*										Cot *_yoy LEFT JOIN tu dtm_public_company_financial_yoy_rpt
*										(bang nay da co san 2 nhom tuong ung) — loai tru nganh='ALL' ben
*										yoy de khong keo nham dong rollup. Join nganh dung null-safe <=>
*										vi business_line_level_1_code co the NULL (cong ty chua phan loai).
* 2026-09-30						Bo sung chi tieu co so con thieu so voi dtm_fct_public_company_
*										financial_smy_snpst: receivable, cash_and_equivalent (SUM theo nhom) va
*										chi tieu phai sinh debt_to_equity = SUM(total_liability)/SUM(equity)
*										(khong SUM/AVG ty le per-company, cung nguyen tac ROA/ROE), dang he so
*										nhu _smy. KHONG them cot *_yoy cho 3 cot moi. Cot moi dat sau
*										roe_ytd_yoy_percentage => CAN ALTER TABLE ADD COLUMN ... AFTER tren
*										Spark + ClickHouse truoc khi deploy (incremental_rebase INSERT theo vi
*										tri cot). CHUA CHAY dbt/trace tren datamart.uat_dtm.
* 2026-10-01						Doi y so voi entry 2026-09-30: 3 cot moi CAN co YoY. Lay
*										receivable_yoy, cash_and_equivalent_yoy, debt_to_equity_yoy co san tren
*										dtm_public_company_financial_yoy_rpt (cung universe 4 san) qua yoy_summary,
*										dat xen ke ngay sau cot gia tri tuong ung (dung convention cap _amt/_yoy).
*										CAN ALTER TABLE ADD COLUMN ... AFTER tren Spark + ClickHouse.
* 2026-10-01		duc.luxuan			Bo sung 9 cot % thay doi tu DAU NAM (so voi cot 'So dau nam' BCDKT)
*										lay tu bang moi dtm_public_company_financial_ytd_chg_rpt (CTE
*										ytd_chg_summary, LEFT JOIN cung key voi yoy): <metric>_ytd_chg (%) cho
*										total_asset, inventory, total_liability, equity, contributed_capital,
*										undistributed_profit, receivable, cash_and_equivalent va
*										debt_to_equity_ytd_diff (chenh lech TUYET DOI he so). GIU NGUYEN cac
*										cot *_yoy (user chap nhan thua cot tam thoi). Cot moi dat ngay sau
*										<metric>_yoy tuong ung => CAN ALTER TABLE ADD COLUMN ... AFTER tren
*										Spark + ClickHouse truoc khi deploy.
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 14 cot *_amt decimal(23,2) -> decimal(38,8); 33 cot %/ty le/he so decimal(9,4) -> decimal(30,6).
*								Nguon: atm_fr_value.data_val doi decimal(20,2) -> decimal(38,8). Quy uoc: cot
*								chi tieu co so = (38,8), cot tinh tu phep chia = (30,6). Bang Iceberg KHONG doi
*								scale tai cho + INSERT theo vi tri => PHAI chay DDL
*								lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql TRUOC dbt run. KHONG --full-refresh.
* 2026-10-02		duc.luxuan			Sua thu tu phep tinh %: X / NULLIF(Y,0) * 100 -> X * 100 / NULLIF(Y,0) (cac cot roa/roe *_percentage).
*									  Spark ep scale ket qua phep chia decimal(38,x)/decimal(38,x) ve 6 => chia truoc
*									  roi *100 chi con 4 chu so thap phan dung (vd 3.215200 thay vi 3.215241).
* 2026-10-02		duc.luxuan			Mau so ROA/ROE theo logic BA: gia tri dau ky/cuoi ky NULL hoac = 0 coi la thieu,
*									  lay cot con lai: CASE WHEN COALESCE(x_beginning,0)=0 THEN x ELSE x_beginning END
*									  + CASE WHEN COALESCE(x,0)=0 THEN x_beginning ELSE x END (truoc chi xu ly NULL).
* 2026-10-02		duc.luxuan			Doi ten debt_to_equity_ytd_diff -> debt_to_equity_ytd_chg: chot voi BA la TOC DO
*										THAY DOI (%) cua he so D/E so voi dau nam (tinh o ytd_chg_rpt), khong phai
*										chenh lech tuyet doi. Vi tri cot giu nguyen. PHAI chay
*										lakehouse_ubck_v1/ddl/20261002_gsdc_de_ytd_chg.sql TRUOC dbt run.
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
        public_company_dim_id,
        equity_listing_exchange_code,
        business_line_level_1_code,
        classification_business_line_nm
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_listing_exchange_code IN ('HOSE','HNX','UPCOM','OTC')
),

financial_summary AS (
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        total_asset,
        total_asset_beginning,
        inventory,
        total_liability,
        equity,
        equity_beginning,
        contributed_capital,
        undistributed_profit,
        net_revenue,
        net_revenue_ytd,
        pre_tax_profit,
        pre_tax_profit_ytd,
        net_profit,
        net_profit_ytd,
        receivable,
        cash_and_equivalent
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

-- Universe = 4 san hop le, mang ca 2 chieu san + nganh, dung chung cho detail_summary
-- va industry_summary.
financial_summary_by_company AS (
    SELECT
        company.equity_listing_exchange_code,
        company.business_line_level_1_code,
        company.classification_business_line_nm,
        financial_summary.rpt_year,
        financial_summary.rpt_quarter,
        financial_summary.total_asset,
        financial_summary.total_asset_beginning,
        financial_summary.inventory,
        financial_summary.total_liability,
        financial_summary.equity,
        financial_summary.equity_beginning,
        financial_summary.contributed_capital,
        financial_summary.undistributed_profit,
        financial_summary.net_revenue,
        financial_summary.net_revenue_ytd,
        financial_summary.pre_tax_profit,
        financial_summary.pre_tax_profit_ytd,
        financial_summary.net_profit,
        financial_summary.net_profit_ytd,
        financial_summary.receivable,
        financial_summary.cash_and_equivalent
    FROM financial_summary
    INNER JOIN company
        ON company.public_company_dim_id = financial_summary.public_company_dim_id
),

-- Nhom (san cu the, nganh cu the).
-- ROA/ROE tinh lai tu SUM(net_profit)/SUM(TSBQ hoac VCSHBQ), KHONG SUM/AVG cot
-- roa/roe per-company co san tren Fact (grain-matching, giong Nhom 41).
detail_summary AS (
    SELECT
        equity_listing_exchange_code,
        business_line_level_1_code,
        classification_business_line_nm,
        rpt_year,
        rpt_quarter,
        SUM(total_asset)          AS total_asset_amt,
        SUM(inventory)            AS inventory_amt,
        SUM(total_liability)      AS total_liability_amt,
        SUM(equity)               AS equity_amt,
        SUM(contributed_capital)  AS contributed_capital_amt,
        SUM(undistributed_profit) AS undistributed_profit_amt,
        SUM(net_revenue)          AS net_revenue_amt,
        SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
        SUM(pre_tax_profit)       AS pre_tax_profit_amt,
        SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
        SUM(net_profit)           AS net_profit_amt,
        SUM(net_profit_ytd)       AS net_profit_ytd_amt,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_percentage,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_percentage,
        -- 2026-09-30: chi tieu co so bo sung tu _smy (khong co YoY)
        SUM(receivable)           AS receivable_amt,
        SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
        -- Phai sinh: tinh lai tu tong tu/mau, khong SUM/AVG debt_to_equity per-company
        SUM(total_liability) / NULLIF(SUM(equity), 0) AS debt_to_equity
    FROM financial_summary_by_company
    GROUP BY
        equity_listing_exchange_code,
        business_line_level_1_code,
        classification_business_line_nm,
        rpt_year,
        rpt_quarter
),

-- Nhom (san='ALL', nganh cu the): toan san (4 san) breakdown theo nganh.
industry_summary AS (
    SELECT
        CAST('ALL' AS string)     AS equity_listing_exchange_code,
        business_line_level_1_code,
        classification_business_line_nm,
        rpt_year,
        rpt_quarter,
        SUM(total_asset)          AS total_asset_amt,
        SUM(inventory)            AS inventory_amt,
        SUM(total_liability)      AS total_liability_amt,
        SUM(equity)               AS equity_amt,
        SUM(contributed_capital)  AS contributed_capital_amt,
        SUM(undistributed_profit) AS undistributed_profit_amt,
        SUM(net_revenue)          AS net_revenue_amt,
        SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
        SUM(pre_tax_profit)       AS pre_tax_profit_amt,
        SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
        SUM(net_profit)           AS net_profit_amt,
        SUM(net_profit_ytd)       AS net_profit_ytd_amt,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_percentage,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_percentage,
        -- 2026-09-30: chi tieu co so bo sung tu _smy (khong co YoY)
        SUM(receivable)           AS receivable_amt,
        SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
        -- Phai sinh: tinh lai tu tong tu/mau, khong SUM/AVG debt_to_equity per-company
        SUM(total_liability) / NULLIF(SUM(equity), 0) AS debt_to_equity
    FROM financial_summary_by_company
    GROUP BY
        business_line_level_1_code,
        classification_business_line_nm,
        rpt_year,
        rpt_quarter
),

combined_summary AS (
    SELECT * FROM detail_summary
    UNION ALL
    SELECT * FROM industry_summary
),

-- YoY doc tu dtm_public_company_financial_yoy_rpt: bo dong nganh='ALL' (rollup theo san /
-- grand-total) vi bao cao nay luon breakdown nganh cu the. Dung NOT (... <=> 'ALL') thay
-- vi <> 'ALL' de GIU dong nganh NULL (<> 'ALL' tren NULL la UNKNOWN => bi loai).
yoy_summary AS (
    SELECT
        equity_listing_exchange_code,
        business_line_level_1_code,
        rpt_year,
        rpt_quarter,
        total_asset_yoy,
        inventory_yoy,
        total_liability_yoy,
        equity_yoy,
        contributed_capital_yoy,
        undistributed_profit_yoy,
        net_revenue_yoy,
        net_revenue_ytd_yoy,
        pre_tax_profit_yoy,
        pre_tax_profit_ytd_yoy,
        net_profit_yoy,
        net_profit_ytd_yoy,
        roa_yoy,
        roa_ytd_yoy,
        roe_yoy,
        roe_ytd_yoy,
        receivable_yoy,
        cash_and_equivalent_yoy,
        debt_to_equity_yoy
    FROM {{ ref('dtm_public_company_financial_yoy_rpt') }}
    WHERE NOT (business_line_level_1_code <=> 'ALL')
        AND rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

-- 2026-10-01: % thay doi tu dau nam (9 chi tieu BCDKT) doc tu dtm_public_company_financial_ytd_chg_rpt,
-- loc dong nganh cu the (NOT <=> 'ALL', giu nganh NULL) + rpt_dt = etl_date, dong pattern yoy_summary.
ytd_chg_summary AS (
    SELECT
        equity_listing_exchange_code,
        business_line_level_1_code,
        rpt_year,
        rpt_quarter,
        total_asset_ytd_chg,
        inventory_ytd_chg,
        total_liability_ytd_chg,
        equity_ytd_chg,
        contributed_capital_ytd_chg,
        undistributed_profit_ytd_chg,
        receivable_ytd_chg,
        cash_and_equivalent_ytd_chg,
        debt_to_equity_ytd_chg
    FROM {{ ref('dtm_public_company_financial_ytd_chg_rpt') }}
    WHERE NOT (business_line_level_1_code <=> 'ALL')
        AND rpt_dt = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
)

SELECT
    CAST(combined_summary.equity_listing_exchange_code AS string)    AS equity_listing_exchange_code,
    CAST(combined_summary.business_line_level_1_code AS string)      AS business_line_level_1_code,
    CAST(combined_summary.classification_business_line_nm AS string) AS business_line_level_1_name,
    CAST(combined_summary.rpt_year AS int)                           AS rpt_year,
    CAST(combined_summary.rpt_quarter AS int)                        AS rpt_quarter,
    CAST(combined_summary.total_asset_amt AS decimal(38,8))          AS total_asset_amt,
    CAST(yoy.total_asset_yoy AS decimal(30,6))                        AS total_asset_yoy,
    CAST(ytd_chg.total_asset_ytd_chg AS decimal(30,6))                AS total_asset_ytd_chg,
    CAST(combined_summary.inventory_amt AS decimal(38,8))            AS inventory_amt,
    CAST(yoy.inventory_yoy AS decimal(30,6))                          AS inventory_yoy,
    CAST(ytd_chg.inventory_ytd_chg AS decimal(30,6))                  AS inventory_ytd_chg,
    CAST(combined_summary.total_liability_amt AS decimal(38,8))      AS total_liability_amt,
    CAST(yoy.total_liability_yoy AS decimal(30,6))                    AS total_liability_yoy,
    CAST(ytd_chg.total_liability_ytd_chg AS decimal(30,6))            AS total_liability_ytd_chg,
    CAST(combined_summary.equity_amt AS decimal(38,8))               AS equity_amt,
    CAST(yoy.equity_yoy AS decimal(30,6))                             AS equity_yoy,
    CAST(ytd_chg.equity_ytd_chg AS decimal(30,6))                     AS equity_ytd_chg,
    CAST(combined_summary.contributed_capital_amt AS decimal(38,8))  AS contributed_capital_amt,
    CAST(yoy.contributed_capital_yoy AS decimal(30,6))                AS contributed_capital_yoy,
    CAST(ytd_chg.contributed_capital_ytd_chg AS decimal(30,6))        AS contributed_capital_ytd_chg,
    CAST(combined_summary.undistributed_profit_amt AS decimal(38,8)) AS undistributed_profit_amt,
    CAST(yoy.undistributed_profit_yoy AS decimal(30,6))               AS undistributed_profit_yoy,
    CAST(ytd_chg.undistributed_profit_ytd_chg AS decimal(30,6))       AS undistributed_profit_ytd_chg,
    CAST(combined_summary.net_revenue_amt AS decimal(38,8))          AS net_revenue_amt,
    CAST(yoy.net_revenue_yoy AS decimal(30,6))                        AS net_revenue_yoy,
    CAST(combined_summary.net_revenue_ytd_amt AS decimal(38,8))      AS net_revenue_ytd_amt,
    CAST(yoy.net_revenue_ytd_yoy AS decimal(30,6))                    AS net_revenue_ytd_yoy,
    CAST(combined_summary.pre_tax_profit_amt AS decimal(38,8))       AS pre_tax_profit_amt,
    CAST(yoy.pre_tax_profit_yoy AS decimal(30,6))                     AS pre_tax_profit_yoy,
    CAST(combined_summary.pre_tax_profit_ytd_amt AS decimal(38,8))   AS pre_tax_profit_ytd_amt,
    CAST(yoy.pre_tax_profit_ytd_yoy AS decimal(30,6))                 AS pre_tax_profit_ytd_yoy,
    CAST(combined_summary.net_profit_amt AS decimal(38,8))           AS net_profit_amt,
    CAST(yoy.net_profit_yoy AS decimal(30,6))                         AS net_profit_yoy,
    CAST(combined_summary.net_profit_ytd_amt AS decimal(38,8))       AS net_profit_ytd_amt,
    CAST(yoy.net_profit_ytd_yoy AS decimal(30,6))                     AS net_profit_ytd_yoy,
    CAST(combined_summary.roa_percentage AS decimal(30,6))            AS roa_percentage,
    CAST(yoy.roa_yoy AS decimal(30,6))                                AS roa_yoy_percentage,
    CAST(combined_summary.roa_ytd_percentage AS decimal(30,6))        AS roa_ytd_percentage,
    CAST(yoy.roa_ytd_yoy AS decimal(30,6))                            AS roa_ytd_yoy_percentage,
    CAST(combined_summary.roe_percentage AS decimal(30,6))            AS roe_percentage,
    CAST(yoy.roe_yoy AS decimal(30,6))                                AS roe_yoy_percentage,
    CAST(combined_summary.roe_ytd_percentage AS decimal(30,6))        AS roe_ytd_percentage,
    CAST(yoy.roe_ytd_yoy AS decimal(30,6))                            AS roe_ytd_yoy_percentage,
    CAST(combined_summary.receivable_amt AS decimal(38,8))           AS receivable_amt,
    CAST(yoy.receivable_yoy AS decimal(30,6))                         AS receivable_yoy,
    CAST(ytd_chg.receivable_ytd_chg AS decimal(30,6))                 AS receivable_ytd_chg,
    CAST(combined_summary.cash_and_equivalent_amt AS decimal(38,8))  AS cash_and_equivalent_amt,
    CAST(yoy.cash_and_equivalent_yoy AS decimal(30,6))                AS cash_and_equivalent_yoy,
    CAST(ytd_chg.cash_and_equivalent_ytd_chg AS decimal(30,6))        AS cash_and_equivalent_ytd_chg,
    CAST(combined_summary.debt_to_equity AS decimal(30,6))            AS debt_to_equity,
    CAST(yoy.debt_to_equity_yoy AS decimal(30,6))                     AS debt_to_equity_yoy,
    CAST(ytd_chg.debt_to_equity_ytd_chg AS decimal(30,6))             AS debt_to_equity_ytd_chg,
    CAST('IDS' AS string)                                            AS src_stm_code,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd') AS rpt_dt
FROM combined_summary
LEFT JOIN yoy_summary yoy
    ON  yoy.equity_listing_exchange_code <=> combined_summary.equity_listing_exchange_code
    AND yoy.business_line_level_1_code <=> combined_summary.business_line_level_1_code
    AND yoy.rpt_year = combined_summary.rpt_year
    AND yoy.rpt_quarter <=> combined_summary.rpt_quarter
LEFT JOIN ytd_chg_summary ytd_chg
    ON  ytd_chg.equity_listing_exchange_code <=> combined_summary.equity_listing_exchange_code
    AND ytd_chg.business_line_level_1_code <=> combined_summary.business_line_level_1_code
    AND ytd_chg.rpt_year = combined_summary.rpt_year
    AND ytd_chg.rpt_quarter <=> combined_summary.rpt_quarter
