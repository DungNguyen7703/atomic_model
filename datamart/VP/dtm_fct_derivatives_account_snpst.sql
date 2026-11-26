/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_derivatives_account_snpst
* Program name: Fact Derivatives Account Snapshot
* Created by: huy.pham
* Created date: 2026-11-05
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-05      huy.pham        [MOI, theo LLD] Fact snapshot so luong tai khoan
*                                 phai sinh theo thang bao cao TTLK01_1. Grain = 1
*                                 dong bieu mau (row_index) / thang. Pivot column_path
*                                 thanh: total_account_quantity, domestic_account_quantity,
*                                 foreign_account_quantity. snpst_dt = LAST_DAY thang bao
*                                 cao. PK hash(snpst_dt_dim_id|row_nbr|src_stm_code).
*                                 ds_snpst_dt cung cua BA -> ds_rcrd_st = 'ACTIVE'.
*--------------------------------------------------------------------*
*/

WITH rpt AS (
    SELECT
        src_stm_code,
        rpt_year,
        rpt_month,
        row_index,
        TRIM(REGEXP_REPLACE(column_path, '\\s+', ' ')) AS col_path_norm,
        cell_val
    FROM uat_atm.internal_statistical_report
    WHERE src_stm_code              = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND rpt_code                = 'TTLK01_1'
        AND rpt_submission_stm_code = 'ICP'
        AND submission_status_code  IN ('SUBMITTED', 'LATE_SUBMITTED')
        AND period_tp_code          = 'MONTHLY'
       -- AND LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1)) <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') -- báo cáo này kéo theo tháng nên cân nhắc để nó về thành event thay vì select full như hiện tại 
        AND ds_rcrd_st              = 'ACTIVE'
),

rpt_pvt AS (
    SELECT
        src_stm_code,
        rpt_year,
        rpt_month,
        row_index,
        LAST_DAY(MAKE_DATE(rpt_year, rpt_month, 1))                                                AS snpst_dt,
        TRY_CAST(MAX(CASE WHEN col_path_norm = 'TỔNG CỘNG'
                          THEN NULLIF(cell_val, '') END) AS INT)                                    AS total_account_quantity,
        TRY_CAST(MAX(CASE WHEN col_path_norm = 'SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC'
                          THEN NULLIF(cell_val, '') END) AS INT)                                    AS domestic_account_quantity,
        TRY_CAST(MAX(CASE WHEN col_path_norm = 'SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI'
                          THEN NULLIF(cell_val, '') END) AS INT)                                    AS foreign_account_quantity
    FROM rpt
    GROUP BY src_stm_code, rpt_year, rpt_month, row_index
)

SELECT
    CAST({{ generate_surrogate_key(
        'ISS_INTERNAL_STATISTICAL_REPORT',
        "CONCAT(date_format(snpst_dt, 'yyyyMMdd'), '|', CAST(row_index AS string), '|', src_stm_code)"
    ) }} AS string)                                                                                 AS derivatives_account_snpst_id,
    CAST(date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(date_format(snpst_dt, 'yyyyMMdd') AS string)                                              AS cdr_dt_dim_id,
    CAST(row_index AS int)                                                                          AS row_nbr,
    CAST(total_account_quantity AS int)                                                             AS total_account_quantity,
    CAST(domestic_account_quantity AS int)                                                          AS domestic_account_quantity,
    CAST(foreign_account_quantity AS int)                                                           AS foreign_account_quantity,
    CAST(src_stm_code AS string)                                                                    AS src_stm_code
FROM rpt_pvt
