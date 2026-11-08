/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_foreign_trading_snpst
* Program name: Dtm Fct Securities Foreign Trading Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-21		nghia.le			[FIX] Dong bo LLD: sua loi cu phap CTE sts (thieu dau phay truoc ROW_NUMBER, cot 'sequence'
*									khong co trong LLD) va sua market_id_code HOSE tu 'STO' thanh 'STK' (dung LLD).
* 2026-10-17		nghia.le			[FIX] Bỏ filter stock_tp_code thừa (không có trong LLD) khỏi se_di (Securities Dimension) —
*									LLD chỉ lọc loại CK ở Security Trading Snapshot (CTE sts), không lọc lại ở bước LOOKUP
*									Securities Dimension. Giữ 'stock_tp_code 4' vào bộ lọc Securities Dimension' của log
*									2026-10-16 bên dưới là ghi chú lịch sử, nay đã loại bỏ điều kiện đó khỏi se_di.
* 2026-10-17		nghia.le			Đồng bộ DTM BA cập nhật 2026-09-24/2026-10-16/2026-10-17 (O_NDTNN_43/44/45):
*									- Loại stock_tp_code '1' (TPDN niêm yết) khỏi phạm vi Fact; giữ ('2','3','6') + chứng quyền ('4' và Floor Code '10').
*									- Thêm JOIN Security Trading Snapshot (bản ghi Trading Time mới nhất/ngày) để xác định Stock Type Code/Floor Code
*									  và thêm filter Market Id Code theo sàn (HOSE 'STO','BDO'; HNX 'UPX','STX','HCX').
*									- Lookup Securities Dimension rẽ nhánh theo src_stm_code: HOSE qua Symbol, HNX qua ISIN Code
*									  (security_symbol_code của HNX là issue_code = ISIN, không phải ticker) — thay OR không điều kiện trước đây.
*									- Nhận diện NĐTNN đổi sang ký tự thứ 4 của số tài khoản (buy_account_nbr/sell_account_nbr) IN ('E','F'),
*									  thay Buy/Sell Foreign Investor Type Code IN ('10','20').
*									- Sửa CAST 3 cột đo lường về decimal(23,2) khớp DDL (trước đây decimal(23,10) sai lệch).
* 2026-10-16		nghia.le			Đồng bộ DTM BA cập nhật 2026-10-15/16 (O_NDTNN_44): Fact lưu ĐA loại CK cho K_NDTNN_1/2/3 'Tổng'
*									(CP + TPDN niêm yết + CCQ + chứng quyền) -> thêm stock_tp_code '4' (chứng quyền) vào bộ lọc Securities Dimension.
*									Lọc cổ phiếu ('2') cho K_4/K_10..K_19 thực hiện ở tầng KPI (03_kpi_queries.sql), không ở đây.
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        execution_val,
        buy_account_nbr,
        sell_account_nbr,
        trade_dt,
        security_symbol_code,
        src_stm_code,
        market_id_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
        trading_dt,
        sequence,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, trading_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND (stock_tp_code IN ('2','3','6') OR (stock_tp_code = '4' AND floor_code = '10'))
),

se_di AS (
    SELECT
        securities_dim_id,
        symbol,
        isin_code,
        trading_time
    FROM {{ ref('dtm_securities_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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
        FROM {{ ref('dtm_public_company_dim') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
          AND ds_rcrd_st = 'ACTIVE'
          AND equity_ticker_symbol IS NOT NULL
          AND public_company_code IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                   AS snpst_dt_dim_id,
    CAST(se_di.securities_dim_id AS string)                                  AS securities_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)                           AS public_company_dim_id,
    CAST(SUM(CASE WHEN SUBSTR(se_tr.buy_account_nbr, 4, 1) IN ('E','F') THEN se_tr.execution_val ELSE 0 END) AS decimal(23,2)) AS foreign_buy_val,
    CAST(SUM(CASE WHEN SUBSTR(se_tr.sell_account_nbr, 4, 1) IN ('E','F') THEN se_tr.execution_val ELSE 0 END) AS decimal(23,2)) AS foreign_sell_val,
    CAST(SUM(se_tr.execution_val) AS decimal(23,2))                          AS total_market_val
FROM se_tr
INNER JOIN sts
    ON  sts.rn = 1
    AND sts.trading_dt = se_tr.trade_dt
    AND (
        (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.ticker_symbol = se_tr.security_symbol_code AND se_tr.market_id_code IN ('STK','BDO'))
        OR (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = se_tr.security_symbol_code AND se_tr.market_id_code IN ('UPX','STX','HCX'))
    )
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = se_tr.trade_dt
INNER JOIN se_di
    ON  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND se_di.symbol = se_tr.security_symbol_code)
    OR  (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND se_di.isin_code = se_tr.security_symbol_code)
LEFT JOIN pu_co_di
    ON  pu_co_di.equity_ticker_symbol = se_di.symbol
GROUP BY cd_dt_di.cdr_dt_dim_id, se_di.securities_dim_id, pu_co_di.public_company_dim_id
