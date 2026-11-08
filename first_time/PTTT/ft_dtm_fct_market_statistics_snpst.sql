-- [FIRST-TIME] ft_dtm_fct_market_statistics_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_market_statistics_snpst (config ft_target='fct_market_statistics_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_statistics_snpst
* Program name: Fact Market Statistics Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_market_statistics_snpst (giong daily tung ngay):
*									- doc atomic qua ft_ref (ft_atm_market_index_snapshot / ft_atm_index_constituent_snapshot / ft_atm_securities_trade /
*									  ft_atm_security_trading_snapshot / ft_atm_listed_share_information), BO cac cua so etl_date-80..etl_date va moi WHERE = etl_date.
*									- LAG / AVG 50 phien tinh tren TOAN BO chuoi phien (PARTITION BY market_code), cho ket qua tung ngay giong daily (daily dung cua so 80 ngay, du 50 phien).
*									- KLLH VSDC (oss): ban ghi gan nhat <= ngay -> as-of (ma, ngay) bang window LAST(... ignore nulls) (tuong duong khoang hieu luc, khong range join).
*									- LNST: ky bao cao as-of THEO TUNG NGAY (chi xet submission_dt <= ngay, rn0/rn1 theo (cong ty, ngay)) giong mau ft_dtm_fct_stock_portfolio_snpst;
*									  atm_public_company doc bang MAIN ACTIVE (danh muc, khong co ft) - HAN CHE: ma/ticker hien tai.
*									- sts_today: ban tin cuoi ngay moi ma theo (ma, ngay).
*									- append: ds_snpst_dt = trading_dt cua tung dong, dat CUOI SELECT.
*--------------------------------------------------------------------*
*									[BA chot 2026-10-28] Chieu chi so: chi tinh CO PHIEU (stock_tp_code='2', san 02/04/10), toan thi truong, KHONG loc board: bo board_tp_code IN (G1,G2,G3,G4,G7,G8) o tr_hist; ro thanh phan (idx_constituent_hist / idx_constituent_today) chi giu ma la co phieu qua stk_day. Khong doi cot/kieu -> build lai mart + flat.
*									[BA chot 2026-10-28] LNST (K_PTTT_234/233/235): moi cong ty lay ky bao cao GAN NHAT CO LNST (lui ve ky truoc neu ky moi nhat khong co LNST); idx_pe: tu so va mau so cung 1 tap ma (co LNST, gia dong cua > 0, KLLH > 0). Khong doi cot/kieu.
*									[FIX 2026-10-28] KLGD/GTGD (K_PTTT_229/237/238) cua chi so HNX/HNX30/HNXCon/HNXFin/HNXLCap/HNXMSCap/HNXMan/UPCOM = 0: so lenh HNX co security_symbol_code = ISIN (Issue_Code) nhung truoc day noi theo ticker. Nay noi 2 nhanh: HOSE theo ticker, HNX theo isin_code cua ma thanh phan (lay tu stk_day), giong sector_risk. Khong doi cot/kieu -> build lai mart + flat.
*									[FIX 2026-10-29] Ro thanh phan (idx_constituent_hist / idx_constituent_today) dung SELECT DISTINCT (chi so, ma, ngay): atm_index_constituent_snapshot co ma lap 2 dong cung ngay (UPCOM 07-20..08-20: AAV, CVN, DDG, KSQ, PCG, SDA, VE8) nen GTGD/KLGD, KLLH, LNST bi cong doi; K_PTTT_238 UPCOM lech 79,6 ty. Khong doi cot/kieu -> build lai mart + flat.
*									[2026-10-29] Dedupe ro thanh phan giong GSTT (dtm_fct_investor_category_index_trading_snpst.ics_dedup): SELECT DISTINCT (ro, ma, ngay) + loc src_stm_code = 'MDDS_JAD_CSIDXINFOR'. Khong doi cot/kieu.
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH idx_snpst_all AS (
    SELECT
        trading_dt
        , market_code
        , market_index_val
        , ROW_NUMBER() OVER (
            PARTITION BY market_id, market_code, trading_dt
            ORDER BY index_time DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
    -- [BACKFILL-UAT-ORIG]     AND trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 80) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

idx_snpst_hist AS (
    SELECT
        trading_dt
        , market_code
        , market_index_val
    FROM idx_snpst_all
    WHERE rn = 1
),

-- [BACKFILL-UAT-NEW] truc ngay giao dich (dung cho as-of LNST)
trade_dates AS (
    SELECT DISTINCT trading_dt FROM idx_snpst_hist
),

-- [BA chot 2026-10-28] chieu chi so chi tinh CO PHIEU: ma la co phieu (stock_tp_code = '2', san 02/04/10) theo (ma, ngay)
stk_day AS (
    SELECT
        ticker_symbol
        , trading_dt
        , MAX(isin_code) AS isin_code
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE floor_code IN ('02','04','10')
        AND stock_tp_code = '2'
    GROUP BY ticker_symbol, trading_dt
),

-- [2026-10-29] 1 dong / (ro, ma, ngay) - csidxinfor co the co nhieu ban tin cho cung 1 thanh vien (giong GSTT: DISTINCT + src_stm_code = 'MDDS_JAD_CSIDXINFOR')
idx_constituent_hist AS (
    SELECT DISTINCT
        c.trading_dt
        , c.index_code
        , c.ticker_symbol AS symbol
        , stk_day.isin_code
    FROM {{ ft_ref('ft_atm_index_constituent_snapshot') }} c   -- [BACKFILL-UAT-NEW] ft_ref
    INNER JOIN stk_day
        ON stk_day.ticker_symbol = c.ticker_symbol
        AND stk_day.trading_dt = c.trading_dt
    WHERE c.src_stm_code = 'MDDS_JAD_CSIDXINFOR'
    -- [BACKFILL-UAT-ORIG] WHERE trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 80) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

tr_hist AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , execution_vol
        , execution_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 80) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code IN ('STK','STO','STX','UPX')
),

