-- [FIRST-TIME] ft_dtm_fct_sector_risk_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_sector_risk_snpst (config ft_target='fct_sector_risk_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_sector_risk_snpst
* Program name: Fact Sector Risk Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_sector_risk_snpst (giong daily tung ngay):
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_securities_trade / ft_atm_listed_share_information),
*									  BO cua so etl_date-50..etl_date va moi WHERE = etl_date; cac cua so 20 phien (Pdrawdown/Pvolatility/Pselling) va LAG nganh
*									  tinh tren TOAN BO chuoi phien (PARTITION BY ma / nganh).
*									- KLLH VSDC (oss_latest): ban ghi gan nhat <= ngay, tinh bang window LAST(... ignore nulls) tren (ma, ngay) thay cho 1 gia tri etl_date.
*									  stress_score_sector_previous_day: GIU DUNG QUY UOC DAILY - trong so von hoa cua ngay truoc dung KLLH as-of NGAY HIEN TAI
*									  (daily ap 1 oss_latest cho ca cua so), nen tinh rieng (stress_prev) tu symbol_risk_score cua ngay truoc.
*									- BCTC (no phai tra / VCSH / LNST): ky bao cao as-of THEO TUNG NGAY (submission_dt <= ngay, rn0/rn1 theo (cong ty, ngay)) giong
*									  mau ft_dtm_fct_stock_portfolio_snpst; doc fr_value mot lan cho moi ky roi noi theo ngay.
*									- se_tr_trade_day: thay dieu kien OR (HOSE symbol / HNX isin) bang UNION ALL 2 nhanh equi-join (tranh nested loop join).
*									- atm_public_company doc bang MAIN ACTIVE (danh muc, khong co ft) - HAN CHE: nganh/ticker hien tai, khong theo lich su.
*									- atm_security_match_log doc bang atomic hien huu (chua co ft_atm/ods): Pselling chi co du lieu cho cac ngay da nap match_log, ngay thieu = 0.
*									- append: ds_snpst_dt = trading_dt cua tung dong, dat CUOI SELECT.
*--------------------------------------------------------------------*
* 2026-10-28		tuan.nguyenvanb		[BA chot] K_PTTT_262/242/243 chi tinh CO PHIEU: total_trading_val_matched_sector them stock_tp_code = '2'; sts (foreign/proprietary net) them
*									floor_code IN ('02','04','10') AND stock_tp_code = '2'. Khong doi cot/kieu. Cac chi tieu khac (stress, von hoa...) giu nguyen.
* 2026-10-28		tuan.nguyenvanb		[BA chot] Co phieu KHONG co ho so cong ty (khong noi duoc atm_public_company) gom vao 'Chua phan nganh' (UNCLASSIFIED) cho K_PTTT_262/242/243:
*									se_tr_matched_sector / se_tr_trade_sector doi INNER JOIN pu_co -> LEFT JOIN + COALESCE(..., 'UNCLASSIFIED'). Khong doi cot/kieu.
*									[BA chot 2026-10-28] LNST (K_PTTT_275/244): moi cong ty lay ky bao cao GAN NHAT CO LNST (lui ve ky truoc neu ky moi nhat khong co LNST) thay vi ky nop gan nhat; sector_pe: tu so va mau so cung 1 tap ma (co LNST, gia dong cua > 0, KLLH > 0). net_profit_after_tax_amt_sector giu tong LNST cac ma co LNST. Khong doi cot/kieu.
*									[BA chot 2026-10-28] pu_co dedupe 1 ho so / ma (ROW_NUMBER PARTITION BY equity_ticker_symbol ORDER BY CAST(pc_code AS bigint) = id ho so IDS nho nhat, giong cau test BA): ma co 2 ho so ACTIVE (vd SST) khong con bi nhan doi o cac chi tieu theo nganh. Khong doi cot/kieu.
* 2026-11-09		tuan.nguyenvanb		[DOI TEN COT ATOMIC public_company theo design 2026-11-08] doc cl_ids_business_line_level_1_id/code, exchange_code, pc_form_tp_code (ten cu business_line_level_1_id/code,
*                                       equity_listing_exchange_code, pc_form_code) va giu alias ten cu o CTE nen phan con lai khong doi. Khong doi cot/kieu mart.
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr_snpst_raw AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , close_price
        , stock_tp_code
        , total_trading_val
        , total_trading_vol
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 50) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE floor_code IN ('02','04','10')
),

