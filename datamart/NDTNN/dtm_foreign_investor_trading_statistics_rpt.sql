/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_trading_statistics_rpt
* Program name: Dtm Foreign Investor Trading Statistics Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-26		nghia.le			Dong bo LLD cap nhat 2026-10-23 (K_NDTNN_3, O_NDTNN_55(2)): bo sung cot total_market_val
*									(tong GT giao dich toan thi truong, KHONG loc NDTNN, theo tung security_tp_group) -
*									cung pham vi/nhom nhu buy_val nhung Securities Trade lay execution_val moi giao dich
*									(bo dieu kien E/F), Bond Order Book lay trading_value/first_settlement_value moi dong
*									so lenh (bo dieu kien E/F), Internal Statistical Report lay row_path = 'GIA TRI GIAO DICH'
*									(khac MUA/BAN cua buy_val/sell_val).
* 2026-10-23		nghia.le			Dong bo LLD cap nhat 2026-10-23 (BA Dung 2026-10-22 "Ma 11-14 bo sung chi tieu" — O_NDTNN_54):
*									tach nhom BOND (gop TPDN niem yet + TPCP) thanh 3 nhom rieng: BOND_LISTED (TPDN niem yet,
*									tu Securities Trade, giu nguyen dieu kien cua nhanh BOND cu), BOND_GOVT (TPCP, tu Bond
*									Order Book — giu nguyen, chi doi nhan), BOND_PRIVATE (TPDN rieng le, nguon moi Internal
*									Statistical Report — bao cao HNX09 qua atm_iss_internal_statistical_report). TOTAL cong
*									ca 3 nhanh nguon (Securities Trade + Bond Order Book + Internal Statistical Report).
* 2026-10-21		nghia.le			[FIX] Dong bo LLD: sua market_id_code HOSE tu 'STO' thanh 'STK' (dung LLD) o tat ca cac
*									nhanh STOCK/FUND_CERT/WARRANT/TOTAL.
* 2026-10-17		nghia.le			Đồng bộ DTM BA STT 14 cập nhật 2026-10-15/16/17 (O_NDTNN_43/44/45):
*									- Phân loại theo Security Trading Snapshot (bản ghi Trading Time mới nhất/ngày) thay vì
*									  dtm_securities_dim_hstr; thêm filter Market Id Code theo sàn cho từng nhóm
*									  (STOCK: HOSE 'STK', HNX 'UPX'/'STX'; BOND: HOSE 'BDO', HNX 'HCX'; FUND_CERT: HOSE 'STK'/'BDO',
*									  HNX 'UPX'/'STX'/'HCX'; WARRANT: HOSE 'STK').
*									- Thêm nhánh Bond Order Book (HNX_OUTRIGHT/REPO/REPO2_ORDER_BOOK) cộng vào BOND và TOTAL
*									  (OUTRIGHT lấy Trading Value, REPO/REPO2 lấy First Settlement Value) — THU HẸP: chưa gồm
*									  TPDN riêng lẻ HNX09, xem O_NDTNN_43.
*									- Nhận diện NĐTNN đổi sang ký tự thứ 4 của số tài khoản (buy/sell_account_nbr) IN ('E','F'),
*									  thay Buy/Sell Foreign Investor Type Code IN ('10','20').
*									- src_stm_code tách CTE driving_src riêng (MAX trên toàn bộ securities_trade theo report_dt,
*									  không group theo stock_tp_code như code cũ) để đúng ngữ nghĩa multi-source (Driving: securities_trade).
* 2026-09-29		tuan.nguyenvanb		Đổi cơ chế phân loại STOCK/BOND/FUND_CERT
*									từ market_id_code sang JOIN Security
*									Trading Snapshot (stock_tp_code), đồng bộ
*									thiết kế O_NDTNN_35 (datamart_model.yaml)
* 2026-10-16		nghia.le			Đồng bộ DTM BA cập nhật 2026-10-15/16 (O_NDTNN_44/45):
*									- STOCK = stock_tp_code '2' (trước '1'); BOND = '1' (TPDN niêm yết, trước '2');
*									  FUND_CERT giữ ('3','6')
*									- Thêm nhóm WARRANT = stock_tp_code '4' AND floor_code '10'
*									- TOTAL = tổng 4 nhóm CP + TPDN niêm yết + CCQ + chứng quyền
*									  (trước đây SUM toàn bộ lệnh khớp, kể cả mã không phân loại)
*									- THU HẸP (O_NDTNN_43): chưa cộng TPCP từ Bond Order Book (HNX outright/repo,
*									  chưa có YAML Atomic) và TPDN riêng lẻ (HNX09) vào BOND/TOTAL
*--------------------------------------------------------------------*
*/

