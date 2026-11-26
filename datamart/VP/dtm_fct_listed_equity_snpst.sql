/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_listed_equity_snpst
* Program name: Dtm Fct Listed Equity Snapshot
* Created by: huy.pham
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-10-29      huy.pham        [MOI, theo LLD DTM_VP_fct_listed_equity_snpst.csv]
*                                 Fact snapshot co phieu / chung chi quy niem yet cuoi
*                                 ngay. Grain = 1 ma (stock_tp_code 2/3/6) / ngay GD
*                                 (MDDS MDDS_JAD_STOCKINFOR, floor_code IN 02/04/10).
*                                 Von hoa chi tinh cho co phieu (stock_tp_code='2');
*                                 UPCoM (floor_code='04') dung VWAP thay close_price
*                                 (VWAP=0 -> reference_price). Khoi luong luu hanh:
*                                 VSDC_OUTSTANDING_SHARES theo dung ngay GD (O_VP_40).
*                                 vol_weighted_average_price: ten cot chinh xac da xac nhan.
* 2026-11-08      huy.pham        [SUA] Doi ve daily: loc trading_dt IN (D, D-1), dung
*                                 nxt_all/nxt lay VWAP(D) dien vao dong D-1. Moi ETL
*                                 ghi 2 partition: D (null UPCoM) va D-1 (day du).
*                                 append dynamic overwrite tren Spark overwrite ca 2.
*                                 CK flat dung ck_snapshot (ds_snpst_dt=etl_date),
*                                 khai thac WHERE ds_snpst_dt = max(ds_snpst_dt).
*                                 Full history (LEAD) active khi can full load, chuyen
*                                 ve daily sau khi load xong.
* 2026-11-16		claude			[SUA, O_VP_80] listed_share_val: doi ELSE
*                                 listed_share_count * 10000 sang WHEN
*                                 stock_tp_code IN ('2','3','6') THEN * 10000
*                                 ELSE NULL — loai chung quyen ('4') khoi nhom
*                                 menh gia 10000, de trong theo dung LLD BA
*                                 Nhom 17 dong 184 cap nhat 2026-11-16.
* 2026-11-09      huy.pham        [SUA, O_VP_66, O_VP_68] Mo rong: them stock_tp_code
*                                 '1' (TPDN niem yet) va '4' (chung quyen); doi filter
*                                 floor_code IN ('02','04','10') -> <> '03'. Them 2 cot:
*                                 fund_tp_code (tu MDDS), industry_dim_id (co phieu:
*                                 JOIN pub_company/SC/FMC -> LOOKUP dtm_industry_dim;
*                                 O_VP_66). Cap nhat listed_share_val: stock_tp_code='1'
*                                 dung KL * 100000 * 10^ROUND(LOG10(ref/100000)),
*                                 con lai KL * 10000 (O_VP_68).
*--------------------------------------------------------------------*
*/

-- [ACTIVE: FULL HISTORY] Chuyen ve khoi DAILY phia duoi sau khi full load xong
WITH sn_all AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        close_price,
        reference_price,
        listed_share_count,
        vol_weighted_average_price,
        trading_time,
        sequence,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code IN ('1', '2', '3', '4', '6')
        AND floor_code <> '03'
),

sn AS (
    SELECT ticker_symbol, trading_dt, floor_code, stock_tp_code, fund_tp_code,
           close_price, reference_price, listed_share_count, vol_weighted_average_price, src_stm_code
    FROM sn_all
    WHERE rn = 1
),

sn_with_nxt AS (
    SELECT
        *,
        -- LEAD lay VWAP cua ngay GD ke tiep cung ticker
        -- dong cuoi cung (moi nhat) → nxt_vwap = NULL → UPCoM market_price = NULL
        LEAD(vol_weighted_average_price) OVER (
            PARTITION BY ticker_symbol
            ORDER BY trading_dt
        ) AS nxt_vwap
    FROM sn
),