se_tr_snpst AS (
    SELECT symbol, trading_dt, close_price, stock_tp_code, total_trading_val, total_trading_vol
    FROM se_tr_snpst_raw
    WHERE rn = 1
),

-- [BACKFILL-UAT-NEW] truc ngay giao dich
trade_dates AS (
    SELECT DISTINCT trading_dt FROM se_tr_snpst
),

pu_co AS (
    SELECT pc_id, equity_ticker_symbol, business_line_level_1_code
    FROM (
        SELECT
            pc_id
            , equity_ticker_symbol
            , COALESCE(NULLIF(TRIM(cl_ids_business_line_level_1_code), ''), 'UNCLASSIFIED') AS business_line_level_1_code
            , ROW_NUMBER() OVER (
                PARTITION BY equity_ticker_symbol
                ORDER BY CAST(pc_code AS bigint) ASC   -- [2026-10-28 BA chot] 1 ho so / ma: id ho so IDS nho nhat (khong dung pc_id hash)
            ) AS rn_pc
        -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
        FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW] danh muc: doc bang MAIN
        -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd') AND ds_rcrd_st = 'ACTIVE' ...
        WHERE ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'IDS_COMPANY_PROFILES'
            AND equity_ticker_symbol IS NOT NULL
    ) x
    WHERE x.rn_pc = 1
),

-- ===== BCTC as-of theo ngay (no phai tra / VCSH / LNST) =====
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

pc_rpt_period AS (
    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_latest
),

-- [2026-10-28 BA chot] moi ky da duyet (rn0 = 1) theo ngay: dung cho LNST lui ve ky gan nhat co LNST
pc_rpt_period_pl AS (
    SELECT DISTINCT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_ranked
    WHERE rn0 = 1
),

fin_value_joined AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
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
        AND fc.rpt_code LIKE 'BCDKT%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
),

fin_pivot_pc AS (
    SELECT
        pc_id
        , rpt_year
        , rpt_quarter
        , fr_code
        , MAX(CASE
            WHEN (enterprise_tp_code IN ('DN','BH') AND row_description_reference = '300')
                OR (enterprise_tp_code = 'TD' AND row_description_reference = '400')
                THEN
                    CASE WHEN column_description_reference = '1' THEN cell_val END
          END) AS total_liabilities_amt
        , MAX(CASE
            WHEN (enterprise_tp_code IN ('DN','BH') AND row_description_reference = '400')
                OR (enterprise_tp_code = 'TD' AND row_description_reference = '500')
                THEN
                    CASE WHEN column_description_reference = '1' THEN cell_val END
          END) AS owner_equity_ending_amt
    FROM fin_value_joined
    GROUP BY pc_id, rpt_year, rpt_quarter, fr_code
),

sector_debt_agg AS (
    SELECT
        pu_co.business_line_level_1_code
        , l.trading_dt
        , SUM(fin_pivot_pc.total_liabilities_amt)  AS total_liabilities_sector
        , SUM(fin_pivot_pc.owner_equity_ending_amt) AS owner_equity_sector
    FROM pc_rpt_sub_latest l
    INNER JOIN pu_co
        ON pu_co.pc_id = l.pc_id
    INNER JOIN fin_pivot_pc
        ON fin_pivot_pc.pc_id = l.pc_id
        AND fin_pivot_pc.rpt_year = l.rpt_year
        AND fin_pivot_pc.rpt_quarter = l.rpt_quarter
        AND fin_pivot_pc.fr_code = l.fr_code
    GROUP BY pu_co.business_line_level_1_code, l.trading_dt
),

