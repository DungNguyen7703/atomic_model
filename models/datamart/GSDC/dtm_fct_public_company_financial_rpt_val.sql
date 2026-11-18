/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_financial_rpt_val
* Program name: Dtm Fct Public Company Financial Rpt Val
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		duc.luxuan			Doi kieu du lieu: cell_val decimal(23,2) -> decimal(38,8) theo atm_fr_value.cell_val.
*								Nguon: atm_fr_value.cell_val doi decimal(20,2) -> decimal(38,8). Quy uoc: cot
*								chi tieu co so = (38,8), cot tinh tu phep chia = (30,6). Bang Iceberg KHONG doi
*								scale tai cho + INSERT theo vi tri => PHAI chay DDL
*								lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql TRUOC dbt run. KHONG --full-refresh.
*--------------------------------------------------------------------*
*/

WITH fr_value_raw AS (
    SELECT
        pc_id,
        pc_code,
        fr_catalog_id,
        fr_catalog_code,
        row_code,
        column_code,
        rpt_year,
        rpt_quarter,
        cell_val,
        ROW_NUMBER() OVER (
            PARTITION BY pc_id, rpt_year, rpt_quarter, fr_catalog_id, row_code, column_code
            ORDER BY ds_rcrd_udt_dt DESC, ds_rcrd_isrt_dt DESC
        ) AS rn
    FROM {{ ref('atm_fr_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_DATA'
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

fr_catalog_dim AS (
    SELECT
        financial_rpt_catalog_dim_id,
        financial_catalog_code,
        row_code,
        column_code,
        fr_year
    FROM {{ ref('dtm_financial_rpt_catalog_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
),

-- Atomic Financial Report Catalog (khác dtm_financial_rpt_catalog_dim) — cần cột
-- financial_statement_tp_code để đối chiếu với template thắng dedup bên dưới, cột này
-- không có trên Dimension datamart.
fr_catalog_atomic AS (
    SELECT
        fr_catalog_id,
        fr_year,
        financial_statement_tp_code
    FROM {{ ref('atm_fr_catalog') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
),

fr_template AS (
    SELECT
        fr_id,
        fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND news_tp_code = 'DINH_KY'
        AND src_stm_code = 'IDS_FORMS'
),

report_submission_raw AS (
    SELECT
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_id,
        submission_dt
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND approval_status_code = 'APPROVED'
        AND src_stm_code = 'IDS_COMPANY_DATA'
),

-- Dedup submission: 1 hồ sơ thắng cuộc / pc_code / rpt_year / rpt_quarter.
-- Ưu tiên loại báo cáo: Hợp nhất (HN) > Tổng hợp (TH) > ME > Riêng lẻ (RI); cùng loại thì
-- submission_dt gần nhất thắng.
report_submission_ranked AS (
    SELECT
        report_submission_raw.pc_code,
        report_submission_raw.rpt_year,
        report_submission_raw.rpt_quarter,
        fr_template.fr_code,
        ROW_NUMBER() OVER (
            PARTITION BY report_submission_raw.pc_code, report_submission_raw.rpt_year, report_submission_raw.rpt_quarter
            ORDER BY
                CASE
                    WHEN fr_template.fr_code LIKE 'HN%' THEN 1
                    WHEN fr_template.fr_code LIKE 'TH%' THEN 2
                    WHEN fr_template.fr_code LIKE 'ME%' THEN 3
                    WHEN fr_template.fr_code LIKE 'RI%' THEN 4
                END,
                report_submission_raw.submission_dt DESC
        ) AS rn
    FROM report_submission_raw
    INNER JOIN fr_template
        ON fr_template.fr_id = report_submission_raw.fr_id
),

-- Dedup 1 dòng / pc_id / rpt_year / rpt_quarter / row_code / column_code (bản ghi cập nhật
-- gần nhất thắng) — lọc hẳn dòng trùng khỏi grain, không chỉ null hoá cell_val của dòng thua.
fr_value AS (
    SELECT
        pc_id,
        pc_code,
        fr_catalog_id,
        fr_catalog_code,
        row_code,
        column_code,
        rpt_year,
        rpt_quarter,
        cell_val
    FROM fr_value_raw
    WHERE rn = 1
),

report_submission AS (
    SELECT
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_code
    FROM report_submission_ranked
    WHERE rn = 1
)

SELECT
    CAST(company.public_company_dim_id AS string)                                      AS public_company_dim_id,
    CAST(fr_catalog_dim.financial_rpt_catalog_dim_id AS string)                        AS financial_rpt_catalog_dim_id,
    CAST(industry.industry_dim_id AS string)                                           AS industry_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')              AS snpst_dt_dim_id,
    CAST(fr_value.rpt_year AS int)                                                     AS rpt_year,
    CAST(fr_value.rpt_quarter AS int)                                                  AS rpt_quarter,
    CAST(fr_value.row_code AS string)                                                  AS row_code,
    CAST(fr_value.column_code AS string)                                               AS column_code,
    CAST(fr_value.cell_val AS decimal(38,8))                                           AS data_val
FROM fr_value
LEFT JOIN company
    ON company.public_company_code = fr_value.pc_code
LEFT JOIN industry
    ON industry.industry_code = company.business_line_level_1_code
LEFT JOIN fr_catalog_dim
    ON  fr_catalog_dim.financial_catalog_code = fr_value.fr_catalog_code
    AND fr_catalog_dim.row_code = fr_value.row_code
    AND fr_catalog_dim.column_code = fr_value.column_code
    AND fr_catalog_dim.fr_year = fr_value.rpt_year
INNER JOIN report_submission
    ON  report_submission.pc_code = fr_value.pc_code
    AND report_submission.rpt_year = fr_value.rpt_year
    AND report_submission.rpt_quarter = fr_value.rpt_quarter
INNER JOIN fr_catalog_atomic
    ON  fr_catalog_atomic.fr_catalog_id = fr_value.fr_catalog_id
    AND fr_catalog_atomic.fr_year = fr_value.rpt_year
    AND fr_catalog_atomic.financial_statement_tp_code = SUBSTR(report_submission.fr_code, 1, 2)