constituent_trade AS (
    -- [FIX 2026-10-28] HOSE: so lenh theo ticker; HNX/UPCOM: so lenh theo ISIN (Issue_Code) - 2 nhanh equi-join, khong dung OR
    SELECT
        idx_constituent_hist.trading_dt
        , idx_constituent_hist.index_code
        , tr_hist.execution_vol
        , tr_hist.execution_val
    FROM idx_constituent_hist
    INNER JOIN tr_hist
        ON tr_hist.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'
        AND tr_hist.security_symbol_code = idx_constituent_hist.symbol
        AND tr_hist.trade_dt = idx_constituent_hist.trading_dt
    UNION ALL
    SELECT
        idx_constituent_hist.trading_dt
        , idx_constituent_hist.index_code
        , tr_hist.execution_vol
        , tr_hist.execution_val
    FROM idx_constituent_hist
    INNER JOIN tr_hist
        ON tr_hist.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
        AND tr_hist.security_symbol_code = idx_constituent_hist.isin_code
        AND tr_hist.trade_dt = idx_constituent_hist.trading_dt
),

agg_by_index_day AS (
    SELECT
        constituent_trade.trading_dt
        , constituent_trade.index_code AS market_code
        , SUM(constituent_trade.execution_vol) AS total_trading_vol_matched
        , SUM(constituent_trade.execution_val) AS total_trading_val_matched
    FROM constituent_trade
    GROUP BY
        constituent_trade.trading_dt
        , constituent_trade.index_code
),

idx_with_agg AS (
    SELECT
        idx_snpst_hist.trading_dt
        , idx_snpst_hist.market_code
        , idx_snpst_hist.market_index_val
        , COALESCE(agg_by_index_day.total_trading_vol_matched, 0) AS total_trading_vol_matched
        , COALESCE(agg_by_index_day.total_trading_val_matched, 0) AS total_trading_val_matched
    FROM idx_snpst_hist
    LEFT JOIN agg_by_index_day
        ON agg_by_index_day.market_code = idx_snpst_hist.market_code
        AND agg_by_index_day.trading_dt = idx_snpst_hist.trading_dt
),

