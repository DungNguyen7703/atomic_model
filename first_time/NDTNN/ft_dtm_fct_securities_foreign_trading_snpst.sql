-- [FIRST-TIME] ft_dtm_fct_securities_foreign_trading_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_securities_foreign_trading_snpst (config ft_target='fct_securities_foreign_trading_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_foreign_trading_snpst
* Program name: Dtm Fct Securities Foreign Trading Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		nghia.le			[FIX] sts: bo sung dau phay con thieu giua cot 'sequence' va ROW_NUMBER()
*									trong SELECT list (fix ngay 2026-10-21 ghi da sua nhung code thuc te
*									van thieu dau phay), gay ParseException 'extra input (' khi chay model.
* 2026-10-21		nghia.le			[FIX] Dong bo LLD: sua loi cu phap CTE sts (thieu dau phay truoc ROW_NUMBER, cot 'sequence'
*									khong co trong LLD) va sua market_id_code HOSE tu 'STO' thanh 'STK' (dung LLD), dong bo voi daily.
* 2026-10-18		nghia.le			[FIRST-TIME NDTNN] Securities Dimension / Public Company Dimension doc _hstr THEO NGAY giao dich (ft_dtm_securities_dim,
*									ft_dtm_public_company_dim, ft_hstr_by_day) thay cho doc bang MAIN ACTIVE -> ma da huy niem yet (vd DAN) van co dong nhu daily.
* 2026-10-17		nghia.le			[FIX] Bo filter stock_tp_code thua (khong co trong LLD) khoi se_di (Securities Dimension) -
*									LLD chi loc loai CK o Security Trading Snapshot (CTE sts), dong bo voi daily.
* 2026-10-17		nghia.le			Dong bo logic daily cap nhat 2026-09-24/2026-10-16/2026-10-17 (O_NDTNN_43/44/45):
*									loai stock_tp_code '1', them JOIN Security Trading Snapshot (rn=1 theo trading_time desc)
*									+ filter market_id_code theo san, rẽ nhanh src_stm_code khi lookup Securities Dimension,
*									nhan dien NDTNN theo SUBSTR(account_nbr,4,1) IN ('E','F'), sua CAST ve decimal(23,2).
*									code_map first-time cap nhat them stock_tp_code chi lay ('2','3','6')/('4'+floor_code='10').
* 2026-10-16		nghia.le			Đồng bộ DTM BA cập nhật 2026-10-15/16 (O_NDTNN_44): Fact lưu ĐA loại CK cho K_NDTNN_1/2/3 'Tổng'
*									(CP + TPDN niêm yết + CCQ + chứng quyền) -> thêm stock_tp_code '4' (chứng quyền) vào bộ lọc Securities Dimension.
*									Lọc cổ phiếu ('2') cho K_4/K_10..K_19 thực hiện ở tầng KPI (03_kpi_queries.sql), không ở đây.
* 2026-10-12		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao: bo loc trade_dt = etl_date (nap toan bo
*                                       lich su atm_securities_trade trong 1 lan, moi ngay 1 partition
*                                       snpst_dt_dim_id nhu daily); dim scd4a doc bang MAIN thay vi
*                                       <bang>_hstr tai etl_date. Gop truoc securities_trade theo
*                                       (trade_dt, security_symbol_code); JOIN co OR (nested loop) chi
*                                       chay tren tap ma CK khac nhau (code_map), roi JOIN bang ve fact -
*                                       tren nhieu nam du lieu khop lenh JOIN OR truc tiep se khong chay
*                                       noi. Ket qua SUM giu nguyen vi so dong dim khop chi phu thuoc
*                                       security_symbol_code.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt,
        security_symbol_code,
        src_stm_code,
        market_id_code,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)  AS foreign_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END) AS foreign_sell_val,
        SUM(execution_val)                                                                       AS total_market_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    -- [FT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY trade_dt, security_symbol_code, src_stm_code, market_id_code
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

sts AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt
    FROM (
        SELECT
            ticker_symbol,
            isin_code,
            trading_dt,
            sequence,
            ROW_NUMBER() OVER (
                PARTITION BY ticker_symbol, trading_dt
                ORDER BY trading_time DESC, sequence DESC
            ) AS rn
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
        WHERE stock_tp_code IN ('2','3','6') OR (stock_tp_code = '4' AND floor_code = '10')
    ) t
    WHERE rn = 1
),

