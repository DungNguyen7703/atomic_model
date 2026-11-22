-- [FIRST-TIME] ft_dtm_fct_index_contribution_rpt_snpst: khoi tao lich su, ghi vao bang that fct_index_contribution_rpt_snpst (ft_target).
/*
*--------------------------------------------------------------------*
* Program code: ft_dtm_fct_index_contribution_rpt_snpst
* Program name: FT Dtm Fct Index Contribution Report Snapshot
* Created by: claude
* Created date: 2026-11-17
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-17		claude				[MOI, O_GSTT_87] Theo LLD DTM_GSTT_fct_index_contribution_rpt_snpst.csv. Fact diem dong gop (%) cua ma CK vao chi so VN30/HNX30 tu bao cao TMS bieu mau PL01_W_F02. Nguon atm_cr_value (grain 1 o = 1 ma CK x 1 dong ngay x 1 lan nop). PK = cr_val_id.
*                                       Ngay du lieu cua dong = o 'Ngay/ ma chung khoan' (COL_01) cung dong (window theo form_code, submission_dt, row_index), thu 3 dinh dang d/M/yyyy, yyyy/M/d, d/M/yy.
*                                       Cach chon dim: symbol = TRIM(column_label) tren dtm_security_trading_snpst_dim_hstr (ACTIVE, ds_snpst_dt = ngay nop); khong khop -> FK NULL, van giu dong nho ticker_symbol.
*                                       Partition theo submission_dt (khong theo snpst_dt_dim_id): 1 lan nop bao cao tuan chua nhieu ngay du lieu, INSERT OVERWRITE theo snpst_dt_dim_id se de mat dong cua lan nop khac.
* 2026-11-17		claude				Fix contribution_percentage NULL: cell_val o nguon TMS PL01_W_F02 co ky tu '%' o cuoi (vd '3.78%') -> lam sach '%', khoang trang va doi ',' thanh '.' truoc khi TRY_CAST DECIMAL(18,10).
*--------------------------------------------------------------------*
*/

WITH cr AS (
    SELECT
        cr_val_id
        , column_code
        , column_label
        , cell_val
        , submission_dt
        , submitter_tp_code
        , form_code
        -- Ngay du lieu cua dong = o 'Ngay/ ma chung khoan' cung dong (window truoc khi loc COL_01)
        , MAX(CASE WHEN column_label = 'Ngày/ mã chứng khoán' THEN cell_val END)
            OVER (PARTITION BY form_code, submission_dt, row_index) AS row_date_raw
    FROM {{ ref('atm_cr_value') }}
    WHERE form_code = 'PL01_W_F02'   -- [BACKFILL] first-time: toan bo lich su nop, khong loc etl_date
),

dt AS (
    SELECT
        cr.*
        , COALESCE(
            TO_DATE(REGEXP_REPLACE(TRIM(row_date_raw), '[-.]', '/'), 'd/M/yyyy')
            , TO_DATE(REGEXP_REPLACE(TRIM(row_date_raw), '[-.]', '/'), 'yyyy/M/d')
            , TO_DATE(REGEXP_REPLACE(TRIM(row_date_raw), '[-.]', '/'), 'd/M/yy')
        ) AS snpst_dt
    FROM cr
    WHERE column_code <> 'COL_01'
        AND submitter_tp_code IN ('HOSE', 'HNX')
),

sd AS (
    SELECT
        security_trading_snpst_dim_id
        , symbol
        , ds_snpst_dt
    FROM (
        SELECT
            security_trading_snpst_dim_id
            , symbol
            , ds_snpst_dt
            , ROW_NUMBER() OVER (PARTITION BY symbol, ds_snpst_dt ORDER BY security_trading_snpst_dim_id) AS rn
        FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_rcrd_st = 'ACTIVE'
    ) x
    WHERE rn = 1
)

SELECT
    CAST(dt.cr_val_id AS string)                                  AS index_contribution_rpt_id,
    CAST(sd.security_trading_snpst_dim_id AS string)              AS security_trading_snpst_dim_id,
    CAST(date_format(dt.snpst_dt, 'yyyyMMdd') AS string)          AS snpst_dt_dim_id,
    CAST(TRIM(dt.column_label) AS string)                         AS ticker_symbol,
    TRY_CAST(REGEXP_REPLACE(REPLACE(TRIM(dt.cell_val), ',', '.'), '[%\\s]', '') AS DECIMAL(18,10)) AS contribution_percentage,
    CAST(dt.submission_dt AS date)                                AS submission_dt,
    CAST(dt.submitter_tp_code AS string)                          AS submitter_tp_code,
    CAST(dt.form_code AS string)                                  AS form_code
FROM dt
    LEFT JOIN sd
        ON sd.symbol = TRIM(dt.column_label)
        AND sd.ds_snpst_dt = dt.submission_dt
WHERE dt.snpst_dt IS NOT NULL
    AND TRIM(dt.column_label) IS NOT NULL   -- ticker_symbol NOT NULL (LLD nullable=false)
