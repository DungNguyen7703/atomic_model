/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_financial_yoy_rpt
* Program name: Dtm Public Company Financial YoY Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-21						BA confirm xu ly NULL cho tat ca cot *_yoy: (1) prev NULL
*									(chua co ky truoc de so sanh, ke ca khi cur cung NULL) => NULL;
*									(2) prev co gia tri, cur NULL (mat du lieu ky nay) => -100;
*									(3) ca 2 co gia tri => cong thuc (cur-prev)/ABS(prev)*100 nhu cu.
* 2026-09-18						[ROLLBACK - xem dong 2026-09-19] Da tung doi ten model nay thanh
*									dtm_public_company_exchange_financial_yoy_rpt va tach rieng
*									dtm_public_company_industry_financial_yoy_rpt cho chieu nganh.
* 2026-09-19						Doi lai ten goc dtm_public_company_financial_yoy_rpt (rollback
*									2026-09-18) vi yeu cau thuc te tu dashboard la CROSS-TAB: khi
*									nguoi dung chon bo loc SAN thi phai xem duoc breakdown theo
*									NGANH trong san do - khong phai 2 view doc lap nhu danh gia ban
*									dau, nen gop chieu nganh (business_line_level_1_code/
*									business_line_level_1_name) vao lam dimension thu 2 cua CHINH
*									bang nay thay vi giu bang rieng
*									dtm_public_company_industry_financial_yoy_rpt (da xoa).
*									User xac nhan lai (2026-09-19, cung ngay, 2 lan): dashboard CHI co
*									filter tren cot SAN, gia tri filter la "tung san cu the" hoac
*									"toan san" (= tat ca 4 san gop lai). Cot NGANH khong phai filter -
*									luon la chieu breakdown cu the, KHONG co gia tri 'ALL' rieng cho
*									nganh o muc grand-total (san='ALL' + nganh='ALL' - da bo). Rieng
*									nhom (san cu the, nganh='ALL') van GIU LAI vi
*									dtm_public_company_exchange_financial_summary_rpt (bao cao co san
*									tu truoc, doc lap voi thay doi lan nay) dang JOIN dung 1 dong nay
*									de lay YoY theo san khong tach nganh - user xac nhan giu nguyen de
*									khong lam gay bao cao do.
*									Grain cuoi cung: (equity_listing_exchange_code,
*									business_line_level_1_code, rpt_year, rpt_quarter), gom 3 nhom:
*									  - (san cu the, nganh cu the): universe = cong ty co
*									    equity_listing_exchange_code IN ('HOSE','HNX','UPCOM','OTC'),
*									    GROUP BY ca 2 chieu (detail_summary) - breakdown dashboard can
*									    khi chon 1 san cu the.
*									  - (san cu the, nganh='ALL'): giu nguyen logic exchange_summary cu
*									    (chi GROUP BY san, cung universe 4 san) - phuc vu rieng
*									    dtm_public_company_exchange_financial_summary_rpt, dashboard
*									    khong dung toi dong nay.
*									  - (san='ALL', nganh cu the): "toan san" + breakdown theo nganh -
*									    GROUP BY nganh tren CUNG universe 4 san voi detail_summary/
*									    exchange_summary (KHONG dung universe khong-gioi-han-san nhu
*									    dtm_public_company_industry_financial_rpt) de dam bao "toan san"
*									    = tong cong cua "tung san" cho tung nganh, nhat quan so lieu.
*									KHONG con nhom (san='ALL', nganh='ALL') - market_summary da bo vi
*									khong co nhu cau xem grand-total khong tach nganh.
*									Ke thua nguyen driving-key pattern union N/N-1 cua
*									dtm_public_company_industry_financial_rpt (gioi han
*									rpt_year <= nam etl_date) nhung mo rong key thanh CAP
*									(equity_listing_exchange_code, business_line_level_1_code) vi nganh
*									van co the "xuat hien/mat" theo ky trong pham vi 1 san (vd 1 nganh
*									chi co cong ty niem yet tren san do o 1 trong 2 nam).
*									QUAN TRONG - anh huong downstream: da cap nhat JOIN trong
*									dtm_public_company_exchange_financial_summary_rpt them dieu kien
*									yoy.business_line_level_1_code = 'ALL' de tranh fan-out (nhan
*									dong) do bang nay tu 1-dimension (chi san) thanh 2-dimension (san
*									x nganh) - neu khong loc se ra N dong trung lap cho moi dong exchange
*									summary (N = so nganh xuat hien trong san do).
* 2026-09-19						[BUG FIX - phat hien khi user rao lai grain cua source]
*									financial_summary truoc day loc dung 1 partition
*									snpst_dt_dim_id = etl_date tren dtm_fct_public_company_financial_
*									smy_snpst. Nguon do la incremental append, PARTITION THEO NGAY
*									CHAY chu khong phai theo ky bao cao, va moi ngay chay CHI tinh dung
*									1 ky = rpt_year=YEAR(etl_date) (xem WHERE trong file nguon) - nghia
*									la partition dung ngay etl_date KHONG BAO GIO chua rpt_year=N-1.
*									Hau qua: combined_summary chi co 1 nam duy nhat, JOIN prev
*									(rpt_year = keys.rpt_year - 1) o SELECT cuoi LUON LUON khong khop =>
*									toan bo cot *_yoy LUON ra NULL cho MOI dong, MOI lan chay - loi
*									nghiem trong da ton tai tu truoc, khong lien quan gi den thay doi
*									cross-tab san/nganh o tren.
*									Fix: them CTE financial_summary_dedup, quet partition
*									snpst_dt_dim_id trong khoang [01/01 nam (N-1), etl_date] (thay vi
*									dung 1 ngay), ROW_NUMBER() OVER (PARTITION BY public_company_dim_id,
*									rpt_year, rpt_quarter ORDER BY snpst_dt_dim_id DESC) lay rn=1 = ban
*									ghi MOI NHAT tung biet cho moi (cong ty, ky). Ke thua dung pattern
*									financial_summary_dedup cua dtm_public_company_regulatory_
*									compliance_rpt.sql (cung xu ly nguon append/daily-partition nay),
*									chi mo rong pham vi quet ve them ca nam N-1 vi bao cao kia da bi
*									descope ve 1-nam-only (2026-09-17) nen khong can. Voi ky N (dang
*									chay dot) rn=1 = luy ke moi nhat tinh den etl_date (giu dung hanh vi
*									cu); voi ky N-1 (da dong so) rn=1 = ban ghi CUOI CUNG nguon tung ghi
*									cho ky do (vi sang nam N nguon ngung tinh lai N-1 hoan toan) - tuong
*									duong so lieu cuoi ky.
* 2026-09-19					[REVERT WORKAROUND - xem changelog cung ngay o tren] Fix BETWEEN +
*						ROW_NUMBER o tren la workaround cho _smy_ ban cu (incremental theo ngay,
*						moi ngay chi tinh dung 1 ky hien hanh). _smy_ vua duoc doi thanh
*						full-recompute moi ngay (xem changelog 2026-09-19 cua
*						dtm_fct_public_company_financial_smy_snpst.sql: bo filter ky hien hanh
*						o report_submission_raw/fr_value_raw) - moi partition
*						snpst_dt_dim_id=etl_date gio da tu than chua DU moi rpt_year (ke ca N-1),
*						moi (company,rpt_year,rpt_quarter) dung 1 dong voi gia tri moi nhat (dedup
*						resubmission xu ly san trong _smy_). Workaround BETWEEN [01/01 N-1,
*						etl_date] + ROW_NUMBER khong con can thiet va ton kem hon nhieu (_smy_ da
*						phinh to du full lich su, quet nhieu ngay se nhan chi phi len nhieu lan).
*						Fix: gop financial_summary_dedup vao thang financial_summary, doc
*						source loc dung snpst_dt_dim_id = etl_date, bo ROW_NUMBER.
* 2026-09-22					[RE-ADD grand-total] Them lai nhom (san='ALL', nganh='ALL') da bo
*						o changelog 2026-09-19 (thay ten model, muc "Grain cuoi cung") - yeu cau
*						moi tu dashboard can xem duoc tong toan thi truong (khong tach san, khong
*						tach nganh). Them CTE market_summary: cung universe 4 san hop le
*						(financial_summary_by_company) voi detail_summary/exchange_summary/
*						industry_summary, khong GROUP BY chieu nao, de dam bao grand-total = tong
*						cong cua cac dong khac. Union vao combined_summary; combined_year_keys va
*						SELECT cuoi khong can sua vi da generic theo cap key. Da kiem tra downstream
*						dtm_public_company_exchange_financial_summary_rpt: JOIN cua bao cao do dung
*						equity_listing_exchange_code cua exchange_summary (luon la 1 trong 4 san cu
*						the, khong bao gio la 'ALL') nen dong grand-total moi khong lam fan-out hay
*						anh huong bao cao nay.
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 19 cot *_yoy (% thay doi) decimal(9,4) -> decimal(30,6).
*								Nguon: atm_fr_value.data_val doi decimal(20,2) -> decimal(38,8). Quy uoc: cot
*								chi tieu co so = (38,8), cot tinh tu phep chia = (30,6). Bang Iceberg KHONG doi
*								scale tai cho + INSERT theo vi tri => PHAI chay DDL
*								lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql TRUOC dbt run. KHONG --full-refresh.
* 2026-10-02		duc.luxuan			Sua thu tu phep tinh %: X / NULLIF(Y,0) * 100 -> X * 100 / NULLIF(Y,0) (roa/roe_pct trung gian + 19 cot *_yoy).
*									  Spark ep scale ket qua phep chia decimal(38,x)/decimal(38,x) ve 6 => chia truoc
*									  roi *100 chi con 4 chu so thap phan dung (vd 3.215200 thay vi 3.215241).
* 2026-10-02		duc.luxuan			Mau so ROA/ROE theo logic BA: gia tri dau ky/cuoi ky NULL hoac = 0 coi la thieu,
*									  lay cot con lai: CASE WHEN COALESCE(x_beginning,0)=0 THEN x ELSE x_beginning END
*									  + CASE WHEN COALESCE(x,0)=0 THEN x_beginning ELSE x END (truoc chi xu ly NULL).
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

