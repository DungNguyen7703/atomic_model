/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_management_company_staff_trade_rpt
* Program name: Dtm Fund Management Company Staff Trade Report
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Viết lại theo LLD DTM_QLQ_fund_management_company_staff_trade_rpt_ORDERTRADE.csv (logic-only, schema không đổi):
*                                       cầu nối tài khoản -> CCCD đọc atm_open_investor_account (thay staging VSDC open ∪ updated investors),
*                                       1 dòng/tài khoản theo open_dt DESC; bỏ nhánh updated_investors (LLD không dùng);
*                                       driving trade_dt = etl_date theo LLD (giữ dòng hardcode 2026-10-08 dạng comment)
* 2026-11-07		claude (sync)		Đồng bộ LLD commit bd962bd0 (O_QLQ_78, logic-only, schema output không đổi): đổi tham chiếu Atomic securities_trade theo design 2026-11-04:
*                                       security_symbol_code → ticker_symbol, buy/sell_broker_id → buy/sell_member_code, buy/sell_order_vol → buy/sell_order_quantity;
*                                       src_stm_code ORDERTRADE_TRADE_BOOK_HOSE/HNX → HOSE_TRADE_BOOK/HNX_TRADE_BOOK (lọc + CASE trade_method_nm)
*--------------------------------------------------------------------*
*/

