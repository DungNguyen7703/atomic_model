/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_multi_period_financial_rpt
* Program name: Dtm Public Company Multi Period Financial Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-19		Sync LLD (GSDC): bo toan bo raw Atomic join chain (fr_value →
*					pc_report_submission → financial_report_catalog → fr_row_template →
*					fr_column_template), thay bang SUM(...) truc tiep tren
*					fct_public_company_financial_smy_snpst (Gold-to-Gold), khong GROUP BY (grain
*					toan thi truong, moi ky 1 dong gia tri duy nhat). charter_capital_amt lay tu
*					cot contributed_capital cua Fact. LLD danh dau lai rpt_year tu key=DD sang
*					key=PK (metadata, khong doi kieu du lieu/CAST).
* 2026-08-27		Fix bug BA log: cot N-1/N-2 sai voi cac rpt_year != nam cua etl_date. Nguyen
*					nhan: year_n1/year_n2 la CTE rieng, loc theo YEAR(etl_date)-1/-2 (co dinh 1
*					cap gia tri), roi CROSS JOIN (ON 1=1) vao moi dong combined_agg => chi dong
*					rpt_year = nam cua etl_date la khop dung, cac nam khac bi gan nham. Sua: bo
*					2 CTE, thay bang self-join combined_agg voi chinh no theo offset rpt_year
*					(year_n1.rpt_year = rpt_year - 1, year_n2.rpt_year = rpt_year - 2) de dung
*					cho tung dong, khong phu thuoc etl_date.
* 2026-09-17		Doi grain tu nam sang nam+quy (them rpt_quarter): bo dieu kien loc
*					rpt_quarter = 5 (chi lay report nam) o financial_summary_dedup, GROUP BY
*					them rpt_quarter o market_summary, self-join year_n1/year_n2 them dieu
*					kien rpt_quarter <=> (null-safe) de so sanh dung cung quy giua cac nam.
* 2026-09-19		Bo CTE financial_summary_dedup (quet snpst_dt_dim_id <= etl_date +
*					ROW_NUMBER lay ban ghi moi nhat). Ly do: dedup nay la workaround cho
*					_smy_ ban cu (incremental theo ngay, moi ngay chi tinh dung 1 ky hien
*					hanh nen 1 (company,rpt_year,rpt_quarter) co nhieu ban ghi rai qua nhieu
*					partition ngay, phai quet nguoc + ROW_NUMBER moi lay dung ban moi nhat).
*					Tu khi _smy_ doi thanh full-recompute moi ngay (xem changelog 2026-09-19
*					cua dtm_fct_public_company_financial_smy_snpst.sql), moi partition
*					snpst_dt_dim_id=etl_date da tu than la dung 1 dong/(company,rpt_year,
*					rpt_quarter) voi gia tri moi nhat (dedup resubmission xu ly san trong
*					_smy_, GROUP BY cuoi cua _smy_ dam bao grain unique). Quet <= nhieu ngay
*					+ dedup lai o day vua du thua vua ton kem (mot _smy_ da phinh to du full
*					lich su). Fix: financial_summary doc thang tu source, loc dung
*					snpst_dt_dim_id = etl_date, giu nguyen dieu kien N/N-1/N-2.
* 2026-09-19		DOI TIEP so voi fix cung ngay o tren: nguoi yeu cau chi ra dieu kien
*					N/N-1/N-2 (ca o financial_summary lan WHERE cuoi cung) khien cong ty
*					nop bu BCTC tre (vd 8-10 nam, da xac nhan co that tren du lieu - xem
*					changelog 2026-09-19 cua dtm_public_company_regulatory_compliance_rpt.sql)
*					KHONG BAO GIO duoc tinh lai: cua so N/N-1/N-2 luon truot theo etl_date,
*					mot khi 1 nam da lui qua N-2 se vinh vien khong con co hoi xuat hien lai
*					trong report, du _smy_ (nguon) da co du lieu day du cho nam do. Fix: ap
*					dung dung cach tiep can full-recompute nhu
*					dtm_public_company_regulatory_compliance_rpt.sql - bo dieu kien loc
*					rpt_year o financial_summary (doc toan bo lich su tu _smy_ cho dung 1
*					partition snpst_dt_dim_id=etl_date), va bo WHERE market_summary.rpt_year
*					= YEAR(etl_date) o cuoi (truoc day gan nham la "TEST-ONLY", thuc chat la
*					gioi han san pham that su can go bo). Output tu day tro di se co 1
*					dong/(rpt_year,rpt_quarter) cho TOAN BO lich su thay vi chi 1 dong nam
*					hien tai - self-join year_n1/year_n2 (fix 2026-08-27) da tong quat theo
*					offset rpt_year nen khong can sua, tu dong dung cho moi nam.
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 18 cot *_amt decimal(23,2) -> decimal(38,8); 12 cot roa/roe decimal(9,4) -> decimal(30,6).
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
*--------------------------------------------------------------------*
*/

