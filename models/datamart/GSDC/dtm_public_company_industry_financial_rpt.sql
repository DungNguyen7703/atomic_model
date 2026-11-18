/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_industry_financial_rpt
* Program name: Dtm Public Company Industry Financial Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-21						Sync tu ban de xuat cua nguoi thiet ke (xu ly thoi gian): them
*										dieu kien fct.rpt_quarter = 5 vao fct_base — thieu dieu kien nay,
*										combined_agg GROUP BY rpt_year (khong co rpt_quarter) se SUM chong
*										ca report quy hien tai (1-4) va report nam/6-thang (5,6) cung nam N
*										(ca 2 loai co the cung ton tai trong 1 snpst_dt_dim_id theo window
*										cua dtm_fct_public_company_financial_smy_snpst), ra so bi thoi phong.
*										Khong can them dedup ROW_NUMBER kieu multi_period vi report nam chi
*										can N/N-1 — da nam du trong dung 1 ngay snapshot (snpst_dt_dim_id =
*										etl_date), khac multi_period phai lui toi N-2 nen moi can quet nhieu
*										ngay + dedup. Them dong rollup 'ALL' toan thi truong (combined_mkt/
*										combined_all), dong pattern voi dtm_public_company_financial_yoy_rpt.
* 2026-08-27						Fix: row driver cu (year_n1 LEFT JOIN tu combined_all cur) chi sinh
*										dong cho nganh CO data nam N, nen nganh chua co bao cao nam N (vd
*										chua den han nop) bi mat hoan toan dong, keo theo mat luon N-1 du
*										N-1 van du lieu day du. Doi sang industry_year_keys = union nganh
*										co data o N hoac N-1 (gioi han rpt_year <= nam etl_date de khong
*										sinh dong "N+1" ao ngoai pham vi cua fct_base). Join keys->cur/prev
*										dung null-safe equal (<=>) thay vi = vi business_line_level_1_code
*										co the NULL (nhom cong ty chua phan loai nganh) — NULL = NULL la
*										UNKNOWN nen se lam mat trang toan bo dong cua nhom nay neu dung =.
* 2026-09-17						Doi grain tu nam sang nam+quy (them rpt_quarter): bo dieu kien loc
*										rpt_quarter = 5 (chi lay report nam) o fct_base, GROUP BY them
*										rpt_quarter o industry_summary/market_summary, industry_year_keys
*										va join cur/prev deu them rpt_quarter (null-safe <=>). Khong con
*										rui ro SUM chong quy/nam nhu truoc vi moi (nam, quy) la 1 group
*										rieng, khong con phu thuoc dieu kien loc quarter=5 nua.
* 2026-09-30						Bo sung chi tieu co so con thieu so voi dtm_fct_public_company_
*										financial_smy_snpst, CHI cho nam N (khong tinh N-1): total_asset,
*										total_liability, equity, contributed_capital, pre_tax_profit,
*										pre_tax_profit_ytd, inventory, undistributed_profit, receivable,
*										cash_and_equivalent (SUM theo nganh/ALL). Chi tieu phai sinh
*										debt_to_equity tinh lai SUM(total_liability)/SUM(equity) (khong SUM/AVG
*										ty le per-company, cung nguyen tac voi ROA/ROE), dang he so nhu _smy.
*										Cot moi dat sau roe_ytd_percentage_year_n => CAN ALTER TABLE ADD COLUMN
*										... AFTER tren Spark + ClickHouse truoc khi deploy (incremental_rebase
*										INSERT theo vi tri cot). CHUA CHAY dbt/trace tren datamart.uat_dtm.
* 2026-10-01						Bo sung YoY cho 11 cot moi (entry 2026-09-30), TU TINH ngay trong
*										model nay tu cap cur/prev (N vs N-1) da co san, KHONG tai su dung
*										dtm_public_company_financial_yoy_rpt: bang yoy tinh tren universe 4 san
*										HOSE/HNX/UPCOM/OTC va dong ('ALL', nganh)/('ALL','ALL') cua no con duoc
*										2 bang exchange doc (can 4 san), trong khi thong ke nganh o day KHONG
*										gioi han san (moi cong ty) => join sang se lech universe voi _amt_year_n.
*										Cong thuc theo BA confirm 2026-08-21 (giong bang yoy): prev NULL => NULL;
*										cur NULL => -100; con lai (cur-prev)/ABS(prev)*100, decimal(9,4).
*										debt_to_equity_yoy tinh tren he so debt_to_equity da tinh lai tu SUM.
*										Cot <metric>_yoy dat xen ke ngay sau <metric>_amt_year_n tuong ung.
*										CAN ALTER TABLE ADD COLUMN ... AFTER. CHUA CHAY dbt/trace.
* 2026-10-01		duc.luxuan			Doi y so voi entry 2026-10-01 o tren: bang nganh KHONG thong ke %
*										thay doi => BO 11 cot *_yoy (total_asset_yoy, total_liability_yoy,
*										equity_yoy, contributed_capital_yoy, pre_tax_profit_yoy,
*										pre_tax_profit_ytd_yoy, inventory_yoy, undistributed_profit_yoy,
*										receivable_yoy, cash_and_equivalent_yoy, debt_to_equity_yoy). GIU
*										industry_year_keys + join prev vi van con cac cot *_year_n1. % thay doi
*										tu dau nam chi lam cho 2 bang san/san-nganh (qua
*										dtm_public_company_financial_ytd_chg_rpt), khong ap dung o day.
*										CAN ALTER TABLE DROP COLUMN tren Spark + ClickHouse truoc khi deploy.
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 18 cot *_amt decimal(23,2) -> decimal(38,8); 9 cot %/he so decimal(9,4) -> decimal(30,6).
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
* 2026-11-06		duc.luxuan			Dong bo LLD (O_GSDC, y/c dev 2026-11-03): them 2 cot reported_company_qty_year_n /
*									  reported_company_qty_year_n1 = COUNT(DISTINCT public_company_dim_id) tren fct smy_snpst
*									  (chi cong ty thuoc 4 san, da loc o CTE company), GROUP BY nganh/ALL, rpt_year, rpt_quarter
*									  (grain nam+quy, khop entry 2026-09-17). Dat sau roe_ytd_percentage_year_n1, truoc src_stm_code
*									  => CAN ALTER TABLE ADD COLUMN ... AFTER tren Spark + ClickHouse truoc khi deploy.
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
        public_company_dim_id,
        business_line_level_1_code,
        classification_business_line_nm
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_listing_exchange_code IN ('HOSE','HNX','UPCOM','OTC')
),