WITH se_tr AS (
    SELECT
        trade_dt,
        security_symbol_code,
        src_stm_code,
        market_id_code,
        execution_val,
        buy_account_nbr,
        sell_account_nbr
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sts AS (
    SELECT
        ticker_symbol,
        isin_code,
        trading_dt,
        stock_tp_code,
        floor_code
    FROM (
        SELECT
            ticker_symbol,
            isin_code,
            trading_dt,
            stock_tp_code,
            floor_code,
            ROW_NUMBER() OVER (
                PARTITION BY ticker_symbol, trading_dt
                ORDER BY trading_time DESC, sequence DESC
            ) AS rn
        FROM {{ ref('atm_security_trading_snapshot') }}
        WHERE trading_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
            AND stock_tp_code IN ('1','2','3','4','6')
    ) t
    WHERE rn = 1
),

se_tr_dim AS (
    SELECT
        se_tr.trade_dt,
        se_tr.src_stm_code,
        se_tr.market_id_code,
        se_tr.execution_val,
        se_tr.buy_account_nbr,
        se_tr.sell_account_nbr,
        sts.stock_tp_code,
        sts.floor_code
    FROM se_tr
    INNER JOIN sts
        ON  sts.trading_dt = se_tr.trade_dt
        AND (
            (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.ticker_symbol = se_tr.security_symbol_code)
            OR (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = se_tr.security_symbol_code)
        )
),

driving_src AS (
    SELECT MAX(src_stm_code) AS src_stm_code
    FROM se_tr
),

bo_bo AS (
    SELECT
        trading_date,
        order_book_type,
        buying_account_no,
        selling_account_no,
        trading_value,
        first_settlement_value
    FROM {{ ref('atm_bond_order_book') }}
    WHERE src_stm_code IN ('HNX_OUTRIGHT_ORDER_BOOK','HNX_REPO_ORDER_BOOK','HNX_REPO2_ORDER_BOOK')
        AND trading_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

isr AS (
    SELECT
        to_date(period_val, 'dd/MM/yyyy') AS trade_dt,
        row_path,
        CAST(cell_val AS decimal(38,2)) AS cell_val
    FROM {{ ref('atm_internal_statistical_report') }}
    WHERE src_stm_code = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND rpt_code = 'HNX09'
        AND period_tp_code = 'DAILY'
        AND submission_status_code IN ('SUBMITTED','LATE_SUBMITTED')
        AND rpt_submission_stm_code = 'ICP'
        AND row_path IN (
            'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA',
            'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ BÁN',
            'GIÁ TRỊ GIAO DỊCH'
        )
        AND to_date(period_val, 'dd/MM/yyyy') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

stat_stock AS (
    SELECT
        trade_dt,
        'STOCK' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  THEN execution_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_bond_listed AS (
    SELECT
        trade_dt,
        'BOND_LISTED' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code = '1'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX'))
                  AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN stock_tp_code = '1'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX'))
                  AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '1'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX'))
                  THEN execution_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_bond_govt AS (
    SELECT
        trading_date AS trade_dt,
        'BOND_GOVT' AS security_tp_group,
        SUM(CASE WHEN SUBSTR(buying_account_no, 4, 1) IN ('E','F')
                  THEN CASE WHEN order_book_type = 'OUTRIGHT' THEN trading_value ELSE first_settlement_value END
                  ELSE 0 END) AS buy_val,
        SUM(CASE WHEN SUBSTR(selling_account_no, 4, 1) IN ('E','F')
                  THEN CASE WHEN order_book_type = 'OUTRIGHT' THEN trading_value ELSE first_settlement_value END
                  ELSE 0 END) AS sell_val,
        SUM(CASE WHEN order_book_type = 'OUTRIGHT' THEN trading_value ELSE first_settlement_value END) AS total_market_val
    FROM bo_bo
    GROUP BY trading_date
),

stat_bond_private AS (
    SELECT
        trade_dt,
        'BOND_PRIVATE' AS security_tp_group,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ MUA' THEN cell_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH NHÀ ĐẦU TƯ NƯỚC NGOÀI - GIÁ TRỊ BÁN' THEN cell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN row_path = 'GIÁ TRỊ GIAO DỊCH' THEN cell_val ELSE 0 END) AS total_market_val
    FROM isr
    GROUP BY trade_dt
),

stat_fund_cert AS (
    SELECT
        trade_dt,
        'FUND_CERT' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code IN ('3','6')
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO'))
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX')))
                  AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN stock_tp_code IN ('3','6')
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO'))
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX')))
                  AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code IN ('3','6')
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO'))
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX')))
                  THEN execution_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_warrant AS (
    SELECT
        trade_dt,
        'WARRANT' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
                  THEN execution_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  THEN execution_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_total_trade AS (
    SELECT
        trade_dt,
        'TOTAL' AS security_tp_group,
        SUM(CASE WHEN (
                  (stock_tp_code = '2' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX'))))
                  OR (stock_tp_code = '1' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX')))
                  OR (stock_tp_code IN ('3','6') AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO')) OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX'))))
                  OR (stock_tp_code = '4' AND floor_code = '10' AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                 )
                 AND SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
                 THEN execution_val ELSE 0 END) AS buy_val,
        SUM(CASE WHEN (
                  (stock_tp_code = '2' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX'))))
                  OR (stock_tp_code = '1' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX')))
                  OR (stock_tp_code IN ('3','6') AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO')) OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX'))))
                  OR (stock_tp_code = '4' AND floor_code = '10' AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                 )
                 AND SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
                 THEN execution_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN (
                  (stock_tp_code = '2' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX'))))
                  OR (stock_tp_code = '1' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX')))
                  OR (stock_tp_code IN ('3','6') AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO')) OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX'))))
                  OR (stock_tp_code = '4' AND floor_code = '10' AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                 )
                 THEN execution_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_total AS (
    SELECT
        trade_dt,
        security_tp_group,
        SUM(buy_val)  AS buy_val,
        SUM(sell_val) AS sell_val,
        SUM(total_market_val) AS total_market_val
    FROM (
        SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_total_trade
        UNION ALL
        SELECT trade_dt, 'TOTAL' AS security_tp_group, buy_val, sell_val, total_market_val FROM stat_bond_govt
        UNION ALL
        SELECT trade_dt, 'TOTAL' AS security_tp_group, buy_val, sell_val, total_market_val FROM stat_bond_private
    ) t
    GROUP BY trade_dt, security_tp_group
),

stat_pv AS (
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_stock
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_bond_listed
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_bond_govt
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_bond_private
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_fund_cert
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_warrant
    UNION ALL
    SELECT trade_dt, security_tp_group, buy_val, sell_val, total_market_val FROM stat_total
)

SELECT
    CAST(stat_pv.trade_dt AS date)              AS report_dt,
    CAST(stat_pv.security_tp_group AS string)   AS security_tp_group,
    CAST(stat_pv.buy_val AS decimal(23,2))      AS buy_val,
    CAST(stat_pv.sell_val AS decimal(23,2))     AS sell_val,
    CAST(stat_pv.total_market_val AS decimal(23,2)) AS total_market_val,
    driving_src.src_stm_code
FROM stat_pv
CROSS JOIN driving_src