windowed AS (
    SELECT
        idx_with_agg.*
        , LAG(idx_with_agg.market_index_val) OVER (
            PARTITION BY idx_with_agg.market_code
            ORDER BY idx_with_agg.trading_dt
        ) AS close_price_previous_day
        , AVG(idx_with_agg.total_trading_val_matched) OVER (
            PARTITION BY idx_with_agg.market_code
            ORDER BY idx_with_agg.trading_dt
            ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS total_trading_val_matched_average_50_days
    FROM idx_with_agg
),

-- [BACKFILL-UAT-NEW] KLLH VSDC gan nhat <= ngay: dedupe (ma, ds_snpst_dt) roi as-of bang window ben duoi
oss_dedup AS (
    SELECT
        ticker_symbol
        , ds_snpst_dt AS from_dt
        , outstanding_share_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, ds_snpst_dt ORDER BY transaction_dt DESC) AS rn
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

-- as-of (ma, ngay) bang window LAST(... ignore nulls) thay vi range join (tranh tich ma x khoang hieu luc)
constituent_symbol_days AS (
    SELECT DISTINCT symbol AS ticker_symbol, trading_dt FROM idx_constituent_hist
),

oss_points AS (
    SELECT ticker_symbol, from_dt AS pt_dt, 0 AS pt_ord, outstanding_share_quantity
    FROM oss_dedup
    WHERE rn = 1
        AND ticker_symbol IN (SELECT ticker_symbol FROM constituent_symbol_days)
    UNION ALL
    SELECT ticker_symbol, trading_dt AS pt_dt, 1 AS pt_ord, CAST(NULL AS bigint) AS outstanding_share_quantity
    FROM constituent_symbol_days
),

oss_asof AS (
    SELECT ticker_symbol, pt_dt AS trading_dt, outstanding_share_quantity
    FROM (
        SELECT
            ticker_symbol
            , pt_dt
            , pt_ord
            , LAST(outstanding_share_quantity, true) OVER (
                PARTITION BY ticker_symbol
                ORDER BY pt_dt, pt_ord
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
              ) AS outstanding_share_quantity
        FROM oss_points
    ) x
    WHERE pt_ord = 1
),

-- [BACKFILL-UAT-NEW] thanh phan ro chi so theo ngay (daily: idx_constituent_today) + KLLH as-of ngay
idx_constituent_oss AS (
    SELECT
        idx_constituent_hist.trading_dt
        , idx_constituent_hist.index_code
        , idx_constituent_hist.symbol
        , oss_asof.outstanding_share_quantity
    FROM idx_constituent_hist
    LEFT JOIN oss_asof
        ON oss_asof.ticker_symbol = idx_constituent_hist.symbol
        AND oss_asof.trading_dt = idx_constituent_hist.trading_dt
),

oss_by_index AS (
    SELECT
        idx_constituent_oss.trading_dt
        , idx_constituent_oss.index_code AS market_code
        , SUM(idx_constituent_oss.outstanding_share_quantity) AS total_outstanding_share_quantity
    FROM idx_constituent_oss
    WHERE idx_constituent_oss.outstanding_share_quantity IS NOT NULL
    GROUP BY idx_constituent_oss.trading_dt, idx_constituent_oss.index_code
),

-- LNST theo ma CK: ky bao cao as-of TUNG NGAY (chi xet submission_dt <= ngay)
pc_rpt_sub_ranked AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , td.trading_dt
        , ROW_NUMBER() OVER (
            PARTITION BY s.pc_id, s.rpt_year, s.rpt_quarter, td.trading_dt
            ORDER BY
                CASE SUBSTR(s.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , s.submission_dt DESC
        ) AS rn0
    FROM {{ ref('atm_pc_report_submission') }} s
    INNER JOIN trade_dates td
        ON s.submission_dt <= td.trading_dt   -- [BACKFILL-UAT-NEW] as-of theo ngay (daily: submission_dt <= etl_date)
    WHERE s.ds_rcrd_st = 'ACTIVE'
        AND s.approval_status_code = 'APPROVED'
        AND SUBSTR(s.fr_code,1,2) IN ('HN','TH','ME','RI')
        AND s.rpt_quarter IN (1,2,3,4)
),

pc_rpt_sub_latest AS (
    SELECT pc_id, trading_dt, rpt_year, rpt_quarter, fr_code
    FROM (
        SELECT
            r.*
            , ROW_NUMBER() OVER (
                PARTITION BY r.pc_id, r.trading_dt
                ORDER BY r.rpt_year DESC, r.rpt_quarter DESC
            ) AS rn1
        FROM pc_rpt_sub_ranked r
        WHERE r.rn0 = 1
    ) t
    WHERE rn1 = 1
),

-- cac ky phan biet (doc fr_value mot lan cho moi ky, khong lap theo ngay)
pc_rpt_period AS (
    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_ranked   -- [2026-10-28 BA chot] moi ky da duyet theo ngay (rn0 = 1) de lui ve ky gan nhat CO LNST
    WHERE rn0 = 1
),

lnst_period AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , SUM(fv.cell_val) AS lnst
    FROM pc_rpt_period s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.fr_code
),

pu_co AS (
    SELECT pc_id, equity_ticker_symbol
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW] danh muc: doc bang MAIN
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd') AND ds_rcrd_st = 'ACTIVE' AND src_stm_code = 'IDS_COMPANY_PROFILES'
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

-- [2026-10-28 BA chot] ky bao cao GAN NHAT CO LNST cua tung cong ty theo (cong ty, ngay)
lnst_by_pc_day AS (
    SELECT pc_id, trading_dt, lnst
    FROM (
        SELECT
            r.pc_id
            , r.trading_dt
            , lp.lnst
            , ROW_NUMBER() OVER (
                PARTITION BY r.pc_id, r.trading_dt
                ORDER BY r.rpt_year DESC, r.rpt_quarter DESC
            ) AS rn
        FROM pc_rpt_sub_ranked r
        INNER JOIN lnst_period lp
            ON lp.pc_id = r.pc_id
            AND lp.rpt_year = r.rpt_year
            AND lp.rpt_quarter = r.rpt_quarter
            AND lp.fr_code = r.fr_code
        WHERE r.rn0 = 1
            AND lp.lnst IS NOT NULL
    ) t
    WHERE rn = 1
),