fin_value_joined_pl AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , s.fr_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
    FROM pc_rpt_period_pl s   -- [2026-10-28 BA chot] moi ky da duyet cua tung ngay (de lui ve ky gan nhat CO LNST)
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
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
),

fin_pivot_pl AS (
    SELECT
        pc_id
        , rpt_year
        , rpt_quarter
        , fr_code
        , MAX(CASE
            WHEN (enterprise_tp_code IN ('DN','BH') AND row_description_reference = '60')
                OR (enterprise_tp_code = 'TD' AND row_description_reference = '21')
                THEN
                    CASE WHEN column_description_reference = '1' THEN cell_val END
          END) AS net_profit_after_tax_amt
    FROM fin_value_joined_pl
    GROUP BY pc_id, rpt_year, rpt_quarter, fr_code
),

-- [2026-10-28 BA chot] ky bao cao GAN NHAT CO LNST cua tung cong ty theo (cong ty, ngay)
pl_latest AS (
    SELECT pc_id, trading_dt, net_profit_after_tax_amt
    FROM (
        SELECT
            r.pc_id
            , r.trading_dt
            , p.net_profit_after_tax_amt
            , ROW_NUMBER() OVER (
                PARTITION BY r.pc_id, r.trading_dt
                ORDER BY r.rpt_year DESC, r.rpt_quarter DESC
            ) AS rn
        FROM pc_rpt_sub_ranked r
        INNER JOIN fin_pivot_pl p
            ON p.pc_id = r.pc_id
            AND p.rpt_year = r.rpt_year
            AND p.rpt_quarter = r.rpt_quarter
            AND p.fr_code = r.fr_code
        WHERE r.rn0 = 1
            AND p.net_profit_after_tax_amt IS NOT NULL
    ) t
    WHERE rn = 1
),

-- ===== KLLH VSDC as-of (ma, ngay): ban ghi gan nhat <= ngay =====
oss_dedup AS (
    SELECT
        ticker_symbol
        , ds_snpst_dt AS from_dt
        , outstanding_share_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, ds_snpst_dt ORDER BY transaction_dt DESC) AS rn
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND ticker_symbol IN (SELECT equity_ticker_symbol FROM pu_co)
),

ticker_days AS (
    SELECT DISTINCT pu_co.equity_ticker_symbol AS ticker_symbol, td.trading_dt
    FROM pu_co
    CROSS JOIN trade_dates td
),

