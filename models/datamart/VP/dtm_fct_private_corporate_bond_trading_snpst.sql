/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_trading_snpst
* Program name: Dtm Fct Private Corporate Bond Trading Snapshot
* Created by: huy.pham
* Created date: 2026-10-28
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-28      huy.pham        [MOI, theo LLD DTM_VP_fct_private_corporate_bond_trading_
*                                 snpst.csv] Fact snapshot GD TPDN rieg le theo ngay bao cao
*                                 HNX09. Grain = 1 dong / ngay bao cao, toan thi truong. Pivot
*                                 row_path thanh cot: trading_val, foreign_buy_val,
*                                 foreign_sell_val. Chi lay nguon So (rpt_submission_stm_code=
*                                 'ICP'), trang thai SUBMITTED/LATE_SUBMITTED, ep so chi khi
*                                 data_tp_code IN (CURRENCY,PERCENTAGE,NUMBER) bang TRY_CAST.
*                                 O_VP_20: ds_snpst_dt cung cua BA -> dung ds_rcrd_st='ACTIVE'.
*                                 O_VP_21: khoa o atomic chua gom nguon nop / trang thai nop.
* 2026-10-29      huy.pham        Them src_stm_code vao PK hash, GROUP BY va SELECT de
*                                 tranh trung khoa khi nhieu nguon.
*--------------------------------------------------------------------*
*/

WITH rpt AS (
    SELECT
        src_stm_code,
        MAKE_DATE(rpt_year, rpt_month, rpt_day)     AS rpt_dt,
        row_path,
        data_tp_code,
        cell_val
    FROM uat_atm.internal_statistical_report
    WHERE src_stm_code              = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND rpt_code                = 'HNX09'
        AND sheet_nm                = 'sheet 1'
        AND column_path             = 'GIÁ TRỊ'
        AND period_tp_code          = 'DAILY'
        AND rpt_submission_stm_code = 'ICP'
        AND submission_status_code  IN ('SUBMITTED','LATE_SUBMITTED')
        AND MAKE_DATE(rpt_year, rpt_month, rpt_day) = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st              = 'ACTIVE'
),

rpt_agg AS (
    SELECT
        src_stm_code,
        rpt_dt,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH'
                  AND data_tp_code IN ('CURRENCY','PERCENTAGE','NUMBER')
                 THEN TRY_CAST(cell_val AS decimal(38,15)) END)                                             AS trading_val,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA'
                  AND data_tp_code IN ('CURRENCY','PERCENTAGE','NUMBER')
                 THEN TRY_CAST(cell_val AS decimal(38,15)) END)                                             AS foreign_buy_val,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ BÁN'
                  AND data_tp_code IN ('CURRENCY','PERCENTAGE','NUMBER')
                 THEN TRY_CAST(cell_val AS decimal(38,15)) END)                                             AS foreign_sell_val
    FROM rpt
    GROUP BY src_stm_code, rpt_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('ISS_INTERNAL_STATISTICAL_REPORT', "CONCAT(date_format(rpt_dt,'yyyyMMdd'), '|', src_stm_code)") }} AS string) AS private_corporate_bond_trading_snpst_id,
    CAST(date_format(rpt_dt, 'yyyyMMdd') AS string)     AS snpst_dt_dim_id,
    CAST(trading_val AS decimal(23,2))                  AS trading_val,
    CAST(foreign_buy_val AS decimal(23,2))              AS foreign_buy_val,
    CAST(foreign_sell_val AS decimal(23,2))             AS foreign_sell_val,
    CAST(src_stm_code AS string)                        AS src_stm_code
FROM rpt_agg
