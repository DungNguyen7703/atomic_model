-- [FIRST-TIME] ft_dtm_foreign_investor_trading_statistics_rpt: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_foreign_investor_trading_statistics_rpt (config ft_target='foreign_investor_trading_statistics_rpt', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_foreign_investor_trading_statistics_rpt
* Program name: Dtm Foreign Investor Trading Statistics Rpt
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-26		nghia.le			Dong bo LLD cap nhat 2026-10-23 (K_NDTNN_3, O_NDTNN_55(2)): bo sung cot total_market_val,
*									dong bo voi daily - xem ghi chu 2026-10-26 o dtm_foreign_investor_trading_statistics_rpt.sql.
* 2026-10-23		nghia.le			Dong bo LLD cap nhat 2026-10-23 (BA Dung 2026-10-22 "Ma 11-14 bo sung chi tieu" — O_NDTNN_54):
*									tach nhom BOND thanh BOND_LISTED/BOND_GOVT/BOND_PRIVATE, dong bo voi daily. BOND_PRIVATE
*									doc tu atm_iss_internal_statistical_report (bang upsert, da la full lich su) bang ref()
*									thuong - khong dung ft_ref() vi model nay chua co ban ft_ rieng va KHONG phai incremental
*									theo etl_date nhu atm_securities_trade (tuong tu ly do atm_foreign_investor dung ref()
*									thuong, xem ghi chu 2026-10-22 ben duoi). TOTAL cong them nhanh BOND_PRIVATE.
* 2026-10-22		nghia.le			[FIX] sts: sua loi cu phap ORDER BY trading_time DESC and sequence DESC
*									-> dung dau phay (Spark SQL khong cho phep 'and' giua cac cot ORDER BY),
*									gay ParseException khi chay model.
* 2026-10-22		nghia.le			[FIRST-TIME NDTNN] Bond Order Book da co ban ft_ rieng (ft_atm_bond_order_book):
*									doi {{ ref('atm_bond_order_book') }} -> {{ ft_ref('ft_atm_bond_order_book') }}.
*									Foreign Investor (model khac co dung atm_foreign_investor) van dung ref() thuong vi
*									nguon stg_fims_investor doc thang tu bang OLTP hien hanh, khong co lich su nhieu
*									ngay o nguon nen chua the thiet ke ban ft_ rieng.
* 2026-10-21		nghia.le			[FIX] Dong bo LLD: sua market_id_code HOSE tu 'STO' thanh 'STK' (dung LLD) o tat ca cac
*									nhanh STOCK/FUND_CERT/WARRANT/TOTAL, dong bo voi daily.
* 2026-10-17		nghia.le			[FIX] se_tr_dim: doi LEFT JOIN code_map -> INNER JOIN code_map de khop dung y do voi
*									daily (INNER JOIN sts) va LLD. Khong doi ket qua so lieu (khong CTE stat_* nao xu ly
*									stock_tp_code IS NULL nen dong khong match da roi vao ELSE 0 o moi nhanh CASE WHEN,
*									tuong duong bi loai bo nhu INNER JOIN) - chi tranh rui ro phan ky khi bao tri sau nay.
* 2026-10-17		nghia.le			[FIX] se_di/code_map: sua lai doc tu ft_atm_security_trading_snapshot (Security Trading
*									Snapshot, co chieu lich su theo trading_dt, rn=1 theo trading_time desc) thay vi tu
*									dtm_securities_dim (Securities Dimension, current-state) - ban truoc do doc nham bang,
*									sai voi chinh comment header va voi daily/LLD. JOIN code_map voi se_tr nay bo sung dieu
*									kien trading_dt = trade_dt vi Security Trading Snapshot co chieu lich su ma Securities
*									Dimension khong co.
* 2026-10-17		nghia.le			Dong bo logic daily cap nhat 2026-10-15/16/17 (O_NDTNN_43/44/45): phan loai theo
*									Security Trading Snapshot (ft_atm_security_trading_snapshot, rn=1 theo trading_time desc)
*									+ filter market_id_code theo san; them nhanh Bond Order Book (ft_atm_bond_order_book neu co,
*									xem ghi chu duoi) cong vao BOND/TOTAL; nhan dien NDTNN theo SUBSTR(account_nbr,4,1) IN ('E','F').
*									code_map first-time giu nguyen co che JOIN OR tren tap ma CK khac nhau, bo sung ve src_stm_code
*									de rẽ nhanh dung sti/isin nhu daily.
* 2026-10-16		nghia.le			[FIRST-TIME NDTNN] Ban khoi tao tu dtm_foreign_investor_trading_statistics_rpt (daily, ban 2026-10-16:
*                                       STOCK '2', BOND '1', FUND_CERT ('3','6'), WARRANT ('4' + floor '10'), TOTAL = 4 nhom):
*                                       - Bo loc trade_dt = etl_date (nap toan bo lich su ft_atm_securities_trade trong 1 lan,
*                                         moi ngay 1 partition report_dt nhu daily).
*                                       - dtm_securities_dim doc bang MAIN (ds_rcrd_st = 'ACTIVE') thay vi _hstr tai etl_date.
*                                       - Gop truoc securities_trade theo (trade_dt, src_stm_code, security_symbol_code); JOIN co OR
*                                         (symbol / isin_code) chi chay tren tap ma CK khac nhau (code_map) roi JOIN bang ve.
*                                         Ket qua SUM khong doi vi nhom CK chi phu thuoc security_symbol_code.
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
        SUM(execution_val) AS total_market_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    -- [FT-ORIG] AND trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY trade_dt, security_symbol_code, src_stm_code, market_id_code
),