-- _smy_ full-recompute moi ngay (xem changelog 2026-09-19 o tren + cua chinh
-- dtm_fct_public_company_financial_smy_snpst.sql) => partition snpst_dt_dim_id=etl_date da
-- tu than chua du moi rpt_year (ke ca N-1), moi (company,rpt_year,rpt_quarter) dung 1 dong
-- voi gia tri moi nhat. Khong can quet BETWEEN nhieu ngay hay ROW_NUMBER dedup lai nua.
financial_summary AS (
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
          net_profit_ytd,
          pre_tax_profit,
          pre_tax_profit_ytd,
          inventory,
          net_revenue,
          net_revenue_ytd,
          undistributed_profit,
          receivable,
          cash_and_equivalent
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

-- Universe = 4 san hop le, mang ca 2 chieu san + nganh, dung chung cho detail_summary
-- va exchange_summary ben duoi (khong con nhom "toan nganh" nen khong can universe
-- khong-loc-san nua).
financial_summary_by_company AS (
    SELECT
          company.equity_listing_exchange_code,
          company.business_line_level_1_code,
          company.classification_business_line_nm,
          financial_summary.rpt_year,
          financial_summary.rpt_quarter,
          financial_summary.total_asset,
          financial_summary.total_asset_beginning,
          financial_summary.total_liability,
          financial_summary.equity,
          financial_summary.equity_beginning,
          financial_summary.contributed_capital,
          financial_summary.net_profit,
          financial_summary.net_profit_ytd,
          financial_summary.pre_tax_profit,
          financial_summary.pre_tax_profit_ytd,
          financial_summary.inventory,
          financial_summary.net_revenue,
          financial_summary.net_revenue_ytd,
          financial_summary.undistributed_profit,
          financial_summary.receivable,
          financial_summary.cash_and_equivalent
    FROM financial_summary
    INNER JOIN company
        ON company.public_company_dim_id = financial_summary.public_company_dim_id
),

-- Nhom (san cu the, nganh='ALL') = "toan san": giu nguyen universe + logic
-- exchange_summary cu (4 san hop le) - dtm_public_company_exchange_financial_summary_rpt
-- dang doc dung 1 dong nay (join them dieu kien business_line_level_1_code = 'ALL').
exchange_summary AS (
    SELECT
          equity_listing_exchange_code,
          CAST('ALL' AS string) AS business_line_level_1_code,
          CAST('ALL' AS string) AS classification_business_line_nm,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)          AS total_asset_amt,
          SUM(total_liability)      AS total_liability_amt,
          SUM(equity)               AS equity_amt,
          SUM(contributed_capital)  AS contributed_capital_amt,
          SUM(net_profit)           AS net_profit_amt,
          SUM(net_profit_ytd)       AS net_profit_ytd_amt,
          SUM(pre_tax_profit)       AS pre_tax_profit_amt,
          SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
          SUM(inventory)            AS inventory_amt,
          SUM(net_revenue)          AS net_revenue_amt,
          SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
          SUM(undistributed_profit) AS undistributed_profit_amt,
          SUM(receivable)           AS receivable_amt,
          SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_pct,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_pct,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                                                                                                AS debt_to_equity_ratio
    FROM financial_summary_by_company
    GROUP BY 
          equity_listing_exchange_code,
          rpt_year,
          rpt_quarter
),

