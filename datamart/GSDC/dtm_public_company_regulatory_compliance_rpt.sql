/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_regulatory_compliance_rpt
* Program name: Dtm Public Company Regulatory Compliance Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* MUC DICH / GRAIN
*   Bao cao tuan thu nghia vu bao cao cua CTDC theo san x nam x ky.
*   Grain: equity_listing_exchange_code (HOSE/HNX/UPCOM/OTC) x rpt_year x rpt_quarter
*   (1-4 = quy, 5 = ca nam, 6 = ban nien). Nam chay tu min_rpt_year (nam dang ky som nhat
*   cua cong ty, san 2000) den YEAR(etl_date). Append theo partition rpt_dt = etl_date.
*
* NGUON
*   - dtm_public_company_dim_hstr  : trang thai/san/ngay dang ky cong ty (daily full snapshot).
*   - dtm_fct_violation_rpt_snpst  : nghia vu phai nop/da nop (partition etl_date = full lich su).
*   - dtm_fct_public_company_financial_smy_snpst : loi nhuan, von gop (partition etl_date = full lich su).
*
* QUY UOC CHUNG
*   - Ngay chot ky (period_status_asof_dt) = LEAST(ngay cuoi ky, etl_date). Trang thai cong ty
*     lay AS-OF ngay chot (partition _hstr dung ngay do) => revoke sau nay KHONG hoi to ky cu.
*   - Dieu kien "duoc tinh vao ky": public_company_status_code = 'APPROVED_PUBLIC' va san thuoc
*     4 san tren, tai ngay chot.
*
* CHI SO
*   - company_count: so CTDC cua san trong ky = company_count_population, gom 2 tap khong giao nhau:
*       (A) ky CO snapshot cong ty tai ngay chot: trang thai as-of + (ids_registration_dt IS NULL
*           OR ids_registration_dt <= ngay chot).
*       (B) ky TRUOC ngay cong ty xuat hien lan dau trong _hstr (cong ty nap muon vao nguon): suy
*           nguoc tu snapshot dau tien (ds_rcrd_isrt_dt cua scd4a) - chi khi snapshot do la
*           APPROVED_PUBLIC; dem tu ky chua ids_registration_dt MOI NHAT tai etl_date (NULL => moi
*           ky trong universe). Snapshot dau tien khong APPROVED_PUBLIC => khong dem nguoc, chi dem
*           cac ky (A) co trang thai APPROVED_PUBLIC. San dung san cua snapshot dau tien. Cong ty
*           dang xoa mem tai etl_date van giu tap (B).
*   - large_scale_company_count: (chi UPCOM/OTC, HOSE/HNX = NULL) cong ty trong company_count_population
*     co contributed_capital (row 411 BCDKT) cua lan nop gan nhat <= ky dang xet >= 120 ty dong.
*   - company_due_count / company_submitted_count: COUNT DISTINCT cong ty co nghia vu den han / da
*     nop it nhat 1 BCTC trong ky (fct_violation), loc theo trang thai as-of (company_status_asof).
*   - profitable_company_count_year / _ytd: so cong ty co net_profit / net_profit_ytd > 0, chi
*     trong tap da nop cua cung ky => company_count >= due >= submitted >= profitable.
*   - Ky khong co du lieu tra NULL (khong ep 0), ky van luon co dong nho period_exchange_universe.
*
* DANH DOI DA CHAP NHAN
*   - Thieu partition _hstr dung ngay chot (job dim fail khong backfill) => ky do mat du lieu tap (A).
*   - violation/smy loc dung partition etl_date, khong fallback ngay truoc.
*   - Tap (B) phu thuoc ds_rcrd_isrt_dt cua scd4a = ngay xuat hien dau tien - can verify tren UAT.
*   - Tap (B) dung san cua snapshot dau tien - nguon Oracle chi luu san moi nhat, khong co lich su
*     chuyen san, nen cong ty chuyen san truoc ngay nap se bi tinh vao san luc nap (da chot).
*   - Du lieu rac vao he thong APPROVED_PUBLIC roi bi xoa mem van duoc dem o tap (B) - can don o nguon.
*   - Nguon xoa/tao lai cong ty voi pc_id moi => co the dem 2 lan o ky cu (loi du lieu nguon).
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-22						Driving table = period_exchange_universe (CROSS JOIN san x ky), khong
*									phu thuoc fact; company_count dung ids_registration_dt thuan.
* 2026-08-26						Trang thai cong ty AS-OF ngay chot ky (fix revoke hoi to).
* 2026-08-27						Them ky 5 (ca nam) / 6 (ban nien); cho phep ids_registration_dt NULL.
* 2026-09-15						due/submitted doi sang COUNT DISTINCT cong ty, doi ten cot
*									company_due_count/company_submitted_count; bo cac cot nam N-1.
* 2026-09-17						Chuan hoa chay daily: violation/smy loc partition etl_date, doc thang
*									_hstr theo ngay chot.
* 2026-09-19						Universe nam dong tu min_rpt_year (nam dang ky som nhat, san 2000).
* 2026-09-29						Them large_scale_company_count (UPCOM/OTC, von gop >= 120 ty).
* 2026-09-30						profitable_* la tap con cua company_submitted_count.
* 2026-10-08						contributed_capital = 0 coi nhu chua co so lieu.
* 2026-10-19						company_count/large_scale_company_count dem them cac ky truoc khi cong
*									ty xuat hien trong _hstr theo ids_registration_dt (tap B, lay gia tri
*									moi nhat; giu ca khi cong ty dang xoa mem). Cac chi so
*									due/submitted/profitable khong doi.
*--------------------------------------------------------------------*
*/