driving_src AS (
    SELECT MAX(src_stm_code) AS src_stm_code
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
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
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
        WHERE stock_tp_code IN ('1','2','3','4','6')
    ) t
    WHERE rn = 1
),

-- [FT-NEW] JOIN co OR chi chay tren tap (ngay, san, ma CK) khac nhau (vai nghin x so ngay dong), sau do JOIN bang ve se_tr.
-- Khac voi fct_securities_foreign_trading_snpst: Security Trading Snapshot co chieu lich su theo trading_dt
-- (khac Securities Dimension la current-state), nen code_map phai giu ca trading_dt trong key JOIN.
code_map AS (
    SELECT
        cd.trade_dt,
        cd.security_symbol_code,
        cd.src_stm_code,
        sts.stock_tp_code,
        sts.floor_code
    FROM (SELECT DISTINCT trade_dt, security_symbol_code, src_stm_code FROM se_tr) cd
    INNER JOIN sts
        ON  sts.trading_dt = cd.trade_dt
        AND (
            (cd.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.ticker_symbol = cd.security_symbol_code)
            OR (cd.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = cd.security_symbol_code)
        )
),

se_tr_dim AS (
    SELECT
        se_tr.trade_dt,
        se_tr.src_stm_code,
        se_tr.market_id_code,
        se_tr.foreign_buy_val,
        se_tr.foreign_sell_val,
        se_tr.total_market_val,
        code_map.stock_tp_code,
        code_map.floor_code
    FROM se_tr
    INNER JOIN code_map
        ON  code_map.trade_dt = se_tr.trade_dt
        AND code_map.security_symbol_code = se_tr.security_symbol_code
        AND code_map.src_stm_code = se_tr.src_stm_code
),

-- [FT-NEW 2026-10-22] Bond Order Book: da co ban ft_ rieng, doc qua ft_ref() (khong loc ngay, nap toan bo lich su).
bo_bo AS (
    SELECT
        trading_date,
        order_book_type,
        buying_account_no,
        selling_account_no,
        trading_value,
        first_settlement_value
    FROM {{ ft_ref('ft_atm_bond_order_book') }}
    WHERE src_stm_code IN ('HNX_OUTRIGHT_ORDER_BOOK','HNX_REPO_ORDER_BOOK','HNX_REPO2_ORDER_BOOK')
),

-- [FT-NEW 2026-10-23] Internal Statistical Report (HNX09 - TPDN rieng le): atm_iss_internal_statistical_report
-- la bang upsert (da tich luy toan bo lich su qua cac lan chay daily), dung ref() thuong, khong loc etl_date.
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
),

stat_stock AS (
    SELECT
        trade_dt,
        'STOCK' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  THEN foreign_buy_val ELSE 0 END)  AS buy_val,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  THEN foreign_sell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '2'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX')))
                  THEN total_market_val ELSE 0 END) AS total_market_val
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
                  THEN foreign_buy_val ELSE 0 END)  AS buy_val,
        SUM(CASE WHEN stock_tp_code = '1'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX'))
                  THEN foreign_sell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '1'
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO')
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX'))
                  THEN total_market_val ELSE 0 END) AS total_market_val
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
                  THEN foreign_buy_val ELSE 0 END)  AS buy_val,
        SUM(CASE WHEN stock_tp_code IN ('3','6')
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO'))
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX')))
                  THEN foreign_sell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code IN ('3','6')
                  AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO'))
                       OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX')))
                  THEN total_market_val ELSE 0 END) AS total_market_val
    FROM se_tr_dim
    GROUP BY trade_dt
),

stat_warrant AS (
    SELECT
        trade_dt,
        'WARRANT' AS security_tp_group,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  THEN foreign_buy_val ELSE 0 END)  AS buy_val,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  THEN foreign_sell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN stock_tp_code = '4' AND floor_code = '10'
                  AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK'
                  THEN total_market_val ELSE 0 END) AS total_market_val
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
                 THEN foreign_buy_val ELSE 0 END)  AS buy_val,
        SUM(CASE WHEN (
                  (stock_tp_code = '2' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX'))))
                  OR (stock_tp_code = '1' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX')))
                  OR (stock_tp_code IN ('3','6') AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO')) OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX'))))
                  OR (stock_tp_code = '4' AND floor_code = '10' AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                 )
                 THEN foreign_sell_val ELSE 0 END) AS sell_val,
        SUM(CASE WHEN (
                  (stock_tp_code = '2' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX'))))
                  OR (stock_tp_code = '1' AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'BDO') OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code = 'HCX')))
                  OR (stock_tp_code IN ('3','6') AND ((src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code IN ('STK','BDO')) OR (src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND market_id_code IN ('UPX','STX','HCX'))))
                  OR (stock_tp_code = '4' AND floor_code = '10' AND src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND market_id_code = 'STK')
                 )
                 THEN total_market_val ELSE 0 END) AS total_market_val
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
    CAST(stat_pv.trade_dt AS date)               AS report_dt,
    cast(stat_pv.security_tp_group AS string)    AS security_tp_group,
    CAST(stat_pv.buy_val AS decimal(23,2))       AS buy_val,
    CAST(stat_pv.sell_val AS decimal(23,2))      AS sell_val,
    CAST(stat_pv.total_market_val AS decimal(23,2)) AS total_market_val,
    driving_src.src_stm_code
FROM stat_pv
CROSS JOIN driving_src