-- Nhom detail (san cu the, nganh cu the): universe = 4 san hop le, GROUP BY ca 2
-- chieu - day la breakdown ma dashboard can khi nguoi dung chon bo loc san.
detail_summary AS (
    SELECT
          equity_listing_exchange_code,
          business_line_level_1_code,
          classification_business_line_nm,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)          AS total_asset_amt,
          SUM(total_liability)      AS total_liability_amt,
          SUM(equity)               AS equity_amt,
          SUM(contributed_capital)  AS contributed_capital_amt,
          SUM(net_profit)           AS net_profit_amt,
          SUM(net_profit_ytd)       AS net_profit_ytd_amt,
          SUM(pre_tax_profit)       AS pre_tax_profit_amt,
          SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
          SUM(inventory)            AS inventory_amt,
          SUM(net_revenue)          AS net_revenue_amt,
          SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
          SUM(undistributed_profit) AS undistributed_profit_amt,
          SUM(receivable)           AS receivable_amt,
          SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_pct,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_pct,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                                                                                                AS debt_to_equity_ratio
    FROM financial_summary_by_company
    GROUP BY 
          equity_listing_exchange_code,
          business_line_level_1_code,
          classification_business_line_nm,
          rpt_year,
          rpt_quarter
),

-- Nhom (san='ALL', nganh cu the) = "toan san" + breakdown theo nganh: cung universe 4
-- san hop le voi detail_summary/exchange_summary (KHONG dung universe khong-gioi-han-san
-- nhu dtm_public_company_industry_financial_rpt) de "toan san" = tong cong cua "tung san"
-- cho tung nganh, nhat quan so lieu giua cac dong.
industry_summary AS (
    SELECT
          CAST('ALL' AS string) AS equity_listing_exchange_code,
          business_line_level_1_code,
          classification_business_line_nm,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)          AS total_asset_amt,
          SUM(total_liability)      AS total_liability_amt,
          SUM(equity)               AS equity_amt,
          SUM(contributed_capital)  AS contributed_capital_amt,
          SUM(net_profit)           AS net_profit_amt,
          SUM(net_profit_ytd)       AS net_profit_ytd_amt,
          SUM(pre_tax_profit)       AS pre_tax_profit_amt,
          SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
          SUM(inventory)            AS inventory_amt,
          SUM(net_revenue)          AS net_revenue_amt,
          SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
          SUM(undistributed_profit) AS undistributed_profit_amt,
          SUM(receivable)           AS receivable_amt,
          SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_pct,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_pct,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                                                                                                AS debt_to_equity_ratio
    FROM financial_summary_by_company
    GROUP BY 
          business_line_level_1_code,
          classification_business_line_nm,
          rpt_year,
          rpt_quarter
),