WITH reporting_universe_year_bounds AS (
    -- Nam nho nhat cua universe = nam dang ky som nhat tren TOAN BO cong ty (khong loc trang thai/san
    -- de khong thu hep sai moc), san 2000 chan du lieu rac.
    SELECT
        GREATEST(MIN(YEAR(ids_registration_dt)), 2000) AS min_rpt_year
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

period_exchange_universe AS (
    -- Driving table: 4 san x nam [min_rpt_year, N] x ky 1-6, doc lap voi moi fact.
    SELECT
        exchange.equity_listing_exchange_code,
        yr_tbl.rpt_year,
        qtr.rpt_quarter
    FROM (SELECT explode(array('HOSE','HNX','UPCOM','OTC')) AS equity_listing_exchange_code) exchange
	CROSS JOIN (
	    SELECT explode(sequence(
	        bounds.min_rpt_year,
	        YEAR(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'))
	    )) AS rpt_year
	    FROM reporting_universe_year_bounds bounds
	) yr_tbl
    CROSS JOIN (SELECT explode(array(1,2,3,4,5,6)) AS rpt_quarter) qtr
),

financial_summary AS (
    -- Partition etl_date cua _smy_ la full lich su, moi (cong ty, ky) 1 dong moi nhat.
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        net_profit,
        net_profit_ytd,
        contributed_capital
    FROM {{ ref('dtm_fct_public_company_financial_smy_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

contributed_capital_by_period AS (
    -- Ung vien von gop cho large_scale_company: moi lan nop co contributed_capital > 0 (0/NULL = chua
    -- co so lieu). period_sort_key = rpt_year*100 + thang cuoi ky de so sanh thu tu giua cac loai ky.
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        rpt_year * 100 + CASE
            WHEN rpt_quarter IN (1,2,3,4) THEN rpt_quarter * 3
            WHEN rpt_quarter = 5 THEN 12
            WHEN rpt_quarter = 6 THEN 6
        END AS period_sort_key,
        contributed_capital
    FROM financial_summary
    WHERE contributed_capital > 0
        AND rpt_quarter IN (1,2,3,4,5,6)
),

violation_dedup AS (
    -- Partition etl_date cua fct_violation la full lich su nghia vu.
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter,
        rpt_due_count,
        rpt_submitted_count
    FROM {{ ref('dtm_fct_violation_rpt_snpst') }}
    WHERE snpst_dt_dim_id = Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')
),

period_status_cutoff AS (
    -- Ngay chot moi ky = LEAST(ngay cuoi ky, etl_date): ky da qua dong bang theo cuoi ky, ky dang chay
    -- dung trang thai moi nhat. Thang cuoi ky: quy 1-4 -> q*3, ky 5 -> 12, ky 6 -> 6.
    SELECT DISTINCT
        rpt_year,
        rpt_quarter,
        LEAST(
            LAST_DAY(make_date(
                rpt_year,
                CASE
                    WHEN rpt_quarter IN (1,2,3,4) THEN rpt_quarter * 3
                    WHEN rpt_quarter = 5 THEN 12
                    WHEN rpt_quarter = 6 THEN 6
                END,
                1
            )),
            TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd')
        ) AS period_status_asof_dt
    FROM period_exchange_universe
),

company_dim_hstr_asof AS (
    -- Doc thang cac partition _hstr = ngay chot (khong fallback ngay gan nhat).
    SELECT
        public_company_dim_id,
        ds_snpst_dt,
        equity_listing_exchange_code,
        public_company_status_code,
        ids_registration_dt
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt IN (SELECT DISTINCT period_status_asof_dt FROM period_status_cutoff)
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

company_status_asof AS (
    -- Cong ty APPROVED_PUBLIC thuoc 4 san tai ngay chot moi ky - dinh nghia chung cho
    -- violation_agg va financial_summary_asof.
    SELECT
        d.public_company_dim_id,
        pc.rpt_year,
        pc.rpt_quarter,
        d.equity_listing_exchange_code,
        d.ids_registration_dt
    FROM period_status_cutoff pc
    INNER JOIN company_dim_hstr_asof d
        ON d.ds_snpst_dt = pc.period_status_asof_dt
    WHERE d.public_company_status_code = 'APPROVED_PUBLIC'
        AND d.equity_listing_exchange_code IN ('HNX','HOSE','UPCOM','OTC')
),

company_first_seen_dt AS (
    -- Ngay cong ty xuat hien lan dau trong _hstr: ds_rcrd_isrt_dt (scd4a gan = etl_date luc insert,
    -- giu nguyen qua update/xoa mem/khoi phuc) doc tu partition etl_date - khong quet toan bo _hstr.
    -- KHONG loc ds_rcrd_st: cong ty dang xoa mem tai etl_date van giu tap (B) (xoa sau nay khong
    -- hoi to ky cu). ids_registration_dt lay gia tri MOI NHAT (nguon sua ngay dang ky van co hieu luc).
    SELECT
        public_company_dim_id,
        ds_rcrd_isrt_dt AS first_seen_dt,
        ids_registration_dt
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

company_first_seen AS (
    -- Trang thai/san TAI snapshot dau tien - chi doc cac partition = first_seen_dt (so ngay phan biet
    -- co cong ty moi), dung lam can cu dem nguoc cho tap (B).
    SELECT
        h.public_company_dim_id,
        h.ds_snpst_dt AS first_seen_dt,
        h.equity_listing_exchange_code,
        h.public_company_status_code,
        f.ids_registration_dt
    FROM {{ ref('dtm_public_company_dim') }}_hstr h
    INNER JOIN company_first_seen_dt f
        ON  f.public_company_dim_id = h.public_company_dim_id
        AND f.first_seen_dt = h.ds_snpst_dt
    WHERE h.ds_snpst_dt IN (SELECT DISTINCT first_seen_dt FROM company_first_seen_dt)
        AND h.ds_rcrd_st = 'ACTIVE'
        AND h.src_stm_code = 'IDS_COMPANY_PROFILES'
),

company_count_population AS (
    -- Tap cong ty dem company_count/large_scale_company_count. (A) va (B) khong giao nhau: (A) can
    -- snapshot tai ngay chot (>= first_seen_dt), (B) chi lay ngay chot < first_seen_dt.
    -- (A) Ky co snapshot: trang thai as-of + cutoff ids_registration_dt (NULL = khong chan).
    SELECT
        company_status_asof.public_company_dim_id,
        company_status_asof.rpt_year,
        company_status_asof.rpt_quarter,
        company_status_asof.equity_listing_exchange_code
    FROM company_status_asof
    INNER JOIN period_status_cutoff
        ON  period_status_cutoff.rpt_year = company_status_asof.rpt_year
        AND period_status_cutoff.rpt_quarter = company_status_asof.rpt_quarter
    WHERE company_status_asof.ids_registration_dt IS NULL
        OR company_status_asof.ids_registration_dt <= period_status_cutoff.period_status_asof_dt

    UNION ALL

    -- (B) Ky truoc khi cong ty xuat hien: dem nguoc theo ids_registration_dt neu snapshot dau tien
    -- la APPROVED_PUBLIC (khong APPROVED => chi dem tu ky (A) co trang thai APPROVED_PUBLIC).
    SELECT
        company_first_seen.public_company_dim_id,
        period_status_cutoff.rpt_year,
        period_status_cutoff.rpt_quarter,
        company_first_seen.equity_listing_exchange_code
    FROM period_status_cutoff
    INNER JOIN company_first_seen
        ON period_status_cutoff.period_status_asof_dt < company_first_seen.first_seen_dt
    WHERE company_first_seen.public_company_status_code = 'APPROVED_PUBLIC'
        AND company_first_seen.equity_listing_exchange_code IN ('HNX','HOSE','UPCOM','OTC')
        AND (company_first_seen.ids_registration_dt IS NULL
            OR company_first_seen.ids_registration_dt <= period_status_cutoff.period_status_asof_dt)
),

large_scale_company AS (
    -- Cong ty UPCOM/OTC trong company_count_population co von gop cua lan nop gan nhat <= ky dang xet
    -- >= 120 ty dong. Cung thang cuoi ky (Q2 vs ky 6, Q4 vs ky 5) uu tien ky 5/6 cho ket qua xac dinh.
    SELECT
        public_company_dim_id,
        rpt_year,
        rpt_quarter
    FROM (
        SELECT
            company_count_population.public_company_dim_id,
            company_count_population.rpt_year,
            company_count_population.rpt_quarter,
            contributed_capital_by_period.contributed_capital,
            ROW_NUMBER() OVER (
                PARTITION BY company_count_population.public_company_dim_id,
                             company_count_population.rpt_year,
                             company_count_population.rpt_quarter
                ORDER BY contributed_capital_by_period.period_sort_key DESC,
                         CASE WHEN contributed_capital_by_period.rpt_quarter IN (5,6) THEN 0 ELSE 1 END
            ) AS rn
        FROM company_count_population
        INNER JOIN contributed_capital_by_period
            ON  contributed_capital_by_period.public_company_dim_id = company_count_population.public_company_dim_id
            AND contributed_capital_by_period.period_sort_key <= company_count_population.rpt_year * 100 + CASE
                    WHEN company_count_population.rpt_quarter IN (1,2,3,4) THEN company_count_population.rpt_quarter * 3
                    WHEN company_count_population.rpt_quarter = 5 THEN 12
                    WHEN company_count_population.rpt_quarter = 6 THEN 6
                END
        WHERE company_count_population.equity_listing_exchange_code IN ('UPCOM','OTC')
    ) latest_capital
    WHERE rn = 1
        AND contributed_capital >= 120000000000
),

financial_summary_asof AS (
    -- Loi nhuan gan san theo trang thai as-of cua chinh ky BCTC, chi giu cong ty "da nop" cung ky
    -- (rpt_submitted_count > 0) => profitable_* la tap con cua company_submitted_count.
    SELECT
        fct.public_company_dim_id,
        company_status_asof.equity_listing_exchange_code,
        fct.rpt_year,
        fct.rpt_quarter,
        fct.net_profit,
        fct.net_profit_ytd
    FROM financial_summary fct
    INNER JOIN company_status_asof
        ON  company_status_asof.public_company_dim_id = fct.public_company_dim_id
        AND company_status_asof.rpt_year = fct.rpt_year
        AND company_status_asof.rpt_quarter = fct.rpt_quarter
    INNER JOIN (
        SELECT DISTINCT
            public_company_dim_id,
            CAST(rpt_year AS int)    AS rpt_year,
            CAST(rpt_quarter AS int) AS rpt_quarter
        FROM violation_dedup
        WHERE rpt_submitted_count > 0
    ) submitted_company
        ON  submitted_company.public_company_dim_id = fct.public_company_dim_id
        AND submitted_company.rpt_year = fct.rpt_year
        AND submitted_company.rpt_quarter = fct.rpt_quarter
),

profitable_company_year_n AS (
    -- So cong ty co lai theo ky (net_profit) va luy ke (net_profit_ytd), tinh cho moi nam trong universe.
    SELECT
        equity_listing_exchange_code,
        rpt_year,
        rpt_quarter,
        COUNT(DISTINCT CASE WHEN net_profit > 0 THEN public_company_dim_id END)     AS profitable_company_count_year_n,
        COUNT(DISTINCT CASE WHEN net_profit_ytd > 0 THEN public_company_dim_id END) AS profitable_company_count_year_n_ytd
    FROM financial_summary_asof
    GROUP BY
        equity_listing_exchange_code,
        rpt_year,
        rpt_quarter
),

company_count_agg AS (
    -- company_count va large_scale_company_count dem tren cung company_count_population => large_scale
    -- luon <= company_count. HOSE/HNX large_scale = NULL (khong ap dung), phan biet voi 0.
    SELECT
        period_exchange_universe.equity_listing_exchange_code,
        period_exchange_universe.rpt_year,
        period_exchange_universe.rpt_quarter,
        COUNT(DISTINCT company_count_population.public_company_dim_id) AS company_count,
        CASE WHEN period_exchange_universe.equity_listing_exchange_code IN ('UPCOM','OTC')
             THEN COUNT(DISTINCT large_scale_company.public_company_dim_id)
        END                                                            AS large_scale_company_count
    FROM period_exchange_universe
    INNER JOIN company_count_population
        ON  company_count_population.equity_listing_exchange_code = period_exchange_universe.equity_listing_exchange_code
        AND company_count_population.rpt_year = period_exchange_universe.rpt_year
        AND company_count_population.rpt_quarter = period_exchange_universe.rpt_quarter
    LEFT JOIN large_scale_company
        ON  large_scale_company.public_company_dim_id = company_count_population.public_company_dim_id
        AND large_scale_company.rpt_year = company_count_population.rpt_year
        AND large_scale_company.rpt_quarter = company_count_population.rpt_quarter
    GROUP BY
        period_exchange_universe.equity_listing_exchange_code,
        period_exchange_universe.rpt_year,
        period_exchange_universe.rpt_quarter
),

violation_agg AS (
    -- So CTDC phai nop (moi dong violation_dedup da co nghia vu den han) / da nop (rpt_submitted_count
    -- > 0), gan san theo trang thai as-of ky bao cao.
    SELECT
        company_status_asof.equity_listing_exchange_code,
        company_status_asof.rpt_year                                        AS rpt_year,
        company_status_asof.rpt_quarter                                     AS rpt_quarter,
        COUNT(DISTINCT violation_dedup.public_company_dim_id)               AS company_due_count,
        COUNT(DISTINCT CASE WHEN violation_dedup.rpt_submitted_count > 0
                            THEN violation_dedup.public_company_dim_id END) AS company_submitted_count
    FROM violation_dedup
    INNER JOIN company_status_asof
        ON  company_status_asof.public_company_dim_id = violation_dedup.public_company_dim_id
        AND company_status_asof.rpt_year = CAST(violation_dedup.rpt_year AS int)
        AND company_status_asof.rpt_quarter = CAST(violation_dedup.rpt_quarter AS int)
    GROUP BY
        company_status_asof.equity_listing_exchange_code,
        company_status_asof.rpt_year,
        company_status_asof.rpt_quarter
)

SELECT
    CAST(period_exchange_universe.equity_listing_exchange_code AS string)      AS equity_listing_exchange_code,
    CAST(period_exchange_universe.rpt_year AS int)                             AS rpt_year,
    CAST(period_exchange_universe.rpt_quarter AS int)                          AS rpt_quarter,
    CAST(company_count_agg.company_count AS int)                               AS company_count,
    CAST(violation_agg.company_due_count AS int)                               AS company_due_count,
    CAST(violation_agg.company_submitted_count AS int)                         AS company_submitted_count,
    CAST(company_count_agg.large_scale_company_count AS int)                   AS large_scale_company_count,
    CAST(profitable_company_year_n.profitable_company_count_year_n AS int)     AS profitable_company_count_year,
    CAST(profitable_company_year_n.profitable_company_count_year_n_ytd AS int) AS profitable_company_count_ytd,
    -- Cot ty le dang tat (chua co trong schema output); mau so = company_submitted_count theo BA.
    -- CASE
    --     WHEN violation_agg.company_submitted_count IS NULL OR violation_agg.company_submitted_count = 0 THEN NULL
    --     ELSE ROUND(profitable_company_year_n.profitable_company_count_year_n / violation_agg.company_submitted_count * 100, 2)
    -- END                                                                      AS profitable_company_rate_year_n,
    CAST('IDS' AS string)                                                      AS src_stm_code,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')      AS rpt_dt
FROM period_exchange_universe
LEFT JOIN profitable_company_year_n
    ON  profitable_company_year_n.equity_listing_exchange_code = period_exchange_universe.equity_listing_exchange_code
    AND profitable_company_year_n.rpt_year = period_exchange_universe.rpt_year
    AND profitable_company_year_n.rpt_quarter = period_exchange_universe.rpt_quarter
LEFT JOIN company_count_agg
    ON  company_count_agg.equity_listing_exchange_code = period_exchange_universe.equity_listing_exchange_code
    AND company_count_agg.rpt_year = period_exchange_universe.rpt_year
    AND company_count_agg.rpt_quarter = period_exchange_universe.rpt_quarter
LEFT JOIN violation_agg
    ON  violation_agg.equity_listing_exchange_code = period_exchange_universe.equity_listing_exchange_code
    AND violation_agg.rpt_year = period_exchange_universe.rpt_year
    AND violation_agg.rpt_quarter = period_exchange_universe.rpt_quarter
