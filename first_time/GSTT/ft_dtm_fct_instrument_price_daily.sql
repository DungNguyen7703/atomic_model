-- [FIRST-TIME] ft_dtm_fct_instrument_price_daily: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_instrument_price_daily (config ft_target='fct_instrument_price_daily', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_instrument_price_daily
* Program name: Dtm Fct Instrument Price Daily
* Created by: tuan.nguyenvanb
* Created date: 2026-10-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-06		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_instrument_price_daily.csv, GSTT
*                                       Nhom 34, LLD v4.33-v4.36] Fact nen NGAY theo do min ca ma CK VA
*                                       chi so: 1 dong / Instrument Code / Trade Date. Nguon Atomic
*                                       market_price_snapshot (MDDS JAD_tvhistory1d), kem Doanh thu / LNST
*                                       cua ky BCTC gan nhat da cong bo (rule GSDC, giong
*                                       dtm_fct_stock_portfolio_snpst) - NULL voi dong chi so.
*                                       Khac dtm_fct_security_trading_daily (Nhom 48, chi ma CK).
*                                       [LUU Y] LLD ghi src_stm_code 'MDDS_JAD_TRADINGVIEWHISTORY1DAY';
*                                       atomic atm_market_price_snapshot dung dung gia tri nay cho nen ngay.
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT: bo loc etl_date, tra cuu theo tung ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH ma_pr_sn AS (
    SELECT
        symbol,
        trading_dt,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ft_ref('ft_atm_market_price_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'
    WHERE src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'   -- [BACKFILL-UAT-NEW]
),
-- [BACKFILL-UAT-ONEPASS-GSTT] Truc ngay giao dich cua lan chay mot luot.   -- [BACKFILL-UAT-NEW]
trade_dates AS (   -- [BACKFILL-UAT-NEW]
    SELECT DISTINCT CAST(trading_dt AS date) AS trading_dt   -- [BACKFILL-UAT-NEW]
    FROM ma_pr_sn   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- 1 cong ty / equity_ticker_symbol (nguon co ticker gan >1 pc_id): uu tien id nguon nho nhat,
-- order theo pc_code (id nguon that), KHONG order theo pc_id (surrogate hash).
pu_co_all AS (
    SELECT
        pc_id,
        equity_ticker_symbol,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint) ASC) AS rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

pu_co AS (
    SELECT pc_id, equity_ticker_symbol
    FROM pu_co_all
    WHERE rn = 1
),

-- ============================================================================
-- Doanh thu / LNST ky BCTC gan nhat da cong bo - rule GSDC (LLD v4.32). Cung logic voi
-- revenue_val/npat_val cua dtm_fct_stock_portfolio_snpst (BCTC DINH KY QUY, 1 bao cao/ky
-- HN>TH>ME>RI, ky gan nhat co submission_dt <= etl_date, fr_value dedupe, data_val NOT NULL).
-- ============================================================================
gsdc_fr_periodic AS (
    SELECT fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

-- [BACKFILL-UAT-ORIG] gsdc_sub_ranked AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] prs.pc_id,
        -- [BACKFILL-UAT-ORIG] prs.rpt_year,
        -- [BACKFILL-UAT-ORIG] prs.rpt_quarter,
        -- [BACKFILL-UAT-ORIG] prs.fr_code,
        -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (
            -- [BACKFILL-UAT-ORIG] PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter
            -- [BACKFILL-UAT-ORIG] ORDER BY
                -- [BACKFILL-UAT-ORIG] CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                -- [BACKFILL-UAT-ORIG] prs.submission_dt DESC
        -- [BACKFILL-UAT-ORIG] ) AS rn0
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_pc_report_submission') }} prs
    -- [BACKFILL-UAT-ORIG] WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        -- [BACKFILL-UAT-ORIG] AND prs.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND prs.approval_status_code = 'APPROVED'
        -- [BACKFILL-UAT-ORIG] AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)
        -- [BACKFILL-UAT-ORIG] AND prs.fr_code LIKE '%QUAR'
        -- [BACKFILL-UAT-ORIG] AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        -- [BACKFILL-UAT-ORIG] AND prs.rpt_quarter IN (1,2,3,4)
        -- [BACKFILL-UAT-ORIG] AND prs.submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] gsdc_sub_anchor AS (
    -- [BACKFILL-UAT-ORIG] SELECT pc_id, rpt_year, rpt_quarter, fr_code
    -- [BACKFILL-UAT-ORIG] FROM (
        -- [BACKFILL-UAT-ORIG] SELECT
            -- [BACKFILL-UAT-ORIG] r.*,
            -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (PARTITION BY r.pc_id ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1
        -- [BACKFILL-UAT-ORIG] FROM gsdc_sub_ranked r
        -- [BACKFILL-UAT-ORIG] WHERE r.rn0 = 1
    -- [BACKFILL-UAT-ORIG] ) t
    -- [BACKFILL-UAT-ORIG] WHERE rn1 = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Rule GSDC theo tung ngay: chi xet bao cao co submission_dt <= trading_dt (giong daily:   -- [BACKFILL-UAT-NEW]
-- submission_dt <= etl_date). Bo cong ty co ky nop moi nhat (rn1) tinh RIENG cho tung trading_dt.   -- [BACKFILL-UAT-NEW]
gsdc_sub_ranked AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        prs.pc_id,   -- [BACKFILL-UAT-NEW]
        prs.rpt_year,   -- [BACKFILL-UAT-NEW]
        prs.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        prs.fr_code,   -- [BACKFILL-UAT-NEW]
        td.trading_dt,   -- [BACKFILL-UAT-NEW]
        ROW_NUMBER() OVER (   -- [BACKFILL-UAT-NEW]
            PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter, td.trading_dt   -- [BACKFILL-UAT-NEW]
            ORDER BY   -- [BACKFILL-UAT-NEW]
                CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,   -- [BACKFILL-UAT-NEW]
                prs.submission_dt DESC   -- [BACKFILL-UAT-NEW]
        ) AS rn0   -- [BACKFILL-UAT-NEW]
    FROM {{ ref('atm_pc_report_submission') }} prs   -- [BACKFILL-UAT-NEW]
    INNER JOIN trade_dates td   -- [BACKFILL-UAT-NEW]
        ON  prs.submission_dt <= td.trading_dt   -- [BACKFILL-UAT-NEW]
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'   -- [BACKFILL-UAT-NEW]
        AND prs.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND prs.approval_status_code = 'APPROVED'   -- [BACKFILL-UAT-NEW]
        AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)   -- [BACKFILL-UAT-NEW]
        AND prs.fr_code LIKE '%QUAR'   -- [BACKFILL-UAT-NEW]
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')   -- [BACKFILL-UAT-NEW]
        AND prs.rpt_quarter IN (1,2,3,4)   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
-- (cong ty, trading_dt) -> ky anchor   -- [BACKFILL-UAT-NEW]
gsdc_sub_anchor_d AS (   -- [BACKFILL-UAT-NEW]
    SELECT pc_id, trading_dt, rpt_year, rpt_quarter, fr_code   -- [BACKFILL-UAT-NEW]
    FROM (   -- [BACKFILL-UAT-NEW]
        SELECT   -- [BACKFILL-UAT-NEW]
            r.*,   -- [BACKFILL-UAT-NEW]
            ROW_NUMBER() OVER (PARTITION BY r.pc_id, r.trading_dt ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1   -- [BACKFILL-UAT-NEW]
        FROM gsdc_sub_ranked r   -- [BACKFILL-UAT-NEW]
        WHERE r.rn0 = 1   -- [BACKFILL-UAT-NEW]
    ) t   -- [BACKFILL-UAT-NEW]
    WHERE rn1 = 1   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-NEW]
-- cac ky anchor phan biet (doc fr_value mot lan cho moi ky, khong lap theo ngay)   -- [BACKFILL-UAT-NEW]
gsdc_sub_anchor AS (   -- [BACKFILL-UAT-NEW]
    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code   -- [BACKFILL-UAT-NEW]
    FROM gsdc_sub_anchor_d   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

-- [BACKFILL-UAT-ORIG] gsdc_fr_value AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] a.pc_id,
        -- [BACKFILL-UAT-ORIG] a.rpt_year,
        -- [BACKFILL-UAT-ORIG] a.rpt_quarter,
        -- [BACKFILL-UAT-ORIG] a.fr_code,
        -- [BACKFILL-UAT-ORIG] fv.fr_catalog_id,
        -- [BACKFILL-UAT-ORIG] fv.row_code,
        -- [BACKFILL-UAT-ORIG] fv.column_code,
        -- [BACKFILL-UAT-ORIG] fv.data_val,
        -- [BACKFILL-UAT-ORIG] ROW_NUMBER() OVER (
            -- [BACKFILL-UAT-ORIG] PARTITION BY fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code
            -- [BACKFILL-UAT-ORIG] ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC
        -- [BACKFILL-UAT-ORIG] ) AS rn
    -- [BACKFILL-UAT-ORIG] FROM gsdc_sub_anchor a
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_value') }} fv
        -- [BACKFILL-UAT-ORIG] ON  fv.pc_id = a.pc_id
        -- [BACKFILL-UAT-ORIG] AND fv.rpt_year = a.rpt_year
        -- [BACKFILL-UAT-ORIG] AND fv.rpt_quarter = a.rpt_quarter
        -- [BACKFILL-UAT-ORIG] AND fv.src_stm_code = 'IDS_DATA'
        -- [BACKFILL-UAT-ORIG] AND fv.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fv.data_val IS NOT NULL
-- [BACKFILL-UAT-ORIG] ),
gsdc_fr_value AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        a.pc_id,   -- [BACKFILL-UAT-NEW]
        a.rpt_year,   -- [BACKFILL-UAT-NEW]
        a.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        a.fr_code,   -- [BACKFILL-UAT-NEW]
        fv.fr_catalog_id,   -- [BACKFILL-UAT-NEW]
        fv.row_code,   -- [BACKFILL-UAT-NEW]
        fv.column_code,   -- [BACKFILL-UAT-NEW]
        fv.cell_val AS data_val,   -- [BACKFILL-UAT-NEW]
        ROW_NUMBER() OVER (   -- [BACKFILL-UAT-NEW]
            PARTITION BY a.fr_code, fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code   -- [BACKFILL-UAT-NEW]
            ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC   -- [BACKFILL-UAT-NEW]
        ) AS rn   -- [BACKFILL-UAT-NEW]
    FROM gsdc_sub_anchor a   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_value') }} fv   -- [BACKFILL-UAT-NEW]
        ON  fv.pc_id = a.pc_id   -- [BACKFILL-UAT-NEW]
        AND fv.rpt_year = a.rpt_year   -- [BACKFILL-UAT-NEW]
        AND fv.rpt_quarter = a.rpt_quarter   -- [BACKFILL-UAT-NEW]
        AND fv.src_stm_code = 'IDS_DATA'   -- [BACKFILL-UAT-NEW]
        AND fv.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fv.cell_val IS NOT NULL   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

-- [BACKFILL-UAT-ORIG] revenue_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] v.pc_id,
        -- [BACKFILL-UAT-ORIG] SUM(v.data_val) AS revenue
    -- [BACKFILL-UAT-ORIG] FROM gsdc_fr_value v
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_catalog') }} fc
        -- [BACKFILL-UAT-ORIG] ON  fc.fr_catalog_id = v.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fc.fr_year = CAST(v.rpt_year AS string)
        -- [BACKFILL-UAT-ORIG] AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        -- [BACKFILL-UAT-ORIG] AND fc.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        -- [BACKFILL-UAT-ORIG] AND fc.rpt_code LIKE 'BCKQKD%'
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_row') }} frt
        -- [BACKFILL-UAT-ORIG] ON  frt.row_code = v.row_code
        -- [BACKFILL-UAT-ORIG] AND frt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND frt.src_stm_code = 'IDS_RROW'
        -- [BACKFILL-UAT-ORIG] AND frt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND (
            -- [BACKFILL-UAT-ORIG] (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            -- [BACKFILL-UAT-ORIG] OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        -- [BACKFILL-UAT-ORIG] )
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_column') }} fclt
        -- [BACKFILL-UAT-ORIG] ON  fclt.column_code = v.column_code
        -- [BACKFILL-UAT-ORIG] AND fclt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fclt.src_stm_code = 'IDS_RCOL'
        -- [BACKFILL-UAT-ORIG] AND fclt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fclt.column_description_reference = '1'
    -- [BACKFILL-UAT-ORIG] WHERE v.rn = 1
    -- [BACKFILL-UAT-ORIG] GROUP BY v.pc_id
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Doanh thu theo ky anchor (pc, nam, quy, fr_code); gan vao ngay o pc_financials.   -- [BACKFILL-UAT-NEW]
revenue_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        v.pc_id,   -- [BACKFILL-UAT-NEW]
        v.rpt_year,   -- [BACKFILL-UAT-NEW]
        v.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        v.fr_code,   -- [BACKFILL-UAT-NEW]
        SUM(v.data_val) AS revenue   -- [BACKFILL-UAT-NEW]
    FROM gsdc_fr_value v   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_catalog') }} fc   -- [BACKFILL-UAT-NEW]
        ON  fc.fr_catalog_id = v.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fc.fr_year = CAST(v.rpt_year AS string)   -- [BACKFILL-UAT-NEW]
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'   -- [BACKFILL-UAT-NEW]
        AND fc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)   -- [BACKFILL-UAT-NEW]
        AND fc.rpt_code LIKE 'BCKQKD%'   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_row') }} frt   -- [BACKFILL-UAT-NEW]
        ON  frt.row_code = v.row_code   -- [BACKFILL-UAT-NEW]
        AND frt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND frt.src_stm_code = 'IDS_RROW'   -- [BACKFILL-UAT-NEW]
        AND frt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND (   -- [BACKFILL-UAT-NEW]
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')   -- [BACKFILL-UAT-NEW]
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')   -- [BACKFILL-UAT-NEW]
        )   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_column') }} fclt   -- [BACKFILL-UAT-NEW]
        ON  fclt.column_code = v.column_code   -- [BACKFILL-UAT-NEW]
        AND fclt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fclt.src_stm_code = 'IDS_RCOL'   -- [BACKFILL-UAT-NEW]
        AND fclt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fclt.column_description_reference = '1'   -- [BACKFILL-UAT-NEW]
    WHERE v.rn = 1   -- [BACKFILL-UAT-NEW]
    GROUP BY v.pc_id, v.rpt_year, v.rpt_quarter, v.fr_code   -- [BACKFILL-UAT-NEW]
),   -- [BACKFILL-UAT-NEW]