pc_all AS (
    SELECT
        equity_ticker_symbol,
        business_line_level_1_code,
        ROW_NUMBER() OVER (
            PARTITION BY equity_ticker_symbol
            ORDER BY CAST(public_company_code AS bigint) ASC
        ) AS rn
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-09-02','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc AS (
    SELECT equity_ticker_symbol, business_line_level_1_code
    FROM pc_all
    WHERE rn = 1
),

sc AS (
    SELECT DISTINCT securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-10-15','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

lsi AS (
    SELECT ticker_symbol, outstanding_share_quantity, transaction_dt
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

joined AS (
    SELECT
        sw.ticker_symbol,
        sw.trading_dt,
        sw.floor_code,
        sw.stock_tp_code,
        sw.fund_tp_code,
        sw.close_price,
        sw.reference_price,
        sw.listed_share_count,
        sw.src_stm_code,
        lsi.outstanding_share_quantity,
        sw.nxt_vwap,
        CASE
            WHEN sw.floor_code = '04' THEN
                CASE WHEN sw.nxt_vwap IS NULL THEN NULL
                     ELSE COALESCE(NULLIF(sw.nxt_vwap, 0), sw.reference_price)
                END
            ELSE sw.close_price
        END                                                        AS market_price_calc,
        CASE WHEN sw.stock_tp_code = '2' THEN
            CASE
                WHEN sc.securities_code IS NOT NULL
                     OR fmc.stock_ticker_code IS NOT NULL THEN '07000'
                ELSE pc.business_line_level_1_code
            END
        END                                                        AS industry_code_calc
    FROM sn_with_nxt sw
    LEFT JOIN pc
        ON  pc.equity_ticker_symbol = sw.ticker_symbol
    LEFT JOIN sc
        ON  sc.securities_code = sw.ticker_symbol
    LEFT JOIN fmc
        ON  fmc.stock_ticker_code = sw.ticker_symbol
    LEFT JOIN lsi
        ON  lsi.ticker_symbol  = sw.ticker_symbol
        AND lsi.transaction_dt = sw.trading_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', "CONCAT(date_format(trading_dt,'yyyyMMdd'), '|', ticker_symbol, '|', src_stm_code)") }} AS string) AS listed_equity_snpst_id,
    CAST(date_format(trading_dt, 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(ind.industry_dim_id AS string)                        AS industry_dim_id,
    CAST(ticker_symbol AS string)                              AS ticker_symbol,
    CAST(floor_code AS string)                                 AS floor_code,
    CAST(stock_tp_code AS string)                              AS stock_tp_code,
    CAST(fund_tp_code AS string)                               AS fund_tp_code,
    CAST(outstanding_share_quantity AS decimal(23,2))                 AS outstanding_share_quantity,
    CAST(listed_share_count AS decimal(23,2))                         AS listed_share_quantity,
    CAST(
        CASE WHEN stock_tp_code = '1'
             THEN listed_share_count * 100000
                  * POWER(10, ROUND(LOG10(NULLIF(reference_price, 0) / 100000)))
             WHEN stock_tp_code IN ('2','3','6')
             THEN listed_share_count * 10000
             ELSE NULL
        END
    AS decimal(23,2))                                          AS listed_share_val,
    CAST(close_price AS decimal(23,2))                         AS close_price,
    CAST(reference_price AS decimal(23,2))                     AS reference_price,
    CAST(nxt_vwap AS decimal(23,2))                                   AS next_day_vol_weighted_average_price,
    CAST(market_price_calc AS decimal(23,2))                   AS market_price,
    CAST(
        CASE WHEN stock_tp_code = '2'
             THEN market_price_calc * outstanding_share_quantity
        END
    AS decimal(23,2))                                          AS market_cap_val,
    CAST(src_stm_code AS string)                               AS src_stm_code
FROM joined
LEFT JOIN ind
    ON  ind.industry_code = joined.industry_code_calc

/*
*--------------------------------------------------------------------*
* [DAILY] Chuyen sang khoi nay sau khi full load xong. Thay the toan
* bo phan WITH...SELECT phia tren.
* Luu y:
*   - prev_dt: tim ngay GD lien truoc etl_date tu calendar dim
*   - sn_all: filter trading_dt IN (D, D-1)
*   - nxt_all/nxt: lay VWAP(D) de dien vao dong D-1
*   - dong D-1: nxt_vwap = VWAP(D) → market_price day du
*   - dong D  : nxt_vwap = NULL   → UPCoM market_price = NULL
*--------------------------------------------------------------------*

WITH prev_dt AS (
    SELECT MAX(cdr_dt) AS prev_trading_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
    WHERE is_trading_date = 'Y'
        AND cdr_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

sn_all AS (
    SELECT
        ticker_symbol,
        trading_dt,
        floor_code,
        stock_tp_code,
        fund_tp_code,
        close_price,
        reference_price,
        listed_share_count,
        vol_weighted_average_price,
        trading_time,
        sequence,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND stock_tp_code IN ('1', '2', '3', '4', '6')
        AND floor_code <> '03'
        AND trading_dt IN (
            to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'),
            (SELECT prev_trading_dt FROM prev_dt)
        )
),

sn AS (
    SELECT ticker_symbol, trading_dt, floor_code, stock_tp_code, fund_tp_code,
           close_price, reference_price, listed_share_count, vol_weighted_average_price, src_stm_code
    FROM sn_all
    WHERE rn = 1
),

nxt_all AS (
    SELECT
        ticker_symbol,
        vol_weighted_average_price AS next_day_vwap,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

nxt AS (
    SELECT ticker_symbol, next_day_vwap
    FROM nxt_all
    WHERE rn = 1
),

pc_all AS (
    SELECT
        equity_ticker_symbol,
        business_line_level_1_code,
        ROW_NUMBER() OVER (
            PARTITION BY equity_ticker_symbol
            ORDER BY CAST(public_company_code AS bigint) ASC
        ) AS rn
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-09-02','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc AS (
    SELECT equity_ticker_symbol, business_line_level_1_code
    FROM pc_all
    WHERE rn = 1
),

sc AS (
    SELECT DISTINCT securities_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND securities_code IS NOT NULL
),

fmc AS (
    SELECT DISTINCT stock_ticker_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-10-15','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
        AND stock_ticker_code IS NOT NULL
),

lsi AS (
    SELECT ticker_symbol, outstanding_share_quantity, transaction_dt
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

ind AS (
    SELECT industry_dim_id, industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('2026-11-05','yyyy-MM-dd')  -- [DAILY] doi thanh etl_date
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

joined AS (
    SELECT
        sn.ticker_symbol,
        sn.trading_dt,
        sn.floor_code,
        sn.stock_tp_code,
        sn.fund_tp_code,
        sn.close_price,
        sn.reference_price,
        sn.listed_share_count,
        sn.src_stm_code,
        lsi.outstanding_share_quantity,
        -- guard trading_dt < etl_date:
        --   dong D-1: lay VWAP(D) tu nxt -> tinh duoc market_price day du
        --   dong D  : nxt_vwap = NULL   -> UPCoM market_price = NULL
        CASE WHEN sn.trading_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
             THEN nxt.next_day_vwap
        END                                                        AS nxt_vwap,
        CASE
            WHEN sn.floor_code = '04' THEN
                CASE WHEN sn.trading_dt < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') THEN
                    CASE WHEN nxt.next_day_vwap IS NULL THEN NULL
                         ELSE COALESCE(NULLIF(nxt.next_day_vwap, 0), sn.reference_price)
                    END
                END
            ELSE sn.close_price
        END                                                        AS market_price_calc,
        CASE WHEN sn.stock_tp_code = '2' THEN
            CASE
                WHEN sc.securities_code IS NOT NULL
                     OR fmc.stock_ticker_code IS NOT NULL THEN '07000'
                ELSE pc.business_line_level_1_code
            END
        END                                                        AS industry_code_calc
    FROM sn
    LEFT JOIN nxt
        ON  nxt.ticker_symbol = sn.ticker_symbol
    LEFT JOIN pc
        ON  pc.equity_ticker_symbol = sn.ticker_symbol
    LEFT JOIN sc
        ON  sc.securities_code = sn.ticker_symbol
    LEFT JOIN fmc
        ON  fmc.stock_ticker_code = sn.ticker_symbol
    LEFT JOIN lsi
        ON  lsi.ticker_symbol  = sn.ticker_symbol
        AND lsi.transaction_dt = sn.trading_dt
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', "CONCAT(date_format(trading_dt,'yyyyMMdd'), '|', ticker_symbol, '|', src_stm_code)") }} AS string) AS listed_equity_snpst_id,
    CAST(date_format(trading_dt, 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(ind.industry_dim_id AS string)                        AS industry_dim_id,
    CAST(ticker_symbol AS string)                              AS ticker_symbol,
    CAST(floor_code AS string)                                 AS floor_code,
    CAST(stock_tp_code AS string)                              AS stock_tp_code,
    CAST(fund_tp_code AS string)                               AS fund_tp_code,
    CAST(outstanding_share_quantity AS bigint)                 AS outstanding_share_quantity,
    CAST(listed_share_count AS bigint)                         AS listed_share_quantity,
    CAST(
        CASE WHEN stock_tp_code = '1'
             THEN listed_share_count * 100000
                  * POWER(10, ROUND(LOG10(NULLIF(reference_price, 0) / 100000)))
             WHEN stock_tp_code IN ('2','3','6')
             THEN listed_share_count * 10000
             ELSE NULL
        END
    AS decimal(23,2))                                          AS listed_share_val,
    CAST(close_price AS decimal(23,2))                         AS close_price,
    CAST(reference_price AS decimal(23,2))                     AS reference_price,
    CAST(nxt_vwap AS bigint)                                   AS next_day_vol_weighted_average_price,
    CAST(market_price_calc AS decimal(23,2))                   AS market_price,
    CAST(
        CASE WHEN stock_tp_code = '2'
             THEN market_price_calc * outstanding_share_quantity
        END
    AS decimal(23,2))                                          AS market_cap_val,
    CAST(src_stm_code AS string)                               AS src_stm_code
FROM joined
LEFT JOIN ind
    ON  ind.industry_code = joined.industry_code_calc

*--------------------------------------------------------------------*
*/