WITH company AS (
    SELECT
        public_company_dim_id
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_listing_exchange_code IN ('HOSE','HNX','UPCOM','OTC')
),

financial_summary AS (
    -- _smy_ full-recompute moi ngay => partition = etl_date da la dung 1 dong/(company,
    -- rpt_year, rpt_quarter), gia tri moi nhat tinh den ngay chay. Khong can quet nhieu
    -- ngay (<=) hay ROW_NUMBER dedup lai o day nua.
    -- FIX 2026-09-19: bo dieu kien loc rpt_year IN (N,N-1,N-2) - gioi han nay lam cong ty
    -- nop bu BCTC qua han nhieu nam khong bao gio duoc tinh lai (xem changelog dau file).
    -- Doc toan bo lich su rpt_year co trong partition ngay hom nay, dung cach tiep can
    -- full-recompute nhu dtm_public_company_regulatory_compliance_rpt.sql.
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        total_asset,
        total_asset_beginning,
        total_liability,
        equity,
        equity_beginning,
        contributed_capital,
        net_profit,
        net_profit_ytd
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

-- ROA/ROE toan thi truong tinh lai tu SUM(net_profit)/SUM(TSBQ hoac VCSHBQ), KHONG SUM/AVG
-- cot roa/roe per-company co san tren Fact (grain-matching, giong Nhom 41).
market_summary AS (
    SELECT
        rpt_year,
        rpt_quarter,
        SUM(total_asset)         AS total_asset_amt,
        SUM(total_liability)     AS total_liability_amt,
        SUM(equity)              AS equity_amt,
        SUM(contributed_capital) AS charter_capital_amt,
        SUM(net_profit)          AS net_profit_amt,
        SUM(net_profit_ytd)      AS net_profit_ytd_amt,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_percentage,
        SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_percentage,
        SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_percentage
    FROM financial_summary
    INNER JOIN company
        ON company.public_company_dim_id = financial_summary.public_company_dim_id
    GROUP BY 
        rpt_year, 
        rpt_quarter
)

SELECT
    CAST(market_summary.rpt_year AS int)                      AS rpt_year,
    CAST(market_summary.rpt_quarter AS int)                   AS rpt_quarter,
    CAST(market_summary.total_asset_amt AS decimal(38,8))     AS total_asset_amt_year_n,
    CAST(market_summary.total_liability_amt AS decimal(38,8)) AS total_liability_amt_year_n,
    CAST(market_summary.equity_amt AS decimal(38,8))          AS equity_amt_year_n,
    CAST(market_summary.charter_capital_amt AS decimal(38,8)) AS charter_capital_amt_year_n,
    CAST(market_summary.net_profit_amt AS decimal(38,8))      AS net_profit_amt_year_n,
    CAST(market_summary.net_profit_ytd_amt AS decimal(38,8))  AS net_profit_ytd_amt_year_n,
    CAST(market_summary.roa_percentage AS decimal(30,6))       AS roa_percentage_year_n,
    CAST(market_summary.roa_ytd_percentage AS decimal(30,6))   AS roa_ytd_percentage_year_n,
    CAST(market_summary.roe_percentage AS decimal(30,6))       AS roe_percentage_year_n,
    CAST(market_summary.roe_ytd_percentage AS decimal(30,6))   AS roe_ytd_percentage_year_n,
    CAST(year_n1.total_asset_amt AS decimal(38,8))          AS total_asset_amt_year_n1,
    CAST(year_n1.total_liability_amt AS decimal(38,8))      AS total_liability_amt_year_n1,
    CAST(year_n1.equity_amt AS decimal(38,8))               AS equity_amt_year_n1,
    CAST(year_n1.charter_capital_amt AS decimal(38,8))      AS charter_capital_amt_year_n1,
    CAST(year_n1.net_profit_amt AS decimal(38,8))           AS net_profit_amt_year_n1,
    CAST(year_n1.net_profit_ytd_amt AS decimal(38,8))       AS net_profit_ytd_amt_year_n1,
    CAST(year_n1.roa_percentage AS decimal(30,6))            AS roa_percentage_year_n1,
    CAST(year_n1.roa_ytd_percentage AS decimal(30,6))        AS roa_ytd_percentage_year_n1,
    CAST(year_n1.roe_percentage AS decimal(30,6))            AS roe_percentage_year_n1,
    CAST(year_n1.roe_ytd_percentage AS decimal(30,6))        AS roe_ytd_percentage_year_n1,
    CAST(year_n2.total_asset_amt AS decimal(38,8))          AS total_asset_amt_year_n2,
    CAST(year_n2.total_liability_amt AS decimal(38,8))      AS total_liability_amt_year_n2,
    CAST(year_n2.equity_amt AS decimal(38,8))               AS equity_amt_year_n2,
    CAST(year_n2.charter_capital_amt AS decimal(38,8))      AS charter_capital_amt_year_n2,
    CAST(year_n2.net_profit_amt AS decimal(38,8))           AS net_profit_amt_year_n2,
    CAST(year_n2.net_profit_ytd_amt AS decimal(38,8))       AS net_profit_ytd_amt_year_n2,
    CAST(year_n2.roa_percentage AS decimal(30,6))            AS roa_percentage_year_n2,
    CAST(year_n2.roa_ytd_percentage AS decimal(30,6))        AS roa_ytd_percentage_year_n2,
    CAST(year_n2.roe_percentage AS decimal(30,6))            AS roe_percentage_year_n2,
    CAST(year_n2.roe_ytd_percentage AS decimal(30,6))        AS roe_ytd_percentage_year_n2,
    CAST('IDS' AS string)                                   AS src_stm_code,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd') AS rpt_dt
FROM market_summary
-- Self-join theo offset rpt_year (thay vi CTE co dinh theo etl_date) de N-1/N-2 dung
-- cho tung dong rpt_year, ke ca khi combined_agg tra nhieu nam (BA test multi-year).
-- rpt_quarter phai khop (<=>) giua cac ky de so sanh dung cung quy nam truoc/nam sau.
LEFT JOIN market_summary AS year_n1
    ON  year_n1.rpt_year = market_summary.rpt_year - 1
    AND year_n1.rpt_quarter <=> market_summary.rpt_quarter
LEFT JOIN market_summary AS year_n2
    ON  year_n2.rpt_year = market_summary.rpt_year - 2
    AND year_n2.rpt_quarter <=> market_summary.rpt_quarter
-- FIX 2026-09-19: bo WHERE rpt_year = YEAR(etl_date) - gioi han nay khien cong ty nop bu
-- BCTC qua han nhieu nam khong bao gio duoc phan anh lai (xem changelog dau file). Output
-- gio la full history: 1 dong/(rpt_year,rpt_quarter) cho moi nam co du lieu trong _smy_,
-- moi dong van co N-1/N-2 di kem qua self-join offset o tren.