-- [BACKFILL-UAT-ORIG] npat_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] v.pc_id,
        -- [BACKFILL-UAT-ORIG] SUM(v.data_val) AS net_profit_after_tax
    -- [BACKFILL-UAT-ORIG] FROM gsdc_fr_value v
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_catalog') }} fc
        -- [BACKFILL-UAT-ORIG] ON  fc.fr_catalog_id = v.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fc.fr_year = CAST(v.rpt_year AS string)
        -- [BACKFILL-UAT-ORIG] AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        -- [BACKFILL-UAT-ORIG] AND fc.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        -- [BACKFILL-UAT-ORIG] AND fc.rpt_code LIKE 'BCKQKD%'
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_row') }} frt
        -- [BACKFILL-UAT-ORIG] ON  frt.row_code = v.row_code
        -- [BACKFILL-UAT-ORIG] AND frt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND frt.src_stm_code = 'IDS_RROW'
        -- [BACKFILL-UAT-ORIG] AND frt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND (
            -- [BACKFILL-UAT-ORIG] (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            -- [BACKFILL-UAT-ORIG] OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        -- [BACKFILL-UAT-ORIG] )
    -- [BACKFILL-UAT-ORIG] INNER JOIN {{ ref('atm_fr_column') }} fclt
        -- [BACKFILL-UAT-ORIG] ON  fclt.column_code = v.column_code
        -- [BACKFILL-UAT-ORIG] AND fclt.fr_catalog_id = fc.fr_catalog_id
        -- [BACKFILL-UAT-ORIG] AND fclt.src_stm_code = 'IDS_RCOL'
        -- [BACKFILL-UAT-ORIG] AND fclt.ds_rcrd_st = 'ACTIVE'
        -- [BACKFILL-UAT-ORIG] AND fclt.column_description_reference = '1'
    -- [BACKFILL-UAT-ORIG] WHERE v.rn = 1
    -- [BACKFILL-UAT-ORIG] GROUP BY v.pc_id
-- [BACKFILL-UAT-ORIG] )
-- [BACKFILL-UAT-ONEPASS] LNST theo ky anchor (pc, nam, quy, fr_code); gan vao ngay o pc_financials.   -- [BACKFILL-UAT-NEW]
npat_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        v.pc_id,   -- [BACKFILL-UAT-NEW]
        v.rpt_year,   -- [BACKFILL-UAT-NEW]
        v.rpt_quarter,   -- [BACKFILL-UAT-NEW]
        v.fr_code,   -- [BACKFILL-UAT-NEW]
        SUM(v.data_val) AS net_profit_after_tax   -- [BACKFILL-UAT-NEW]
    FROM gsdc_fr_value v   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_catalog') }} fc   -- [BACKFILL-UAT-NEW]
        ON  fc.fr_catalog_id = v.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fc.fr_year = CAST(v.rpt_year AS string)   -- [BACKFILL-UAT-NEW]
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'   -- [BACKFILL-UAT-NEW]
        AND fc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)   -- [BACKFILL-UAT-NEW]
        AND fc.rpt_code LIKE 'BCKQKD%'   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_row') }} frt   -- [BACKFILL-UAT-NEW]
        ON  frt.row_code = v.row_code   -- [BACKFILL-UAT-NEW]
        AND frt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND frt.src_stm_code = 'IDS_RROW'   -- [BACKFILL-UAT-NEW]
        AND frt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND (   -- [BACKFILL-UAT-NEW]
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')   -- [BACKFILL-UAT-NEW]
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')   -- [BACKFILL-UAT-NEW]
        )   -- [BACKFILL-UAT-NEW]
    INNER JOIN {{ ref('atm_fr_column') }} fclt   -- [BACKFILL-UAT-NEW]
        ON  fclt.column_code = v.column_code   -- [BACKFILL-UAT-NEW]
        AND fclt.fr_catalog_id = fc.fr_catalog_id   -- [BACKFILL-UAT-NEW]
        AND fclt.src_stm_code = 'IDS_RCOL'   -- [BACKFILL-UAT-NEW]
        AND fclt.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND fclt.column_description_reference = '1'   -- [BACKFILL-UAT-NEW]
    WHERE v.rn = 1   -- [BACKFILL-UAT-NEW]
    GROUP BY v.pc_id, v.rpt_year, v.rpt_quarter, v.fr_code   -- [BACKFILL-UAT-NEW]
)   -- [BACKFILL-UAT-NEW]

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)        AS security_trading_snpst_dim_id,
    CAST(date_format(ma_pr_sn.trading_dt, 'yyyyMMdd') AS string)      AS trade_dt_dim_id,
    CAST(ma_pr_sn.symbol AS string)                                   AS instrument_code,
    CAST(ma_pr_sn.open_price AS decimal(23,2))                        AS open_price,
    CAST(ma_pr_sn.high_price AS decimal(23,2))                        AS high_price,
    CAST(ma_pr_sn.low_price AS decimal(23,2))                         AS low_price,
    CAST(ma_pr_sn.close_price AS decimal(23,2))                       AS close_price,
    CAST(ma_pr_sn.vol AS int)                                         AS vol,
    CAST(revenue_val.revenue AS decimal(23,2))                        AS revenue,
    CAST(npat_val.net_profit_after_tax AS decimal(23,2))              AS net_profit_after_tax
