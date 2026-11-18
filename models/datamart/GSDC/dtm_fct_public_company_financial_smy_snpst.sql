/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_financial_smy_snpst
* Program name: Dtm Fct Public Company Financial Summary Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		duc.luxuan			Sua thu tu phep tinh %: X / NULLIF(Y,0) * 100 -> X * 100 / NULLIF(Y,0) (4 cot roa/roe/roa_ytd/roe_ytd).
*									  Spark ep scale ket qua phep chia decimal(38,x)/decimal(38,x) ve 6 => chia truoc
*									  roi *100 chi con 4 chu so thap phan dung (vd 3.215200 thay vi 3.215241).
* 2026-10-02		duc.luxuan			ROA/ROE (roa, roe, roa_ytd, roe_ytd) theo logic BA: tach SELECT tong hop thanh CTE smy_base,
*									  tinh ROA/ROE o SELECT ngoai; mau so = trung binh dau ky/cuoi ky, ben nao NULL hoac = 0 thi
*									  lay cot con lai (truoc la SUM(dau ky) + SUM(cuoi ky) => thieu 1 ben ra NULL). Thu tu cot giu nguyen.
* 2026-11-06		duc.luxuan			Dong bo LLD 2026-11-03 (y/c dev) + 2026-11-04 (BA Nhom 7/18.1):
*								(a) Them 16 cot cuoi bang (giu nguyen thu tu vat ly cu, cot moi APPEND sau
*								debt_to_equity_beginning): 10 cot ky nay operating_cash_flow (BCLCTT chi tieu 20,
*								DN/BH, uu tien BCLCTT_GT hon BCLCTT_TT), short_term_asset (BCDKT 100),
*								short_term_liability (BCDKT 310), interest_expense (BCKQKD 23, chi DN),
*								financial_revenue (DN 21/BH 12), other_revenue (DN 31/BH 13), current_ratio,
*								interest_coverage, financial_revenue_to_net_profit, other_revenue_to_net_profit;
*								6 cot luy ke interest_expense_ytd, financial_revenue_ytd, other_revenue_ytd,
*								interest_coverage_ytd, financial_revenue_to_net_profit_ytd,
*								other_revenue_to_net_profit_ytd (column_description_reference='3').
*								operating_cash_flow: chon catalog GT truoc, khong co thi TT - cai dat bang cot
*								cf_pref_rank (DENSE_RANK theo pc/ky/chi tieu/cot) o chi_tieu de SUM khong bi cong
*								doi 2 catalog; LLD ghi PARTITION theo row_code/column_code nhung cung muc dich.
*								(b) TD: net_revenue/net_revenue_ytd row IN ('1','4','7','8','9') (truoc '03');
*								receivable/receivable_beginning TD row IN ('251','252') (truoc '251').
*								ROA/ROE: da khop LLD (CASE trung binh dau/cuoi ky), khong doi.
*								LUU Y TRIEN KHAI: PHAI ALTER TABLE ADD COLUMN ... AFTER thu cong tren Iceberg
*								va ClickHouse flat TRUOC dbt run. KHONG --full-refresh.
*--------------------------------------------------------------------*
*/

WITH report_submission_raw AS (
    SELECT
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_id,
        submission_dt
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_DATA'
        AND approval_status_code = 'APPROVED'
),

