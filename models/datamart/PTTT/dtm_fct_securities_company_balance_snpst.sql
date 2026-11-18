/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_balance_snpst
* Program name: Fact Securities Company Balance Snapshot
* Created by:
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01			Claude				Tao moi theo LLD DTM_PTTT_fct_securities_company_balance_snpst.csv (changelog Phan 10)
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Grain: 1 CTCK niem yet x quy bao cao (BCDKT, IDS). Phuc vu K_PTTT_198
*   (tong no phai tra) va K_PTTT_200 (D/E) - BI chon quy gan nhat.
* - CTCK noi IDS qua securities_company.securities_code =
*   public_company.equity_ticker_symbol (O_PTTT_32: chi phu CTCK niem yet).
* - Moi (pc_id, rpt_year, rpt_quarter) chot DUNG 1 bao cao theo uu tien
*   HN > TH > ME > RI roi submission_dt moi nhat (rn0); GIU MOI quy da cong
*   bo (submission_dt <= etl_date), KHONG xep hang rn1 nhu opr credit monitor.
* - total_liabilities_amt: row_desc 300 (DN/BH) / 400 (TD); owner_equity_amt:
*   row_desc 400 (DN/BH) / 500 (TD); column_description_reference = '1'.
* - Model incremental_rebase/snapshot, partition ds_snpst_dt: moi ngay ghi
*   lai toan bo cac quy da cong bo -> flat loc theo ds_snpst_dt = etl_date.
* - snpst_dt_dim_id = ngay cuoi quy cua (rpt_year, rpt_quarter).
* - Don vi VND (O_PTTT_32). src_stm_code = src_stm_code cua pc_report_submission.
*--------------------------------------------------------------------*
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*/

WITH se_co AS (

    SELECT
        sc_code
        , securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL

),

sc_dim AS (

    SELECT
        securities_company_dim_id
        , sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'

),

pu_co AS (

    SELECT
        pc_id
        , equity_ticker_symbol
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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
        AND submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')

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
    CAST(fin_pivot.src_stm_code AS string)                  AS src_stm_code
FROM se_co
INNER JOIN pu_co
    ON pu_co.equity_ticker_symbol = se_co.securities_code
INNER JOIN fin_pivot
    ON fin_pivot.pc_id = pu_co.pc_id
INNER JOIN sc_dim
    ON sc_dim.sc_code = se_co.sc_code