se_di AS (
    SELECT
        securities_dim_id,
        symbol,
        isin_code,
        ds_snpst_dt
    -- [FT-ORIG] FROM {{ ref('dtm_securities_dim') }}_hstr WHERE ds_snpst_dt = etl_date AND ds_rcrd_st = 'ACTIVE'
    FROM {{ ft_ref('ft_dtm_securities_dim') }}_hstr   -- [FT-NEW 2026-10-18] _hstr theo NGAY (khong doc MAIN) - khop daily
    WHERE ds_rcrd_st = 'ACTIVE'
),

pu_co_di AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        equity_ticker_symbol
    FROM (
        SELECT
            public_company_dim_id,
            public_company_code,
            equity_ticker_symbol,
            ROW_NUMBER() OVER (
                PARTITION BY equity_ticker_symbol
                ORDER BY
                    cast(public_company_code as int) ASC
            ) AS rn
        -- [FT-ORIG] FROM {{ ref('dtm_public_company_dim') }}_hstr WHERE ds_snpst_dt = etl_date AND ds_rcrd_st = 'ACTIVE'
        -- [FT-NEW 2026-10-26] doc bang MAIN (ACTIVE) cua dtm_public_company_dim, KHONG doc _hstr theo ngay (hstr thua ngay -> join theo ngay ra NULL)
        FROM {{ ref('dtm_public_company_dim') }}
        WHERE ds_rcrd_st = 'ACTIVE'
          AND equity_ticker_symbol IS NOT NULL
          AND public_company_code IS NOT NULL
    ) t
    WHERE rn = 1
),

-- [FT-NEW] Lookup Securities Dimension theo NGAY giao dich: tach 2 nhanh bang (HOSE theo symbol, HNX theo isin_code) thay cho 1 JOIN co OR
-- (loai tru nhau theo src_stm_code nen tong khong doi) -> hash join theo (ds_snpst_dt, ma), khong nested loop.
code_map AS (
    SELECT
        cd.trade_dt,
        cd.security_symbol_code,
        cd.src_stm_code,
        se_di.securities_dim_id,
        se_di.symbol
    FROM (SELECT DISTINCT trade_dt, security_symbol_code, src_stm_code FROM se_tr WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE') cd
    INNER JOIN se_di
        ON  se_di.ds_snpst_dt = cd.trade_dt
        AND se_di.symbol = cd.security_symbol_code
    UNION ALL
    SELECT
        cd.trade_dt,
        cd.security_symbol_code,
        cd.src_stm_code,
        se_di.securities_dim_id,
        se_di.symbol
    FROM (SELECT DISTINCT trade_dt, security_symbol_code, src_stm_code FROM se_tr WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX') cd
    INNER JOIN se_di
        ON  se_di.ds_snpst_dt = cd.trade_dt
        AND se_di.isin_code = cd.security_symbol_code
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                   AS snpst_dt_dim_id,
    CAST(code_map.securities_dim_id AS string)                               AS securities_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)                           AS public_company_dim_id,
    CAST(SUM(se_tr.foreign_buy_val) AS decimal(23,2))                        AS foreign_buy_val,
    CAST(SUM(se_tr.foreign_sell_val) AS decimal(23,2))                       AS foreign_sell_val,
    CAST(SUM(se_tr.total_market_val) AS decimal(23,2))                       AS total_market_val
FROM se_tr
INNER JOIN sts
    ON  sts.trading_dt = se_tr.trade_dt
    AND (
        (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.ticker_symbol = se_tr.security_symbol_code AND se_tr.market_id_code IN ('STK','BDO'))
        OR (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = se_tr.security_symbol_code AND se_tr.market_id_code IN ('UPX','STX','HCX'))
    )
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = se_tr.trade_dt
-- [FT-ORIG] (daily hien tai) INNER JOIN se_di
--     ON  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND se_di.symbol = se_tr.security_symbol_code)
--     OR  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND se_di.isin_code = se_tr.security_symbol_code)
--   se_di (daily) = dtm_securities_dim_hstr tai etl_date, ACTIVE.
-- [FT-NEW] Thay bang code_map (xem CTE tren): cung phep tra cuu nhung tach 2 nhanh HOSE/HNX va noi theo ngay (se_di.ds_snpst_dt = trade_dt)
--   tren tap ma khac nhau roi JOIN lai se_tr — ket qua giong daily, chi khac cach viet de chay duoc tren nhieu nam du lieu.
INNER JOIN code_map   -- [FT-NEW]
    ON  code_map.trade_dt = se_tr.trade_dt
    AND code_map.security_symbol_code = se_tr.security_symbol_code
    AND code_map.src_stm_code = se_tr.src_stm_code
LEFT JOIN pu_co_di
    ON  pu_co_di.equity_ticker_symbol = code_map.symbol
GROUP BY cd_dt_di.cdr_dt_dim_id, code_map.securities_dim_id, pu_co_di.public_company_dim_id