-- Nhom (san='ALL', nganh='ALL') = grand-total toan thi truong: cung universe 4 san
-- hop le voi detail_summary/exchange_summary/industry_summary (khong GROUP BY chieu
-- nao) de dam bao nhat quan voi tong cac dong khac.
market_summary AS (
    SELECT
          CAST('ALL' AS string) AS equity_listing_exchange_code,
          CAST('ALL' AS string) AS business_line_level_1_code,
          CAST('ALL' AS string) AS classification_business_line_nm,
          rpt_year,
          rpt_quarter,
          SUM(total_asset)          AS total_asset_amt,
          SUM(total_liability)      AS total_liability_amt,
          SUM(equity)               AS equity_amt,
          SUM(contributed_capital)  AS contributed_capital_amt,
          SUM(net_profit)           AS net_profit_amt,
          SUM(net_profit_ytd)       AS net_profit_ytd_amt,
          SUM(pre_tax_profit)       AS pre_tax_profit_amt,
          SUM(pre_tax_profit_ytd)   AS pre_tax_profit_ytd_amt,
          SUM(inventory)            AS inventory_amt,
          SUM(net_revenue)          AS net_revenue_amt,
          SUM(net_revenue_ytd)      AS net_revenue_ytd_amt,
          SUM(undistributed_profit) AS undistributed_profit_amt,
          SUM(receivable)           AS receivable_amt,
          SUM(cash_and_equivalent)  AS cash_and_equivalent_amt,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)     AS roa_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0) AS roa_ytd_pct,
          SUM(net_profit) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                         AS roe_pct,
          SUM(net_profit_ytd) * 100 / NULLIF(SUM(CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)                     AS roe_ytd_pct,
          SUM(total_liability) / NULLIF(SUM(equity), 0)                                                                                                AS debt_to_equity_ratio
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
),