oss_points AS (
    SELECT ticker_symbol, from_dt AS pt_dt, 0 AS pt_ord, outstanding_share_quantity
    FROM oss_dedup
    WHERE rn = 1
    UNION ALL
    SELECT ticker_symbol, trading_dt AS pt_dt, 1 AS pt_ord, CAST(NULL AS bigint) AS outstanding_share_quantity
    FROM ticker_days
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

risk_wc_sector AS (
    SELECT risk_factor_code, weight
    FROM {{ ref('atm_risk_weight_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND risk_factor_code IN ('PDRAWDOWN','PVOLATILITY','PSELLING')
),

risk_wc_sector_scalar AS (
    SELECT
        MAX(CASE WHEN risk_factor_code = 'PDRAWDOWN' THEN weight END)   AS w1_drawdown
        , MAX(CASE WHEN risk_factor_code = 'PVOLATILITY' THEN weight END) AS w2_volatility
        , MAX(CASE WHEN risk_factor_code = 'PSELLING' THEN weight END)    AS w3_selling
    FROM risk_wc_sector
),

se_match_daily_sell AS (
    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , SUM(match_vol) AS daily_sell_vol
    FROM {{ ref('atm_security_match_log') }}
    -- [BACKFILL-UAT-ORIG] WHERE trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 50) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE trade_direction_code = 'S'
    GROUP BY ticker_symbol, trading_dt
),

-- ===== grain trung gian: 1 dong / ma CK / ngay (chua gan von hoa: trong so tinh rieng vi KLLH as-of) =====
symbol_daily AS (
    SELECT
        se_tr_snpst.symbol
        , se_tr_snpst.trading_dt
        , pu_co.business_line_level_1_code
        , se_tr_snpst.close_price
        , se_tr_snpst.stock_tp_code
        , COALESCE(se_tr_snpst.total_trading_vol, 0) AS daily_vol
        , COALESCE(se_tr_snpst.total_trading_val, 0) AS daily_val
        , COALESCE(se_match_daily_sell.daily_sell_vol, 0) AS daily_sell_vol
    FROM se_tr_snpst
    INNER JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_snpst.symbol
    LEFT JOIN se_match_daily_sell
        ON se_match_daily_sell.symbol = se_tr_snpst.symbol
        AND se_match_daily_sell.trading_dt = se_tr_snpst.trading_dt
),

symbol_window AS (
    SELECT
        symbol_daily.*
        , LAG(close_price) OVER (PARTITION BY symbol ORDER BY trading_dt)                                  AS prev_close_price
        , MAX(close_price)     OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS max_close_20d
        , SUM(daily_vol)       OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sum_vol_20d
        , SUM(daily_sell_vol)  OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sell_vol_20d
    FROM symbol_daily
),

symbol_return AS (
    SELECT
        symbol_window.*
        , LN(close_price / NULLIF(prev_close_price, 0)) AS daily_log_return
    FROM symbol_window
),

symbol_calc AS (
    SELECT
        symbol_return.*
        , STDDEV_SAMP(daily_log_return) OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sigma_20d
    FROM symbol_return
),

market_sigma AS (
    SELECT
        trading_dt
        , MIN(sigma_20d) AS sigma_min
        , MAX(sigma_20d) AS sigma_max
    FROM symbol_calc
    WHERE sigma_20d IS NOT NULL
    GROUP BY trading_dt
),

symbol_risk AS (
    SELECT
        symbol_calc.symbol
        , symbol_calc.trading_dt
        , symbol_calc.business_line_level_1_code
        , symbol_calc.close_price
        , symbol_calc.stock_tp_code
        , symbol_calc.daily_vol
        , symbol_calc.daily_val
        , CAST((symbol_calc.max_close_20d - symbol_calc.close_price) / NULLIF(symbol_calc.max_close_20d, 0) * 100 AS decimal(5,2)) AS pdrawdown_i
        , CAST(
              (symbol_calc.sigma_20d - market_sigma.sigma_min)
              / NULLIF(market_sigma.sigma_max - market_sigma.sigma_min, 0) * 100
          AS decimal(5,2))                                                                                                          AS pvolatility_i
        , CAST(symbol_calc.sell_vol_20d / NULLIF(symbol_calc.sum_vol_20d, 0) * 100 AS decimal(5,2))                                 AS pselling_i
    FROM symbol_calc
    LEFT JOIN market_sigma
        ON market_sigma.trading_dt = symbol_calc.trading_dt
),

symbol_risk_score AS (
    SELECT
        symbol_risk.*
        , CAST(
              COALESCE(risk_wc_sector_scalar.w1_drawdown, 0)   * COALESCE(symbol_risk.pdrawdown_i, 0)
            + COALESCE(risk_wc_sector_scalar.w2_volatility, 0) * COALESCE(symbol_risk.pvolatility_i, 0)
            + COALESCE(risk_wc_sector_scalar.w3_selling, 0)    * COALESCE(symbol_risk.pselling_i, 0)
          AS decimal(5,2)) AS stress_score_i
    FROM symbol_risk
    CROSS JOIN risk_wc_sector_scalar
),

-- [BACKFILL-UAT-NEW] von hoa = close_price (ngay cua dong) x KLLH as-of NGAY CUA DONG
symbol_mcap AS (
    SELECT
        symbol_risk_score.*
        , symbol_risk_score.close_price * COALESCE(oss_asof.outstanding_share_quantity, 0) AS market_cap
    FROM symbol_risk_score
    LEFT JOIN oss_asof
        ON oss_asof.ticker_symbol = symbol_risk_score.symbol
        AND oss_asof.trading_dt = symbol_risk_score.trading_dt
),

sector_day_agg AS (
    SELECT
        symbol_mcap.business_line_level_1_code
        , symbol_mcap.trading_dt
        , SUM(CASE WHEN symbol_mcap.stock_tp_code = '2' THEN symbol_mcap.daily_val END)   AS total_val_sector
        , SUM(symbol_mcap.market_cap)                                     AS total_market_cap_sector
        , SUM(CASE WHEN symbol_mcap.stock_tp_code = '2' THEN symbol_mcap.market_cap END) AS total_market_cap_sector_stock
        , SUM(symbol_mcap.stress_score_i * symbol_mcap.market_cap)
            / NULLIF(SUM(symbol_mcap.market_cap), 0)                      AS stress_score_sector_raw
    FROM symbol_mcap
    GROUP BY symbol_mcap.business_line_level_1_code, symbol_mcap.trading_dt
),

-- nganh/ngay va ngay truoc cua chinh nganh do (daily: LAG 1 buoc PARTITION BY nganh)
sector_days AS (
    SELECT
        business_line_level_1_code
        , trading_dt
        , LAG(trading_dt) OVER (PARTITION BY business_line_level_1_code ORDER BY trading_dt) AS prev_dt
    FROM sector_day_agg
),

-- stress_score_sector cua ngay truoc, trong so von hoa dung KLLH as-of NGAY HIEN TAI (quy uoc daily: 1 oss_latest cho ca cua so)
stress_prev AS (
    SELECT
        sd.business_line_level_1_code
        , sd.trading_dt
        , SUM(s.stress_score_i * s.close_price * COALESCE(o.outstanding_share_quantity, 0))
            / NULLIF(SUM(s.close_price * COALESCE(o.outstanding_share_quantity, 0)), 0) AS stress_score_sector_previous_day_raw
    FROM sector_days sd
    INNER JOIN symbol_risk_score s
        ON s.business_line_level_1_code = sd.business_line_level_1_code
        AND s.trading_dt = sd.prev_dt
    LEFT JOIN oss_asof o
        ON o.ticker_symbol = s.symbol
        AND o.trading_dt = sd.trading_dt
    GROUP BY sd.business_line_level_1_code, sd.trading_dt
),

sector_stress_lag AS (
    SELECT
        sector_day_agg.*
        , CAST(sector_day_agg.stress_score_sector_raw AS decimal(5,2)) AS stress_score_sector
        , CAST(stress_prev.stress_score_sector_previous_day_raw AS decimal(5,2)) AS stress_score_sector_previous_day
    FROM sector_day_agg
    LEFT JOIN stress_prev
        ON stress_prev.business_line_level_1_code = sector_day_agg.business_line_level_1_code
        AND stress_prev.trading_dt = sector_day_agg.trading_dt
),

se_tr_matched_sector AS (
    SELECT
        COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED') AS business_line_level_1_code   -- [2026-10-28 BA chot] co phieu khong co ho so cong ty -> Chua phan nganh
        , se_tr_snpst.trading_dt
        , SUM(se_tr_snpst.total_trading_val) AS total_trading_val_matched_sector
    FROM se_tr_snpst
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_snpst.symbol
    -- [BACKFILL-UAT-ORIG] WHERE se_tr_snpst.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE se_tr_snpst.stock_tp_code = '2'   -- [2026-10-28 BA chot] chi lay CO PHIEU (bo chung quyen, chung chi quy, trai phieu)
    GROUP BY COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED'), se_tr_snpst.trading_dt
),

sts_raw AS (
    SELECT
        ticker_symbol AS symbol
        , isin_code
        , ds_snpst_dt AS trading_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE floor_code IN ('02','04','10')   -- [2026-10-28 BA chot] foreign/proprietary net chi tinh CO PHIEU san 02/04/10
        AND stock_tp_code = '2'
),

sts AS (
    SELECT symbol, isin_code, trading_dt
    FROM sts_raw
    WHERE rn = 1
),

se_tr AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , execution_vol
        , execution_price
        , buy_account_nbr
        , sell_account_nbr
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE se_tr.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code IN ('STK','STO','STX','UPX')
),

-- [BACKFILL-UAT-NEW] daily: ON (HOSE AND sts.symbol = code) OR (HNX AND sts.isin_code = code) -> 2 nhanh equi-join (tranh nested loop)
se_tr_trade_day AS (
    SELECT
        sts.symbol
        , sts.trading_dt AS trade_dt
        , se_tr.execution_vol
        , se_tr.execution_price
        , se_tr.buy_account_nbr
        , se_tr.sell_account_nbr
    FROM se_tr
    INNER JOIN sts
        ON sts.trading_dt = se_tr.trade_dt
        AND sts.symbol = se_tr.security_symbol_code
    WHERE se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'
    UNION ALL
    SELECT
        sts.symbol
        , sts.trading_dt AS trade_dt
        , se_tr.execution_vol
        , se_tr.execution_price
        , se_tr.buy_account_nbr
        , se_tr.sell_account_nbr
    FROM se_tr
    INNER JOIN sts
        ON sts.trading_dt = se_tr.trade_dt
        AND sts.isin_code = se_tr.security_symbol_code
    WHERE se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
),

se_tr_trade_sector AS (
    SELECT
        COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED') AS business_line_level_1_code   -- [2026-10-28 BA chot] co phieu khong co ho so cong ty -> Chua phan nganh
        , se_tr_trade_day.trade_dt
        , SUM(CASE WHEN SUBSTR(se_tr_trade_day.buy_account_nbr, 4, 1) IN ('E','F')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)
          - SUM(CASE WHEN SUBSTR(se_tr_trade_day.sell_account_nbr, 4, 1) IN ('E','F')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)  AS foreign_net_val_sector
        , SUM(CASE WHEN SUBSTR(se_tr_trade_day.buy_account_nbr, 4, 1) IN ('A','E','P')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)
          - SUM(CASE WHEN SUBSTR(se_tr_trade_day.sell_account_nbr, 4, 1) IN ('A','E','P')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)   AS proprietary_net_val_sector
    FROM se_tr_trade_day
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_trade_day.symbol
    GROUP BY COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED'), se_tr_trade_day.trade_dt
),

oss_by_sector AS (
    SELECT
        pu_co.business_line_level_1_code
        , oss_asof.trading_dt
        , SUM(oss_asof.outstanding_share_quantity) AS total_outstanding_share_quantity_sector
    FROM pu_co
    INNER JOIN oss_asof
        ON oss_asof.ticker_symbol = pu_co.equity_ticker_symbol
    WHERE oss_asof.outstanding_share_quantity IS NOT NULL
    GROUP BY pu_co.business_line_level_1_code, oss_asof.trading_dt
),

threshold_stress_score AS (
    SELECT
        from_value
        , to_value
        , status AS sector_rating
    FROM {{ ref('atm_status_threshold_config') }}
    WHERE index_code = 'STRESS_SCORE'
        AND ds_rcrd_st = 'ACTIVE'
),

se_tr_pe AS (
    SELECT
        symbol
        , trading_dt
        , close_price
    FROM se_tr_snpst
),

sector_pl_agg AS (
    SELECT
        pu_co.business_line_level_1_code
        , l.trading_dt
        , SUM(l.net_profit_after_tax_amt)                        AS net_profit_after_tax_amt_sector
        , SUM(CASE WHEN l.net_profit_after_tax_amt IS NOT NULL
                    AND se_tr_pe.close_price > 0 AND oss_asof.outstanding_share_quantity > 0
                   THEN se_tr_pe.close_price * oss_asof.outstanding_share_quantity END) AS sector_pe_numerator
        , SUM(CASE WHEN se_tr_pe.close_price > 0 AND oss_asof.outstanding_share_quantity > 0
                   THEN l.net_profit_after_tax_amt END) AS sector_pe_denominator
    FROM pl_latest l
    INNER JOIN pu_co
        ON pu_co.pc_id = l.pc_id
    LEFT JOIN oss_asof
        ON oss_asof.ticker_symbol = pu_co.equity_ticker_symbol
        AND oss_asof.trading_dt = l.trading_dt
    LEFT JOIN se_tr_pe
        ON se_tr_pe.symbol = pu_co.equity_ticker_symbol
        AND se_tr_pe.trading_dt = l.trading_dt
    GROUP BY pu_co.business_line_level_1_code, l.trading_dt
)

SELECT
    CAST(date_format(sector_stress_lag.trading_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(sc.sector_dim_id AS string)                                          AS industry_dim_id,
    CAST(sector_stress_lag.total_val_sector AS decimal(23,2))                 AS total_val_sector,
    CAST(sector_stress_lag.total_market_cap_sector AS decimal(23,2))          AS total_market_cap_sector,
    CAST(sector_stress_lag.stress_score_sector AS decimal(5,2))               AS stress_score_sector,
    CAST(
        sector_stress_lag.total_val_sector / NULLIF(sector_stress_lag.total_market_cap_sector_stock, 0)
    AS decimal(38,20))                                                          AS sector_liquid_score,
    CAST(sector_stress_lag.stress_score_sector_previous_day AS decimal(5,2))  AS stress_score_sector_previous_day,
    CAST(
        sector_stress_lag.stress_score_sector - sector_stress_lag.stress_score_sector_previous_day
    AS decimal(5,2))                                                          AS sector_stress_delta,
    CAST(threshold_stress_score.sector_rating AS string)                      AS sector_rating,
    CAST(
        sector_debt_agg.total_liabilities_sector / NULLIF(sector_debt_agg.owner_equity_sector, 0)
    AS decimal(8,4))                                                          AS sector_debt_score,
    CAST(se_tr_matched_sector.total_trading_val_matched_sector AS decimal(23,2)) AS total_trading_val_matched_sector,
    CAST(se_tr_trade_sector.foreign_net_val_sector AS decimal(23,2))          AS foreign_net_val_sector,
    CAST(se_tr_trade_sector.proprietary_net_val_sector AS decimal(23,2))      AS proprietary_net_val_sector,
    CAST(oss_by_sector.total_outstanding_share_quantity_sector AS bigint)     AS total_outstanding_share_quantity_sector,
    CAST(sector_pl_agg.net_profit_after_tax_amt_sector AS decimal(23,2))      AS net_profit_after_tax_amt_sector,
    CAST(
        ROUND(sector_pl_agg.sector_pe_numerator / NULLIF(sector_pl_agg.sector_pe_denominator, 0), 2)
    AS decimal(10,2))                                                        AS sector_pe,
    CAST(sector_stress_lag.trading_dt AS date)                                AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM sector_stress_lag
LEFT JOIN {{ ref('dtm_sector_dim') }} sc
    ON sc.industry_code = sector_stress_lag.business_line_level_1_code
    AND sc.ds_rcrd_st = 'ACTIVE'
LEFT JOIN se_tr_matched_sector
    ON se_tr_matched_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
    AND se_tr_matched_sector.trading_dt = sector_stress_lag.trading_dt
LEFT JOIN se_tr_trade_sector
    ON se_tr_trade_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
    AND se_tr_trade_sector.trade_dt = sector_stress_lag.trading_dt
LEFT JOIN oss_by_sector
    ON oss_by_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
    AND oss_by_sector.trading_dt = sector_stress_lag.trading_dt
LEFT JOIN sector_debt_agg
    ON sector_debt_agg.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
    AND sector_debt_agg.trading_dt = sector_stress_lag.trading_dt
LEFT JOIN sector_pl_agg
    ON sector_pl_agg.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
    AND sector_pl_agg.trading_dt = sector_stress_lag.trading_dt
LEFT JOIN threshold_stress_score
    ON sector_stress_lag.stress_score_sector
        BETWEEN CAST(threshold_stress_score.from_value AS decimal(5,2))
            AND CAST(threshold_stress_score.to_value AS decimal(5,2))
-- [BACKFILL-UAT-ORIG] WHERE sector_stress_lag.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