financial_summary_raw AS (
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        net_revenue,
        net_revenue_ytd,
        net_profit,
        net_profit_ytd,
        total_asset,
        total_asset_beginning,
        equity,
        equity_beginning,
        total_liability,
        contributed_capital,
        pre_tax_profit,
        pre_tax_profit_ytd,
        inventory,
        undistributed_profit,
        receivable,
        cash_and_equivalent
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

financial_summary_by_industry AS (
    SELECT
        financial_summary_raw.public_company_dim_id,
        company.business_line_level_1_code,
        company.classification_business_line_nm,
        financial_summary_raw.rpt_year,
        financial_summary_raw.rpt_quarter,
        financial_summary_raw.net_revenue,
        financial_summary_raw.net_revenue_ytd,
        financial_summary_raw.net_profit,
        financial_summary_raw.net_profit_ytd,
        financial_summary_raw.total_asset,
        financial_summary_raw.total_asset_beginning,
        financial_summary_raw.equity,
        financial_summary_raw.equity_beginning,
        financial_summary_raw.total_liability,
        financial_summary_raw.contributed_capital,
        financial_summary_raw.pre_tax_profit,
        financial_summary_raw.pre_tax_profit_ytd,
        financial_summary_raw.inventory,
        financial_summary_raw.undistributed_profit,
        financial_summary_raw.receivable,
        financial_summary_raw.cash_and_equivalent
    FROM financial_summary_raw
    INNER JOIN company
        ON company.public_company_dim_id = financial_summary_raw.public_company_dim_id
),

-- ROA/ROE muc nganh tinh lai tu SUM(net_profit)/SUM(TSBQ hoac VCSHBQ), KHONG SUM/AVG cot
-- roa/roe per-company co san tren Fact (grain-matching, giong Nhom 41).
industry_summary AS (
    SELECT
        business_line_level_1_code,
        classification_business_line_nm,
        rpt_year,
        rpt_quarter,
        SUM(net_revenue)     AS net_revenue_amt,
        SUM(net_revenue_ytd) AS net_revenue_ytd_amt,
        SUM(net_profit)      AS net_profit_amt,
        SUM(net_profit_ytd)  AS net_profit_ytd_amt,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_percentage,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_percentage,
        -- 2026-09-30: chi tieu co so bo sung tu _smy (chi output nam N)
        SUM(total_asset)          AS total_asset_amt,
        SUM(total_liability)      AS total_liability_amt,
        SUM(equity)               AS equity_amt,
        SUM(contributed_capital)  AS contributed_capital_amt,
        SUM(pre_tax_profit)       AS pre_tax_profit_amt,
        SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
        SUM(inventory)            AS inventory_amt,
        SUM(undistributed_profit) AS undistributed_profit_amt,
        SUM(receivable)           AS receivable_amt,
        SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
        -- Phai sinh: tinh lai tu tong tu/mau, khong SUM/AVG debt_to_equity per-company
        SUM(total_liability) / NULLIF(SUM(equity), 0) AS debt_to_equity,
        -- 2026-11-06: so cong ty da ghi nhan du lieu bao cao (O_GSDC, y/c dev 2026-11-03)
        COUNT(DISTINCT public_company_dim_id) AS reported_company_qty
    FROM financial_summary_by_industry
    GROUP BY 
        business_line_level_1_code, 
        classification_business_line_nm, 
        rpt_year, 
        rpt_quarter
),

-- Nhom 'ALL': rollup toan thi truong, khong GROUP BY theo nganh.
market_summary AS (
    SELECT
        CAST('ALL' AS string) AS business_line_level_1_code,
        CAST('ALL' AS string) AS classification_business_line_nm,
        rpt_year,
        rpt_quarter,
        SUM(net_revenue)     AS net_revenue_amt,
        SUM(net_revenue_ytd) AS net_revenue_ytd_amt,
        SUM(net_profit)      AS net_profit_amt,
        SUM(net_profit_ytd)  AS net_profit_ytd_amt,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_percentage,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_percentage,
        -- 2026-09-30: chi tieu co so bo sung tu _smy (chi output nam N)
        SUM(total_asset)          AS total_asset_amt,
        SUM(total_liability)      AS total_liability_amt,
        SUM(equity)               AS equity_amt,
        SUM(contributed_capital)  AS contributed_capital_amt,
        SUM(pre_tax_profit)       AS pre_tax_profit_amt,
        SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
        SUM(inventory)            AS inventory_amt,
        SUM(undistributed_profit) AS undistributed_profit_amt,
        SUM(receivable)           AS receivable_amt,
        SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
        -- Phai sinh: tinh lai tu tong tu/mau, khong SUM/AVG debt_to_equity per-company
        SUM(total_liability) / NULLIF(SUM(equity), 0) AS debt_to_equity,
        -- 2026-11-06: so cong ty da ghi nhan du lieu bao cao (O_GSDC, y/c dev 2026-11-03)
        COUNT(DISTINCT public_company_dim_id) AS reported_company_qty
    FROM financial_summary_by_industry
    GROUP BY 
        rpt_year, 
        rpt_quarter
),

combined_summary AS (
    SELECT * FROM industry_summary
    UNION ALL
    SELECT * FROM market_summary
),

-- Union nganh co data o N hoac N-1, gioi han <= nam etl_date de khop dung
-- pham vi (nam etl_date, nam etl_date - 1) ma fct_base da loc san.
industry_year_keys AS (
    SELECT DISTINCT business_line_level_1_code, rpt_year, rpt_quarter FROM combined_summary
    UNION
    SELECT DISTINCT business_line_level_1_code, rpt_year + 1, rpt_quarter FROM combined_summary
)

SELECT
    CAST(keys.business_line_level_1_code AS string)                       AS business_line_level_1_code,
    CAST(COALESCE(cur.classification_business_line_nm,
                  prev.classification_business_line_nm) AS string)        AS business_line_level_1_name,
    CAST(keys.rpt_year AS int)                                            AS rpt_year,
    CAST(keys.rpt_quarter AS int)                                         AS rpt_quarter,
    CAST(cur.net_revenue_amt AS decimal(38,8))                            AS net_revenue_amt_year_n,
    CAST(cur.net_revenue_ytd_amt AS decimal(38,8))                        AS net_revenue_ytd_amt_year_n,
    CAST(cur.net_profit_amt AS decimal(38,8))                             AS net_profit_amt_year_n,
    CAST(cur.net_profit_ytd_amt AS decimal(38,8))                         AS net_profit_ytd_amt_year_n,
    CAST(cur.roa_percentage AS decimal(30,6))                              AS roa_percentage_year_n,
    CAST(cur.roa_ytd_percentage AS decimal(30,6))                          AS roa_ytd_percentage_year_n,
    CAST(cur.roe_percentage AS decimal(30,6))                              AS roe_percentage_year_n,
    CAST(cur.roe_ytd_percentage AS decimal(30,6))                          AS roe_ytd_percentage_year_n,
    CAST(cur.total_asset_amt AS decimal(38,8))                            AS total_asset_amt_year_n,
    CAST(cur.total_liability_amt AS decimal(38,8))                        AS total_liability_amt_year_n,
    CAST(cur.equity_amt AS decimal(38,8))                                 AS equity_amt_year_n,
    CAST(cur.contributed_capital_amt AS decimal(38,8))                    AS contributed_capital_amt_year_n,
    CAST(cur.pre_tax_profit_amt AS decimal(38,8))                         AS pre_tax_profit_amt_year_n,
    CAST(cur.pre_tax_profit_ytd_amt AS decimal(38,8))                     AS pre_tax_profit_ytd_amt_year_n,
    CAST(cur.inventory_amt AS decimal(38,8))                              AS inventory_amt_year_n,
    CAST(cur.undistributed_profit_amt AS decimal(38,8))                   AS undistributed_profit_amt_year_n,
    CAST(cur.receivable_amt AS decimal(38,8))                             AS receivable_amt_year_n,
    CAST(cur.cash_and_equivalent_amt AS decimal(38,8))                    AS cash_and_equivalent_amt_year_n,
    CAST(cur.debt_to_equity AS decimal(30,6))                              AS debt_to_equity_year_n,
    CAST(prev.net_revenue_amt AS decimal(38,8))                           AS net_revenue_amt_year_n1,
    CAST(prev.net_revenue_ytd_amt AS decimal(38,8))                       AS net_revenue_ytd_amt_year_n1,
    CAST(prev.net_profit_amt AS decimal(38,8))                            AS net_profit_amt_year_n1,
    CAST(prev.net_profit_ytd_amt AS decimal(38,8))                        AS net_profit_ytd_amt_year_n1,
    CAST(prev.roa_percentage AS decimal(30,6))                             AS roa_percentage_year_n1,
    CAST(prev.roa_ytd_percentage AS decimal(30,6))                         AS roa_ytd_percentage_year_n1,
    CAST(prev.roe_percentage AS decimal(30,6))                             AS roe_percentage_year_n1,
    CAST(prev.roe_ytd_percentage AS decimal(30,6))                         AS roe_ytd_percentage_year_n1,
    CAST(cur.reported_company_qty AS int)                                 AS reported_company_qty_year_n,
    CAST(prev.reported_company_qty AS int)                                AS reported_company_qty_year_n1,
    CAST('IDS' AS string)                                                 AS src_stm_code,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd') AS rpt_dt
FROM industry_year_keys keys
LEFT JOIN combined_summary cur
    ON  cur.business_line_level_1_code <=> keys.business_line_level_1_code
    AND cur.rpt_year = keys.rpt_year
    AND cur.rpt_quarter <=> keys.rpt_quarter
LEFT JOIN combined_summary prev
    ON  prev.business_line_level_1_code <=> keys.business_line_level_1_code
    AND prev.rpt_year = keys.rpt_year - 1
    AND prev.rpt_quarter <=> keys.rpt_quarter
-- WHERE keys.rpt_year <= YEAR(TO_DATE('{{ var("etl_date") }}', 'yyyy-MM-dd'))