-- Union cap (san, nganh) co du lieu o N hoac N-1, gioi han <= nam etl_date - mo rong
-- pattern industry_year_keys cua dtm_public_company_industry_financial_rpt sang 2
-- chieu, vi ca san lan nganh trong combined_summary deu co the "xuat hien/mat" theo
-- ky (vd 1 nganh chi co du lieu 1 trong 2 nam, hoac 1 san chua co bao cao ky do).
combined_year_keys AS (
     SELECT DISTINCT 
          equity_listing_exchange_code, 
          business_line_level_1_code, 
          rpt_year, 
          rpt_quarter 
     FROM combined_summary
     UNION
     SELECT DISTINCT 
          equity_listing_exchange_code, 
          business_line_level_1_code, 
          rpt_year + 1, 
          rpt_quarter 
     FROM combined_summary
)

SELECT
     CAST(keys.equity_listing_exchange_code AS string)                     AS equity_listing_exchange_code,
     CAST(keys.business_line_level_1_code AS string)                       AS business_line_level_1_code,
     CAST(COALESCE(cur.classification_business_line_nm,
                   prev.classification_business_line_nm) AS string)        AS business_line_level_1_name,
     CAST(keys.rpt_year AS int)                                            AS rpt_year,
     CAST(keys.rpt_quarter AS int)                                         AS rpt_quarter,
     CASE WHEN prev.total_asset_amt IS NULL THEN NULL
          WHEN cur.total_asset_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.total_asset_amt - prev.total_asset_amt) * 100 / NULLIF(ABS(prev.total_asset_amt), 0) AS decimal(30,6)) END AS total_asset_yoy,
     CASE WHEN prev.total_liability_amt IS NULL THEN NULL
          WHEN cur.total_liability_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.total_liability_amt - prev.total_liability_amt) * 100 / NULLIF(ABS(prev.total_liability_amt), 0) AS decimal(30,6)) END AS total_liability_yoy,
     CASE WHEN prev.equity_amt IS NULL THEN NULL
          WHEN cur.equity_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.equity_amt - prev.equity_amt) * 100 / NULLIF(ABS(prev.equity_amt), 0) AS decimal(30,6)) END AS equity_yoy,
     CASE WHEN prev.contributed_capital_amt IS NULL THEN NULL
          WHEN cur.contributed_capital_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.contributed_capital_amt - prev.contributed_capital_amt) * 100 / NULLIF(ABS(prev.contributed_capital_amt), 0) AS decimal(30,6)) END AS contributed_capital_yoy,
     CASE WHEN prev.net_profit_amt IS NULL THEN NULL
          WHEN cur.net_profit_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.net_profit_amt - prev.net_profit_amt) * 100 / NULLIF(ABS(prev.net_profit_amt), 0) AS decimal(30,6)) END AS net_profit_yoy,
     CASE WHEN prev.net_profit_ytd_amt IS NULL THEN NULL
          WHEN cur.net_profit_ytd_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.net_profit_ytd_amt - prev.net_profit_ytd_amt) * 100 / NULLIF(ABS(prev.net_profit_ytd_amt), 0) AS decimal(30,6)) END AS net_profit_ytd_yoy,
     CASE WHEN prev.pre_tax_profit_amt IS NULL THEN NULL
          WHEN cur.pre_tax_profit_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.pre_tax_profit_amt - prev.pre_tax_profit_amt) * 100 / NULLIF(ABS(prev.pre_tax_profit_amt), 0) AS decimal(30,6)) END AS pre_tax_profit_yoy,
     CASE WHEN prev.pre_tax_profit_ytd_amt IS NULL THEN NULL
          WHEN cur.pre_tax_profit_ytd_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.pre_tax_profit_ytd_amt - prev.pre_tax_profit_ytd_amt) * 100 / NULLIF(ABS(prev.pre_tax_profit_ytd_amt), 0) AS decimal(30,6)) END AS pre_tax_profit_ytd_yoy,
     CASE WHEN prev.inventory_amt IS NULL THEN NULL
          WHEN cur.inventory_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.inventory_amt - prev.inventory_amt) * 100 / NULLIF(ABS(prev.inventory_amt), 0) AS decimal(30,6)) END AS inventory_yoy,
     CASE WHEN prev.net_revenue_amt IS NULL THEN NULL
          WHEN cur.net_revenue_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.net_revenue_amt - prev.net_revenue_amt) * 100 / NULLIF(ABS(prev.net_revenue_amt), 0) AS decimal(30,6)) END AS net_revenue_yoy,
     CASE WHEN prev.net_revenue_ytd_amt IS NULL THEN NULL
          WHEN cur.net_revenue_ytd_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.net_revenue_ytd_amt - prev.net_revenue_ytd_amt) * 100 / NULLIF(ABS(prev.net_revenue_ytd_amt), 0) AS decimal(30,6)) END AS net_revenue_ytd_yoy,
     CASE WHEN prev.undistributed_profit_amt IS NULL THEN NULL
          WHEN cur.undistributed_profit_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.undistributed_profit_amt - prev.undistributed_profit_amt) * 100 / NULLIF(ABS(prev.undistributed_profit_amt), 0) AS decimal(30,6)) END AS undistributed_profit_yoy,
     CASE WHEN prev.receivable_amt IS NULL THEN NULL
          WHEN cur.receivable_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.receivable_amt - prev.receivable_amt) * 100 / NULLIF(ABS(prev.receivable_amt), 0) AS decimal(30,6)) END AS receivable_yoy,
     CASE WHEN prev.cash_and_equivalent_amt IS NULL THEN NULL
          WHEN cur.cash_and_equivalent_amt IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.cash_and_equivalent_amt - prev.cash_and_equivalent_amt) * 100 / NULLIF(ABS(prev.cash_and_equivalent_amt), 0) AS decimal(30,6)) END AS cash_and_equivalent_yoy,
     CASE WHEN prev.roa_pct IS NULL THEN NULL
          WHEN cur.roa_pct IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.roa_pct - prev.roa_pct) * 100 / NULLIF(ABS(prev.roa_pct), 0) AS decimal(30,6)) END AS roa_yoy,
     CASE WHEN prev.roa_ytd_pct IS NULL THEN NULL
          WHEN cur.roa_ytd_pct IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.roa_ytd_pct - prev.roa_ytd_pct) * 100 / NULLIF(ABS(prev.roa_ytd_pct), 0) AS decimal(30,6)) END AS roa_ytd_yoy,
     CASE WHEN prev.roe_pct IS NULL THEN NULL
          WHEN cur.roe_pct IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.roe_pct - prev.roe_pct) * 100 / NULLIF(ABS(prev.roe_pct), 0) AS decimal(30,6)) END AS roe_yoy,
     CASE WHEN prev.roe_ytd_pct IS NULL THEN NULL
          WHEN cur.roe_ytd_pct IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.roe_ytd_pct - prev.roe_ytd_pct) * 100 / NULLIF(ABS(prev.roe_ytd_pct), 0) AS decimal(30,6)) END AS roe_ytd_yoy,
     CASE WHEN prev.debt_to_equity_ratio IS NULL THEN NULL
          WHEN cur.debt_to_equity_ratio IS NULL THEN CAST(-100 AS decimal(30,6))
          ELSE CAST((cur.debt_to_equity_ratio - prev.debt_to_equity_ratio) * 100 / NULLIF(ABS(prev.debt_to_equity_ratio), 0) AS decimal(30,6)) END AS debt_to_equity_yoy,
    CAST('IDS' AS string) AS src_stm_code,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd') AS rpt_dt
FROM combined_year_keys keys
LEFT JOIN combined_summary cur
    ON  cur.equity_listing_exchange_code <=> keys.equity_listing_exchange_code
    AND cur.business_line_level_1_code <=> keys.business_line_level_1_code
    AND cur.rpt_year = keys.rpt_year
    AND cur.rpt_quarter <=> keys.rpt_quarter
LEFT JOIN combined_summary prev
    ON  prev.equity_listing_exchange_code <=> keys.equity_listing_exchange_code
    AND prev.business_line_level_1_code <=> keys.business_line_level_1_code
    AND prev.rpt_year = keys.rpt_year - 1
    AND prev.rpt_quarter <=> keys.rpt_quarter
-- WHERE keys.rpt_year <= YEAR(TO_DATE('{{ var("etl_date") }}', 'yyyy-MM-dd'))
