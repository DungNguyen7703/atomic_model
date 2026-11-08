-- [FIRST-TIME] ft_dtm_fct_macro_indicator_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_macro_indicator_snpst (config ft_target='fct_macro_indicator_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_macro_indicator_snpst
* Program name: Fact Macro Indicator Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_macro_indicator_snpst:
*									- BO 2 dieu kien loc ngay (ri_val_hist: period_dt <= etl_date; SELECT cuoi: period_dt = etl_date) de nap TOAN BO lich su 1 lan:
*									  moi (chi tieu, period_dt) ra 1 dong, ds_snpst_dt = period_dt (daily: moi lan chay chi ghi dong period_dt = etl_date).
*									- LAG/AVG/yoy giu nguyen: cac window chi nhin ve TRUOC (LAG, ROWS 19 PRECEDING) nen gia tri tai moi dong = gia tri daily
*									  se ra neu chay dung ngay do (daily cat lich su o period_dt <= etl_date).
*									- atm_cl_risk_indicator_value la upsert giu du lich su -> ref() thuong (khong co ban ft).
* 2026-11-02		tuan.nguyenvanb		[THEM 8 COT KY] Xuat thong tin ky ra de man hinh hien dung ky cua tung con so: period_val, period_year (ky hien tai), prev_period_label, prev_period_period_val, prev_period_period_year (ky cua prev_period_val, pct_change), prev_year_val, prev_year_label, prev_year_period_year (ky cua yoy_pct_change). Cac cot dat SAU ma_n_val, TRUOC src_stm_code. Khong doi cong thuc cac cot cu. Mart ghi theo VI TRI cot -> phai ALTER ADD COLUMN AFTER dung vi tri truoc khi chay (xem scratch/alter_pttt_macro_period_20261102.sql).
* 2026-11-03		tuan.nguyenvanb		[THEM COT unit_tp_code THEO LLD] don vi cua gia tri chi tieu (MRMS UNIT_TYPE), lay tu atm_cl_risk_indicator_value.unit_tp_code, dat SAU indicator_val, TRUOC prev_period_val. Mart ghi theo VI TRI cot -> ALTER ADD COLUMN unit_tp_code AFTER indicator_val truoc khi chay (xem scratch/alter_pttt_macro_unit_tp_code_20261103.sql); can build lai mart + flat.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH ri_val_hist AS (

    SELECT
        cl_risk_ind_code
        , period_tp_code
        , period_val
        , period_year
        , period_dt
        , period_label
        , val
        , unit_tp_code
    FROM {{ ref('atm_cl_risk_indicator_value') }}
    -- [BACKFILL-UAT-ORIG] WHERE period_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

ri_ind AS (

    SELECT
        cl_risk_ind_code
        , ind_nm
    FROM {{ ref('atm_cl_risk_indicator') }}

),

windowed AS (

    SELECT
        ri_val_hist.*
        , LAG(ri_val_hist.val) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
        ) AS prev_period_val
        , LAG(ri_val_hist.val, 1) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code, ri_val_hist.period_val
            ORDER BY ri_val_hist.period_year
        ) AS prev_year_val
        , LAG(ri_val_hist.period_label) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
        ) AS prev_period_label
        , LAG(ri_val_hist.period_val) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
        ) AS prev_period_period_val
        , LAG(ri_val_hist.period_year) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
        ) AS prev_period_period_year
        , LAG(ri_val_hist.period_label, 1) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code, ri_val_hist.period_val
            ORDER BY ri_val_hist.period_year
        ) AS prev_year_label
        , LAG(ri_val_hist.period_year, 1) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code, ri_val_hist.period_val
            ORDER BY ri_val_hist.period_year
        ) AS prev_year_period_year
        , AVG(ri_val_hist.val) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ) AS ma_n_val
    FROM ri_val_hist

)

SELECT
    CAST(date_format(windowed.period_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(windowed.cl_risk_ind_code AS string)                        AS macro_indicator_code,
    CAST(ri_ind.ind_nm AS string)                                    AS macro_indicator_name,
    CAST(windowed.period_tp_code AS string)                         AS period_tp_code,
    CAST(windowed.period_label AS string)                            AS period_label,
    CAST(windowed.val AS decimal(23,4))                              AS indicator_val,
    CAST(windowed.unit_tp_code AS string)                            AS unit_tp_code,
    CAST(windowed.prev_period_val AS decimal(23,4))                  AS prev_period_val,
    CAST(
        ROUND(
            (windowed.val - windowed.prev_period_val) / NULLIF(windowed.prev_period_val, 0) * 100
        , 2)
    AS decimal(5,2))                                                  AS pct_change,
    CAST(
        ROUND(
            (windowed.val - windowed.prev_year_val) / NULLIF(windowed.prev_year_val, 0) * 100
        , 2)
    AS decimal(5,2))                                                  AS yoy_pct_change,
    CAST(windowed.ma_n_val AS decimal(23,4))                          AS ma_n_val,
    CAST(windowed.period_val AS int)                                  AS period_val,
    CAST(windowed.period_year AS int)                                 AS period_year,
    CAST(windowed.prev_period_label AS string)                        AS prev_period_label,
    CAST(windowed.prev_period_period_val AS int)                      AS prev_period_period_val,
    CAST(windowed.prev_period_period_year AS int)                     AS prev_period_period_year,
    CAST(windowed.prev_year_val AS decimal(23,4))                     AS prev_year_val,
    CAST(windowed.prev_year_label AS string)                          AS prev_year_label,
    CAST(windowed.prev_year_period_year AS int)                       AS prev_year_period_year,
    CAST('MRMS' AS string)                                            AS src_stm_code,
    CAST(windowed.period_dt AS date)                                  AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = period_dt (daily: = etl_date = period_dt)
FROM windowed
LEFT JOIN ri_ind
    ON ri_ind.cl_risk_ind_code = windowed.cl_risk_ind_code
-- [BACKFILL-UAT-ORIG] WHERE windowed.period_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