FROM ma_pr_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = ma_pr_sn.symbol
    AND se_tr_sn_di.ds_snpst_dt = CAST(ma_pr_sn.trading_dt AS date)   -- [FIRST-TIME 2026-10-18]
LEFT JOIN pu_co
    ON  pu_co.equity_ticker_symbol = ma_pr_sn.symbol
-- [BACKFILL-UAT-ORIG] LEFT JOIN revenue_val
    -- [BACKFILL-UAT-ORIG] ON  revenue_val.pc_id = pu_co.pc_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN npat_val
    -- [BACKFILL-UAT-ORIG] ON  npat_val.pc_id = pu_co.pc_id
LEFT JOIN gsdc_sub_anchor_d ga   -- [BACKFILL-UAT-NEW]
    ON  ga.pc_id = pu_co.pc_id   -- [BACKFILL-UAT-NEW]
    AND ga.trading_dt = CAST(ma_pr_sn.trading_dt AS date)   -- [BACKFILL-UAT-NEW]
LEFT JOIN revenue_val   -- [BACKFILL-UAT-NEW]
    ON  revenue_val.pc_id = ga.pc_id   -- [BACKFILL-UAT-NEW]
    AND revenue_val.rpt_year = ga.rpt_year   -- [BACKFILL-UAT-NEW]
    AND revenue_val.rpt_quarter = ga.rpt_quarter   -- [BACKFILL-UAT-NEW]
    AND revenue_val.fr_code = ga.fr_code   -- [BACKFILL-UAT-NEW]
LEFT JOIN npat_val   -- [BACKFILL-UAT-NEW]
    ON  npat_val.pc_id = ga.pc_id   -- [BACKFILL-UAT-NEW]
    AND npat_val.rpt_year = ga.rpt_year   -- [BACKFILL-UAT-NEW]
    AND npat_val.rpt_quarter = ga.rpt_quarter   -- [BACKFILL-UAT-NEW]
    AND npat_val.fr_code = ga.fr_code   -- [BACKFILL-UAT-NEW]