fr_template_periodic AS (
    SELECT
        fr_id,
        fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

fr_value_raw AS (
    -- Dedup fr_value: bản ghi mới nhất mỗi (company, kỳ, catalog, row_code, column_code)
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pc_id, rpt_year, rpt_quarter, fr_catalog_id, row_code, column_code
            ORDER BY ds_rcrd_udt_dt DESC, ds_rcrd_isrt_dt DESC, fr_val_code desc
        ) AS rn
    FROM {{ ref('atm_fr_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_DATA'
),

fr_catalog_atomic AS (
    SELECT
        fr_catalog_id,
        fr_year,
        financial_statement_tp_code,
        enterprise_tp_code,
        rpt_code
    FROM {{ ref('atm_fr_catalog') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
),

fr_row_template AS (
    SELECT
        row_code,
        fr_catalog_id,
        rpt_year,
        row_description_reference
    FROM {{ ref('atm_fr_row') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RROW'
),

fr_column_template AS (
    SELECT
        column_code,
        fr_catalog_id,
        rpt_year,
        column_description_reference
    FROM {{ ref('atm_fr_column') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RCOL'
),

company AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        business_line_level_1_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES' 
),

industry AS (
    SELECT
        industry_dim_id,
        industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_BUSINESS_LINE_LEVEL_1'
),

report_submission_ranked AS (
    SELECT
        report_submission_raw.pc_code,
        report_submission_raw.rpt_year,
        report_submission_raw.rpt_quarter,
        report_submission_raw.fr_id,
        ROW_NUMBER() OVER (
            PARTITION BY report_submission_raw.pc_code, report_submission_raw.rpt_year, report_submission_raw.rpt_quarter
            ORDER BY CASE
                WHEN fr_template_periodic.fr_code LIKE 'HN%' THEN 1
                WHEN fr_template_periodic.fr_code LIKE 'TH%' THEN 2
                WHEN fr_template_periodic.fr_code LIKE 'ME%' THEN 3
                WHEN fr_template_periodic.fr_code LIKE 'RI%' THEN 4
            END, report_submission_raw.submission_dt DESC
        ) AS rn
    FROM report_submission_raw
    INNER JOIN fr_template_periodic
        ON fr_template_periodic.fr_id = report_submission_raw.fr_id
),

-- Chọn 1 form ưu tiên (HN>TH>ME>RI) mỗi (company, kỳ) đã APPROVED, loại tin định kỳ
form_uu_tien AS (
    SELECT
        report_submission_ranked.pc_code,
        report_submission_ranked.rpt_year,
        report_submission_ranked.rpt_quarter,
        fr_template_periodic.fr_code,
        SUBSTR(fr_template_periodic.fr_code, 1, 2) AS financial_statement_tp_code
    FROM report_submission_ranked
    INNER JOIN fr_template_periodic
        ON fr_template_periodic.fr_id = report_submission_ranked.fr_id
    WHERE report_submission_ranked.rn = 1
),

fr_value AS (
    SELECT
        pc_id,
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_catalog_id,
        row_code,
        column_code,
        cell_val
    FROM fr_value_raw
    WHERE rn = 1
),

chi_tieu AS (
    SELECT
        fr_value.pc_id,
        fr_value.pc_code,
        fr_value.rpt_year,
        fr_value.rpt_quarter,
        fr_value.cell_val,
        fr_catalog_atomic.enterprise_tp_code,
        fr_row_template.row_description_reference,
        fr_column_template.column_description_reference,
        fr_catalog_atomic.rpt_code,
        -- Uu tien bao cao luu chuyen tien te gian tiep (BCLCTT_GT) hon truc tiep (BCLCTT_TT) cho cung chi tieu/cot
        DENSE_RANK() OVER (
            PARTITION BY fr_value.pc_id, fr_value.rpt_year, fr_value.rpt_quarter,
                         fr_row_template.row_description_reference, fr_column_template.column_description_reference
            ORDER BY CASE WHEN fr_catalog_atomic.rpt_code LIKE 'BCLCTT_GT%' THEN 1 ELSE 2 END
        ) AS cf_pref_rank
    FROM fr_value
    INNER JOIN form_uu_tien
        ON form_uu_tien.pc_code = fr_value.pc_code 
        AND form_uu_tien.rpt_year = fr_value.rpt_year 
        AND form_uu_tien.rpt_quarter = fr_value.rpt_quarter
    INNER JOIN fr_catalog_atomic
        ON fr_catalog_atomic.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_catalog_atomic.fr_year = CAST(fr_value.rpt_year AS STRING)
        AND fr_catalog_atomic.financial_statement_tp_code = form_uu_tien.financial_statement_tp_code
    INNER JOIN fr_row_template
        ON fr_row_template.row_code = fr_value.row_code
        AND fr_row_template.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_row_template.rpt_year = CAST(fr_value.rpt_year AS STRING)
    INNER JOIN fr_column_template
        ON fr_column_template.column_code = fr_value.column_code
        AND fr_column_template.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_column_template.rpt_year = CAST(fr_value.rpt_year AS STRING)
),

smy_base AS (
SELECT
    company.public_company_dim_id                                                  AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')          AS snpst_dt_dim_id,
    industry.industry_dim_id                                                       AS industry_dim_id,
    chi_tieu.rpt_year                                                              AS rpt_year
    ,chi_tieu.rpt_quarter                                                          AS rpt_quarter
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '270')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '300'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS total_asset
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS total_liability
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS equity
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND chi_tieu.row_description_reference = '411'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS contributed_capital
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '60')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '21'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS net_profit
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '50')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '17'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS pre_tax_profit
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '60')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '21'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS net_profit_ytd
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '10')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('1','4','7','8','9')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS net_revenue_ytd
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '50')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '17'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS pre_tax_profit_ytd
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '270')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '300'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS total_asset_beginning
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS equity_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS total_liability_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND chi_tieu.row_description_reference = '411'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS contributed_capital_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '140'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS inventory_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '421'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS undistributed_profit_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference IN ('130','210'))
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('251','252')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS receivable_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '110')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('110','120')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS cash_and_equivalent_beginning
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '140'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS inventory
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '10')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('1','4','7','8','9')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS net_revenue
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '421'
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS undistributed_profit
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference IN ('130','210'))
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('251','252')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS receivable
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '110')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('110','120')))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS cash_and_equivalent
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.cell_val END)
    / NULLIF(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.cell_val END), 0) AS decimal(30,6))                                          AS debt_to_equity
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.cell_val END)
    / NULLIF(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.cell_val END), 0) AS decimal(30,6))                                          AS debt_to_equity_beginning
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCLCTT%' AND chi_tieu.column_description_reference = '1' AND chi_tieu.cf_pref_rank = 1
             AND (UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '20')
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS operating_cash_flow
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND (UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '100')
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS short_term_asset
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND (UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '310')
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS short_term_liability
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND (UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '23')
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS interest_expense
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '21') OR (UPPER(chi_tieu.enterprise_tp_code) = 'BH' AND chi_tieu.row_description_reference = '12'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS financial_revenue
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '31') OR (UPPER(chi_tieu.enterprise_tp_code) = 'BH' AND chi_tieu.row_description_reference = '13'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS other_revenue
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND (UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '23')
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS interest_expense_ytd
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '21') OR (UPPER(chi_tieu.enterprise_tp_code) = 'BH' AND chi_tieu.row_description_reference = '12'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS financial_revenue_ytd
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) = 'DN' AND chi_tieu.row_description_reference = '31') OR (UPPER(chi_tieu.enterprise_tp_code) = 'BH' AND chi_tieu.row_description_reference = '13'))
        THEN chi_tieu.cell_val END) AS decimal(38,8))                                               AS other_revenue_ytd