WITH securities_trade AS (
    SELECT
        trade_dt,
        board_tp_code,
        security_symbol_code    AS ticker_symbol,        -- LIVE: ticker_symbol
        buy_account_nbr,
        buy_broker_id           AS buy_member_code,      -- LIVE: buy_member_code
        buy_order_vol           AS buy_order_quantity,   -- LIVE: buy_order_quantity
        buy_order_price,
        sell_account_nbr,
        sell_broker_id          AS sell_member_code,     -- LIVE: sell_member_code
        sell_order_vol          AS sell_order_quantity,  -- LIVE: sell_order_quantity
        sell_order_price,
        src_stm_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')  -- LIVE: 'HOSE_TRADE_BOOK','HNX_TRADE_BOOK'
        AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fmc_employee AS (
    SELECT
        fmc_employee_code,
        fmc_code
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
),

ip_alternative_identification AS (
    SELECT
        ip_code,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
        AND identification_tp_code = 'IDENTIFICATION'
        AND identification_nbr IS NOT NULL
),

-- Cầu nối tài khoản GDCK -> CCCD theo LLD: atm_open_investor_account (nguồn VSDC open_investors), mọi partition open_dt <= etl_date;
-- 1 dòng / số tài khoản = lần mở gần nhất (ROW_NUMBER theo open_dt DESC) để 1 tài khoản chỉ gắn 1 số giấy tờ.
open_investor_account AS (
    SELECT
        investor_account_nbr,
        identification_nbr
    FROM (
        SELECT
            investor_account_nbr,
            identification_nbr,
            ROW_NUMBER() OVER (PARTITION BY investor_account_nbr
                               ORDER BY open_dt DESC) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE investor_account_nbr IS NOT NULL
            AND (open_dt IS NULL OR open_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
    ) t
    WHERE rn = 1
),

-- ia.identification_nbr = emp_id.identification_nbr, emp_id.ip_code = fmc_employee.fmc_employee_code (LLD):
-- 1 dòng / nhân viên × tài khoản GDCK (1 nhân viên có thể có nhiều tài khoản ở nhiều CTCK)
fmc_employee_account AS (
    SELECT DISTINCT
        fmc_employee.fmc_employee_code,
        fmc_employee.fmc_code,
        ip_alternative_identification.identification_nbr,
        open_investor_account.investor_account_nbr
    FROM open_investor_account
    INNER JOIN ip_alternative_identification
        ON ip_alternative_identification.identification_nbr = open_investor_account.identification_nbr
    INNER JOIN fmc_employee
        ON fmc_employee.fmc_employee_code = ip_alternative_identification.ip_code
),

-- ia.investor_account_nbr = securities_trade.buy/sell_account_nbr (LLD) (LEFT JOIN + lọc trade_date của BA tương đương INNER JOIN)
staff_trade_buy AS (
    SELECT
        fmc_employee_account.fmc_employee_code,
        securities_trade.trade_dt,
        securities_trade.buy_account_nbr        AS securities_account_nbr,
        'BUY'                                   AS trade_direction_code,
        securities_trade.ticker_symbol          AS security_symbol_code,
        securities_trade.board_tp_code,
        fmc_employee_account.fmc_code,
        fmc_employee_account.identification_nbr,
        securities_trade.buy_member_code        AS securities_company_code,
        'Mua'                                   AS trade_direction_nm,
        securities_trade.buy_order_quantity     AS order_vol,
        securities_trade.buy_order_price        AS order_price,
        securities_trade.buy_order_quantity * securities_trade.buy_order_price AS order_amt,
        securities_trade.src_stm_code
    FROM securities_trade
    INNER JOIN fmc_employee_account
        ON fmc_employee_account.investor_account_nbr = securities_trade.buy_account_nbr
),

staff_trade_sell AS (
    SELECT
        fmc_employee_account.fmc_employee_code,
        securities_trade.trade_dt,
        securities_trade.sell_account_nbr       AS securities_account_nbr,
        'SELL'                                  AS trade_direction_code,
        securities_trade.ticker_symbol          AS security_symbol_code,
        securities_trade.board_tp_code,
        fmc_employee_account.fmc_code,
        fmc_employee_account.identification_nbr,
        securities_trade.sell_member_code       AS securities_company_code,
        'Bán'                                   AS trade_direction_nm,
        securities_trade.sell_order_quantity    AS order_vol,
        securities_trade.sell_order_price       AS order_price,
        securities_trade.sell_order_quantity * securities_trade.sell_order_price AS order_amt,
        securities_trade.src_stm_code
    FROM securities_trade
    INNER JOIN fmc_employee_account
        ON fmc_employee_account.investor_account_nbr = securities_trade.sell_account_nbr
),

staff_trade AS (
    SELECT * FROM staff_trade_buy
    UNION ALL
    SELECT * FROM staff_trade_sell
)

-- SELECT DISTINCT: khử trùng toàn bộ cột, tương đương UNION của SQL BA (O_QLQ_36)
SELECT DISTINCT
    CAST(staff_trade.fmc_employee_code AS string)                                             AS fmc_employee_code,
    CAST(staff_trade.trade_dt AS date)                                                        AS trade_dt,
    CAST(staff_trade.securities_account_nbr AS string)                                        AS securities_account_nbr,
    CAST(staff_trade.trade_direction_code AS string)                                          AS trade_direction_code,
    CAST(staff_trade.security_symbol_code AS string)                                          AS security_symbol_code,
    CAST(CASE
        WHEN staff_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' THEN  -- LIVE: 'HOSE_TRADE_BOOK'
            CASE staff_trade.board_tp_code
                WHEN 'G1' THEN 'Phiên chính khớp lệnh liên tục'
                WHEN 'G2' THEN 'Phiên định kỳ mở cửa'
                WHEN 'G3' THEN 'Phiên sau đóng cửa'
                WHEN 'G4' THEN 'Giao dịch lô lẻ'
                ELSE 'Khác'
            END
        WHEN staff_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' THEN  -- LIVE: 'HNX_TRADE_BOOK'
            CASE staff_trade.board_tp_code
                WHEN 'G1' THEN 'Phiên chính khớp lệnh liên tục'
                WHEN 'G2' THEN 'Phiên định kỳ mở cửa'
                WHEN 'G3' THEN 'Phiên sau đóng cửa'
                WHEN 'G4' THEN 'Giao dịch lô lẻ'
                WHEN 'G7' THEN 'Giao dịch mua bắt buộc'
                WHEN 'G8' THEN 'Bán giải chấp/bán bắt buộc'
                WHEN 'T1' THEN 'Thỏa thuận'
                WHEN 'T4' THEN 'Thỏa thuận lô lẻ'
                WHEN 'T2' THEN 'Thỏa thuận trước giờ mở cửa'
                WHEN 'T3' THEN 'Thỏa thuận sau giờ giao dịch'
                WHEN 'T6' THEN 'Thỏa thuận sau giờ cho lô lẻ'
                WHEN 'R1' THEN 'Giao dịch repo (mua bán có cam kết mua lại)'
                ELSE 'Khác'
            END
      END AS string)                                                                          AS trade_method_nm,
    CAST(staff_trade.fmc_code AS string)                                                      AS fmc_code,
    CAST(staff_trade.identification_nbr AS string)                                            AS identification_nbr,
    CAST(staff_trade.securities_company_code AS string)                                       AS securities_company_code,
    CAST(staff_trade.trade_direction_nm AS string)                                            AS trade_direction_nm,
    CAST(staff_trade.order_vol AS bigint)                                                     AS order_vol,
    CAST(staff_trade.order_price AS decimal(23,2))                                            AS order_price,
    CAST(staff_trade.order_amt AS decimal(23,2))                                              AS order_amt,
    CAST(staff_trade.src_stm_code AS string)                                                  AS src_stm_code
FROM staff_trade
