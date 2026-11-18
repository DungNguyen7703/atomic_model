/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_futures_investor_flow_snpst
* Program name: Fact Futures Investor Flow Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - LLD mo ta grain "1 row / nhom NDT / ma HDTL / ngay" nhung danh sach
*   cot yeu cau (foreign_buy_vol, foreign_sell_vol, proprietary_buy_vol,
*   proprietary_sell_vol...) lai nam CHUNG tren 1 dong theo tung ma HDTL
*   (khong co cot dimension nhom NDT rieng, khong co FK toi
*   dtm_investor_group_dim). Da giu dung grain THUC TE la 1 row / ma HDTL
*   / ngay, voi cac cap cot buy/sell tach rieng theo nhom Nuoc ngoai va
*   Tu doanh nam ngang hang -- can LLD xac nhan lai neu y dinh that su la
*   normalize theo investor_group_dim (dang long format).
* - atm_security_trading_snapshot: incremental_rebase/snapshot, KHONG
*   _hstr, KHONG ds_rcrd_st -> loc truc tiep trading_dt = etl_date.
* - atm_securities_trade: incremental_rebase/append, KHONG _hstr -> loc
*   truc tiep trade_dt = etl_date.
* - HDTL xac dinh bang stock_tp_code = '4' AND floor_code='03' tren
*   atm_security_trading_snapshot; giao dich loc theo market_id_code='DVX'
*   tren atm_securities_trade.
* - underlying_symbol DA TON TAI san tren atm_security_trading_snapshot
*   (khong PENDING).
* - Nha dau tu nuoc ngoai: buy_foreign_investor_tp_code /
*   sell_foreign_investor_tp_code <> '00' (ma '00' quy uoc la khong phai
*   NDT nuoc ngoai, theo dung convention da dung o cac fact PTTT khac
*   cung nhom atomic securities_trade).
* - Tu doanh CTCK: buy_client_house_cl_code / sell_client_house_cl_code
*   IN ('30') theo dung business rule da chot trong yeu cau.
* - foreign_buy_vol/foreign_sell_vol va proprietary_buy_vol/
*   proprietary_sell_vol duoc tinh gop trong CUNG 1 lan quet
*   atm_securities_trade bang SUM(CASE WHEN ...) thay vi 4 lan GROUP BY
*   rieng le -- ket qua tuong duong ve mat toan hoc voi cach mo ta trong
*   yeu cau (cung dieu kien WHERE nen, chi khac dieu kien loc buy/sell o
*   muc CASE thay vi muc WHERE).
* - snpst_dt_dim_id tinh truc tiep bang date_format(trading_dt,'yyyyMMdd')
*   giong convention dtm_fct_order_size_snpst.sql, khong JOIN vat ly
*   dtm_cdr_dt_dim.
* - [2026-09-23 doi chieu lai LLD DTM_PTTT_fct_futures_investor_flow_snpst.
*   csv] LLD VAN CHUA SUA: danh sach 9 cot dan ra (snpst_dt_dim_id,
*   security_symbol_code, underlying_symbol, foreign_buy_vol,
*   foreign_sell_vol, foreign_net_vol, proprietary_buy_vol,
*   proprietary_sell_vol, proprietary_net_vol) khop CHINH XAC 100% voi
*   cau truc dang code (khong co FK investor_group_dim_id nao trong LLD).
*   -> GIU NGUYEN logic/cau truc cot hien tai, khong sua gi. Van can
*   nghiep vu/LLD xac nhan lai xem grain "per nhom NDT" trong ten cot mo
*   ta co dung y dinh la PIVOT theo dtm_investor_group_dim (dang long,
*   giong fct_investor_flow_snpst) hay khong; neu co thi day la 1 thay
*   doi cau truc lon (breaking change) can lam lai tu dau.
*--------------------------------------------------------------------*
* 2026-10-19			tuan.nguyenvanb		Ap dung LLD commit 05c7c2d3 (O_PTTT_51, BA STT 28/31, BA dong 396-399): NDTNN theo ky tu thu 4 cua so tai
*									khoan MUA/BAN IN ('E','F') (thay buy/sell_foreign_investor_tp_code <> '00'); Tu doanh IN ('A','E','P')
*									(thay buy/sell_client_house_cl_code = '30'). Ghi chu cu o tren ve '00'/'30' khong con hieu luc.
*									Khong doi ten/kieu/vi tri cot output nen khong can ALTER. market_id_code HOSE van 'STK' (LLD ghi 'STO').
* 2026-10-21			tuan.nguyenvanb		SUA KHOA NOI so lenh DVX <-> HDTL: security_symbol_code (so lenh) = ISIN nen noi bang isin_code cua snapshot, KHONG
*									noi bang symbol (truoc day 0/7 ma khop -> ca 6 cot *_vol = 0). Dung mapping BA STT 28/31 (dong 396-399:
*									Issue_Code = symbolisin AND Trade_date = tradingdate). Them CTE fu_raw lay ban tin cuoi ngay (rn=1) truoc khi loc
*									stock_tp_code = '4' AND floor_code = '03'; doc ngay qua ds_snpst_dt AS trading_dt (atomic khong con cot trading_dt).
*									LLD fct_futures_investor_flow_snpst van ghi noi theo ticker_symbol - CAN DESIGN SUA (O_PTTT_50). Khong doi cot output.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*/