FROM chi_tieu
INNER JOIN company
    ON company.public_company_code = chi_tieu.pc_code
LEFT JOIN industry
    ON industry.industry_code = company.business_line_level_1_code
GROUP BY
    company.public_company_dim_id ,
    industry.industry_dim_id ,
    chi_tieu.rpt_year,
    chi_tieu.rpt_quarter
)

-- Mau so ROA/ROE theo logic BA: dau ky/cuoi ky NULL hoac = 0 thi lay cot con lai
SELECT
    public_company_dim_id
    ,snpst_dt_dim_id
    ,industry_dim_id
    ,rpt_year
    ,rpt_quarter
    ,total_asset
    ,total_liability
    ,equity
    ,contributed_capital
    ,net_profit
    ,pre_tax_profit
    ,net_profit_ytd
    ,net_revenue_ytd
    ,pre_tax_profit_ytd
    ,total_asset_beginning
    ,equity_beginning
    ,total_liability_beginning
    ,contributed_capital_beginning
    ,inventory_beginning
    ,undistributed_profit_beginning
    ,receivable_beginning
    ,cash_and_equivalent_beginning
    ,inventory
    ,net_revenue
    ,undistributed_profit
    ,receivable
    ,cash_and_equivalent
    ,CAST(net_profit * 100
        / NULLIF((CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END
                + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)
        AS decimal(30,6))                                                          AS roa
    ,CAST(net_profit * 100
        / NULLIF((CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END
                + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)
        AS decimal(30,6))                                                          AS roe
    ,CAST(net_profit_ytd * 100
        / NULLIF((CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END
                + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)
        AS decimal(30,6))                                                          AS roa_ytd
    ,CAST(net_profit_ytd * 100
        / NULLIF((CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END
                + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)
        AS decimal(30,6))                                                          AS roe_ytd
    ,debt_to_equity
    ,debt_to_equity_beginning
    ,operating_cash_flow
    ,short_term_asset
    ,short_term_liability
    ,interest_expense
    ,financial_revenue
    ,other_revenue
    ,CAST(short_term_asset / NULLIF(short_term_liability, 0) AS decimal(30,6))      AS current_ratio
    ,CAST((pre_tax_profit + interest_expense) / NULLIF(interest_expense, 0) AS decimal(30,6)) AS interest_coverage
    ,CAST(financial_revenue / NULLIF(net_profit, 0) AS decimal(30,6))               AS financial_revenue_to_net_profit
    ,CAST(other_revenue / NULLIF(net_profit, 0) AS decimal(30,6))                   AS other_revenue_to_net_profit
    ,interest_expense_ytd
    ,financial_revenue_ytd
    ,other_revenue_ytd
    ,CAST((pre_tax_profit_ytd + interest_expense_ytd) / NULLIF(interest_expense_ytd, 0) AS decimal(30,6)) AS interest_coverage_ytd
    ,CAST(financial_revenue_ytd / NULLIF(net_profit_ytd, 0) AS decimal(30,6))       AS financial_revenue_to_net_profit_ytd
    ,CAST(other_revenue_ytd / NULLIF(net_profit_ytd, 0) AS decimal(30,6))           AS other_revenue_to_net_profit_ytd
FROM smy_base
    
	