lnst_by_symbol AS (
    SELECT
        l.trading_dt
        , pu_co.equity_ticker_symbol AS symbol
        , SUM(l.lnst) AS lnst
    FROM lnst_by_pc_day l
    INNER JOIN pu_co
        ON pu_co.pc_id = l.pc_id
    GROUP BY l.trading_dt, pu_co.equity_ticker_symbol
),

-- ban tin cuoi ngay moi ma theo (ma, ngay)
sts_today_raw AS (
    SELECT
        ticker_symbol
        , trading_dt
        , close_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE floor_code IN ('02','04','10')
),

sts_today AS (
    SELECT ticker_symbol, trading_dt, close_price
    FROM sts_today_raw
    WHERE rn = 1
),

lnst_and_cp_by_index AS (
    SELECT
        idx_constituent_oss.trading_dt
        , idx_constituent_oss.index_code AS market_code
        , SUM(lnst_by_symbol.lnst) AS net_profit_after_tax_amt
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL THEN idx_constituent_oss.outstanding_share_quantity END) AS eps_denominator_share_quantity
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL AND security_trading_snapshot.close_price > 0 AND idx_constituent_oss.outstanding_share_quantity > 0
                   THEN security_trading_snapshot.close_price * idx_constituent_oss.outstanding_share_quantity END) AS pe_numerator_market_cap
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL AND security_trading_snapshot.close_price > 0 AND idx_constituent_oss.outstanding_share_quantity > 0
                   THEN lnst_by_symbol.lnst END) AS pe_denominator_net_profit
    FROM idx_constituent_oss
    LEFT JOIN lnst_by_symbol
        ON lnst_by_symbol.symbol = idx_constituent_oss.symbol
        AND lnst_by_symbol.trading_dt = idx_constituent_oss.trading_dt
    LEFT JOIN sts_today security_trading_snapshot
        ON security_trading_snapshot.ticker_symbol = idx_constituent_oss.symbol
        AND security_trading_snapshot.trading_dt = idx_constituent_oss.trading_dt
    GROUP BY idx_constituent_oss.trading_dt, idx_constituent_oss.index_code
)

SELECT
    CAST(date_format(windowed.trading_dt, 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(windowed.market_code AS string)                                AS market_code,
    CAST(windowed.total_trading_vol_matched AS decimal(23,2))           AS total_trading_vol_matched,
    CAST(windowed.market_index_val AS decimal(23,2))                    AS close_price,
    CAST(windowed.close_price_previous_day AS decimal(23,2))            AS close_price_previous_day,
    CAST(
        (windowed.market_index_val - windowed.close_price_previous_day)
        / NULLIF(windowed.close_price_previous_day, 0) * 100
    AS decimal(5,2))                                                    AS price_change_percentage,
    CAST(windowed.total_trading_val_matched AS decimal(23,2))           AS total_trading_val_matched,
    CAST(windowed.total_trading_val_matched_average_50_days AS decimal(23,2)) AS total_trading_val_matched_average_50_days,
    CAST(oss_by_index.total_outstanding_share_quantity AS bigint)       AS total_outstanding_share_quantity,
    CAST(lnst_and_cp_by_index.net_profit_after_tax_amt AS decimal(23,2)) AS net_profit_after_tax_amt,
    CAST(
        lnst_and_cp_by_index.net_profit_after_tax_amt
        / NULLIF(lnst_and_cp_by_index.eps_denominator_share_quantity, 0)
    AS decimal(23,2))                                                   AS idx_eps,
    CAST(
        ROUND(
            lnst_and_cp_by_index.pe_numerator_market_cap
            / NULLIF(lnst_and_cp_by_index.pe_denominator_net_profit, 0)
        , 2)
    AS decimal(10,2))                                                   AS idx_pe,
    CAST(windowed.trading_dt AS date)                                   AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM windowed
LEFT JOIN oss_by_index
    ON oss_by_index.market_code = windowed.market_code
    AND oss_by_index.trading_dt = windowed.trading_dt
LEFT JOIN lnst_and_cp_by_index
    ON lnst_and_cp_by_index.market_code = windowed.market_code
    AND lnst_and_cp_by_index.trading_dt = windowed.trading_dt
-- [BACKFILL-UAT-ORIG] WHERE windowed.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