-- [2026-10-21] Bản tin CUOI NGAY moi ma truoc khi loc loai HDTL (dung ranked_stock cua mapping BA STT 28/31):
-- ROW_NUMBER theo (symbol, ngay) ORDER BY trading_time DESC, sequence DESC, chi lay rn = 1 roi moi loc stock_tp_code/floor_code.
-- Lay them isin_code de noi so lenh DVX (Issue Code = ISIN).
WITH fu_raw AS (
    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , underlying_symbol
        , stock_tp_code
        , floor_code
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fu_symbols AS (
    SELECT
        trading_dt
        , symbol
        , isin_code
        , underlying_symbol
    FROM fu_raw
    WHERE rn = 1
        AND stock_tp_code = '4'
        AND floor_code = '03'
),

flow AS (
    SELECT
        trade_dt
        , security_symbol_code
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_vol ELSE 0 END) AS foreign_buy_vol
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_vol ELSE 0 END) AS foreign_sell_vol
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('A','E','P') THEN execution_vol ELSE 0 END) AS proprietary_buy_vol
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('A','E','P') THEN execution_vol ELSE 0 END) AS proprietary_sell_vol
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code = 'DVX'
    GROUP BY
        trade_dt
        , security_symbol_code
),

joined AS (
    SELECT
        fu_symbols.trading_dt
        , fu_symbols.symbol
        , fu_symbols.underlying_symbol
        , COALESCE(flow.foreign_buy_vol, 0)      AS foreign_buy_vol
        , COALESCE(flow.foreign_sell_vol, 0)     AS foreign_sell_vol
        , COALESCE(flow.proprietary_buy_vol, 0)  AS proprietary_buy_vol
        , COALESCE(flow.proprietary_sell_vol, 0) AS proprietary_sell_vol
    FROM fu_symbols
    LEFT JOIN flow
        ON flow.security_symbol_code = fu_symbols.isin_code
        AND flow.trade_dt = fu_symbols.trading_dt
)

SELECT
    CAST(date_format(joined.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(joined.symbol AS string)                              AS security_symbol_code,
    CAST(joined.underlying_symbol AS string)                   AS underlying_symbol,
    CAST(joined.foreign_buy_vol AS decimal(23,2))              AS foreign_buy_vol,
    CAST(joined.foreign_sell_vol AS decimal(23,2))             AS foreign_sell_vol,
    CAST(joined.foreign_buy_vol - joined.foreign_sell_vol AS decimal(23,2))      AS foreign_net_vol,
    CAST(joined.proprietary_buy_vol AS decimal(23,2))          AS proprietary_buy_vol,
    CAST(joined.proprietary_sell_vol AS decimal(23,2))         AS proprietary_sell_vol,
    CAST(joined.proprietary_buy_vol - joined.proprietary_sell_vol AS decimal(23,2)) AS proprietary_net_vol
FROM joined
