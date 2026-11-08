-- [FIRST-TIME] ft_dtm_fct_securities_company_balance_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_securities_company_balance_snpst (config ft_target='fct_securities_company_balance_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_balance_snpst
* Program name: Fact Securities Company Balance Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_securities_company_balance_snpst:
*									- Daily ghi TOAN BO lich su ky bao cao vao lat ds_snpst_dt = etl_date; ban ft sinh DUNG 1 LAT duy nhat, ds_snpst_dt = etl_date cua lan chay
*									  (chay voi dates = [ngay dau khoang lich su can xem]); noi dung lat = toan bo lich su ky bao cao (bo submission_dt <= etl_date).
*									- append: ds_snpst_dt = etl_date dat CUOI SELECT (khong cat theo etl_date trong noi dung).
*									- HAN CHE: dim doc bang MAIN ds_rcrd_st='ACTIVE' (khong _hstr theo ngay) (securities_company, public_company, securities_company_dim)
*									  khai thac lay max(ds_snpst_dt) <= ngay chon nen cac ngay chon TRUOC etl_date cua lat nay se khong co du lieu.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi 1 lat ds_snpst_dt = etl_date (thay strategy snapshot cua yml)

WITH se_co AS (

    SELECT
        sc_code
        , securities_code
    FROM {{ ref('atm_securities_company') }}   -- [BACKFILL-UAT-NEW] bang MAIN
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_securities_company') }}_hstr WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL

),

sc_dim AS (

    SELECT
        securities_company_dim_id
        , sc_code
    FROM {{ ref('dtm_securities_company_dim') }}   -- [BACKFILL-UAT-NEW] bang MAIN
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('dtm_securities_company_dim') }}_hstr WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'

),

pu_co AS (

    SELECT
        pc_id
        , equity_ticker_symbol
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW] bang MAIN
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'

),

pc_rpt_sub_valid AS (

    SELECT
        pc_id
        , rpt_year
        , rpt_quarter
        , fr_code
        , submission_dt
        , src_stm_code
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND approval_status_code = 'APPROVED'
        AND SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI')
        AND rpt_quarter IN (1,2,3,4)
        -- [BACKFILL-UAT-ORIG] AND submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')   (lat first-time chua TOAN BO lich su ky bao cao)

),

pc_rpt_sub_ranked AS (

    SELECT
        pc_rpt_sub_valid.*
        , ROW_NUMBER() OVER (
            PARTITION BY pc_rpt_sub_valid.pc_id, pc_rpt_sub_valid.rpt_year, pc_rpt_sub_valid.rpt_quarter
            ORDER BY
                CASE SUBSTR(pc_rpt_sub_valid.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , pc_rpt_sub_valid.submission_dt DESC
        ) AS rn0
    FROM pc_rpt_sub_valid

),

pc_rpt_sub_dedup AS (

    SELECT pc_id, rpt_year, rpt_quarter, fr_code, src_stm_code
    FROM pc_rpt_sub_ranked
    WHERE rn0 = 1

),

fin_value_joined AS (

    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.src_stm_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fv.cell_val
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCDKT%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'

),

fin_pivot AS (

    SELECT
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter
        , MAX(fin_value_joined.src_stm_code) AS src_stm_code
        , MAX(CASE
            WHEN (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '300')
                OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '400')
            THEN fin_value_joined.cell_val
          END) AS total_liabilities_amt
        , MAX(CASE
            WHEN (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
            THEN fin_value_joined.cell_val
          END) AS owner_equity_amt
    FROM fin_value_joined
    GROUP BY
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter

)

SELECT
    CAST(date_format(last_day(to_date(CONCAT(CAST(fin_pivot.rpt_year AS string), LPAD(CAST(fin_pivot.rpt_quarter * 3 AS string), 2, '0'), '01'), 'yyyyMMdd')), 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(sc_dim.securities_company_dim_id AS string)        AS securities_company_dim_id,
    CAST(fin_pivot.rpt_year AS int)                         AS rpt_year,
    CAST(fin_pivot.rpt_quarter AS int)                      AS rpt_quarter,
    CAST(fin_pivot.total_liabilities_amt AS decimal(23,2))  AS total_liabilities_amt,
    CAST(fin_pivot.owner_equity_amt AS decimal(23,2))       AS owner_equity_amt,
    CAST(fin_pivot.src_stm_code AS string)                  AS src_stm_code,
    CAST(to_date('{{ var("etl_date") }}','yyyy-MM-dd') AS date) AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] dong dau lat = etl_date cua lan chay (daily: ds_snpst_dt = etl_date)
FROM se_co
INNER JOIN pu_co
    ON pu_co.equity_ticker_symbol = se_co.securities_code
INNER JOIN fin_pivot
    ON fin_pivot.pc_id = pu_co.pc_id
INNER JOIN sc_dim
    ON sc_dim.sc_code = se_co.sc_code
