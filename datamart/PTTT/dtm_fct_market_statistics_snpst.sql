/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_statistics_snpst
* Program name: Fact Market Statistics Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30	tuan.nguyenvanb	Dedup atm_market_index_snapshot lay ban ghi cuoi phien
*									(ROW_NUMBER PARTITION BY market_id, market_code, trading_dt
*									ORDER BY index_time DESC = 1) giong GSTT - truoc day nhan
*									dong (~hang tram dong / chi so / ngay) va sai LAG/AVG 50 ngay.
*
*--------------------------------------------------------------------*
* CANH BAO - DIEN GIAI LAI CONG THUC SO VOI LLD GOC, CAN LLD XAC NHAN LAI:
* - LLD goc (DTM_PTTT_fct_market_statistics_snpst.csv) viet cong thuc
*   close_price = security_trading_snapshot.close_price va
*   total_trading_val_matched = SUM(securities_trade.execution_val) MA
*   KHONG loc/join theo index_code -- day la cong thuc cua 1 FACT PER MA
*   CHUNG KHOAN DON LE (giong fct_order_size_snpst), KHONG khop voi grain
*   "1 row / chi so (index) / ngay" cua bang nay. Nhieu kha nang la loi
*   copy-paste tu 1 fact khac trong cung LLD.
* - Da DIEN GIAI LAI cho DUNG GRAIN per-index nhu sau:
*   + close_price / close_price_previous_day: lay TRUC TIEP tu
*     atm_market_index_snapshot.market_index_val (gia tri chi so thuc su),
*     KHONG dung security_trading_snapshot.close_price (gia 1 ma CK don le
*     khong co y nghia la "gia dong cua chi so").
*   + total_trading_vol_matched / total_trading_val_matched: JOIN
*     atm_index_constituent_snapshot (bang anh xa ma CK <-> chi so thanh
*     phan) voi atm_securities_trade de aggregate dung theo tung index_code,
*     thay vi lay tong giao dich cua 1 ma CK don le.
* - Day la GIA DINH TU DUA RA de bang co the chay dung nghiep vu, CAN LLD
*   xac nhan lai truoc khi dua vao production.
*--------------------------------------------------------------------*
* Ghi chu ky thuat khac:
* - atm_market_index_snapshot: incremental_rebase/append (kieu tuong tu
*   atm_securities_trade), KHONG co bang phu _hstr, KHONG co cot
*   ds_rcrd_st -> loc truc tiep theo trading_dt.
* - atm_index_constituent_snapshot: cung kieu, khong _hstr, loc truc tiep
*   trading_dt. Cot anh xa: index_code (chi so) <-> symbol (ma CK thanh
*   phan).
* - atm_securities_trade: incremental_rebase/append, loc truc tiep
*   trade_dt, gioi han market_id_code IN ('STO','STX','UPX') giong cac
*   fact PTTT theo co phieu khac.
* - market_code cua fact nay lay tu market_index_snapshot.market_code,
*   xem nhu text tu do (KHONG phai FK chuan hoa toi 1 dimension chi so),
*   dung theo dung LLD.
* - close_price_previous_day va total_trading_val_matched_average_50_days
*   can lich su nhieu ngay -> cac CTE trung gian doc du lieu voi dieu
*   kien trading_dt/trade_dt <= etl_date (KHONG chi loc 1 ngay), chi loc
*   dung etl_date o buoc cuoi cung khi gan nhan data_dt.
* - snpst_dt_dim_id tinh truc tiep bang date_format(trading_dt,'yyyyMMdd')
*   giong convention dtm_fct_order_size_snpst.sql, khong JOIN vat ly
*   dtm_cdr_dt_dim.
*--------------------------------------------------------------------*
* [2026-09-23] CAP NHAT THEO LLD MOI (DTM_PTTT_fct_market_statistics_snpst.csv):
* - Them cot MOI total_outstanding_share_quantity (bigint) - Tong KL co phieu
*   dang luu hanh cua cac ma thuoc ro chi so tai ngay t. Nguon
*   atm_listed_share_information (VSDC_OUTSTANDING_SHARES) JOIN atm_index_constituent
*   _snapshot (symbol <-> index_code) filter trading_dt = etl_date, GROUP BY
*   index_code.
* - listed_share_information lay ban ghi gan nhat <= etl_date theo tung ticker bang
*   ROW_NUMBER dedupe (khong dung MAX(...) correlated subquery nhu LLD viet -
*   cung pattern da chuan hoa o dtm_fct_stock_portfolio_snpst.sql/GSTT, vi
*   MAX(...) khong chong duoc truong hop trung (ticker_symbol, ds_snpst_dt)
*   do incremental_strategy=append o tang atomic khi DAG chay lai).
*--------------------------------------------------------------------*
* [2026-09-25] tuan.nguyenvanb - CAP NHAT THEO LLD MOI (DTM_PTTT_fct_market_statistics_snpst.csv,
*   cap nhat 2026-09-24): them 3 cot MOI net_profit_after_tax_amt, idx_eps,
*   idx_pe (K_PTTT_234/233/235). Ly do trien khai duoc ngay: atomic fr_value
*   (IDS.DATA) da san sang (giong chuoi da dung o
*   dtm_opr_corporate_bond_issuer_credit_monitor.sql cung ngay 2026-09-23).
* - Ca 3 cot dung CHUNG 1 CTE LNST theo ma CK (lnst_by_symbol), pattern dedup
*   ky bao cao HOAN TOAN GIONG dtm_opr_corporate_bond_issuer_credit_monitor.sql
*   (pc_rpt_sub_valid/pc_rpt_sub_ranked/pc_rpt_sub_dedup/pc_rpt_sub_latest_ranked
*   /pc_rpt_sub_latest): rn0 PARTITION BY pc_id, rpt_year, rpt_quarter uu tien
*   HN(1) > TH(2) > ME(3) > RI(4) roi submission_dt DESC -> chot 1 ban ghi nop/ky;
*   rn1 PARTITION BY pc_id ORDER BY rpt_year DESC, rpt_quarter DESC -> lay dung
*   ky GAN NHAT da duyet (approval_status_code = 'APPROVED') tinh den etl_date.
*   LNST = fr_catalog.rpt_code LIKE 'BCKQKD%', fr_row.row_description_reference
*   = '60' (DN/BH) / '21' (TD), fr_column.column_description_reference = '1'.
* - lnst_by_symbol GROUP BY atm_public_company.equity_ticker_symbol (KHONG
*   group theo pc_id, vi 1 cong ty dai chung <-> 1 equity_ticker_symbol) ->
*   JOIN thang vao index_constituent_hist/today theo symbol, KHONG can qua
*   pc_id o tang datamart.
* - net_profit_after_tax_amt = SUM(lnst) cua cac ma thuoc ro chi so, GROUP BY
*   market_code (LEFT JOIN tu index_constituent -> ma chua co LNST duoc coi
*   la 0/NULL, khong cong).
* - idx_eps = SUM(lnst) / SUM(outstanding_share_quantity CHI cua ma CO LNST)
*   -- dung CASE WHEN lnst.lnst IS NOT NULL de tu/mau cung 1 tap ma, dung
*   dung LLD dong 12 (KHONG lay tong mau so toan bo ro).
* - idx_pe = SUM(close_price * outstanding_share_quantity CHI cua ma CO LNST)
*   / SUM(lnst CHI cua ma CO LNST). close_price lay tu
*   atm_security_trading_snapshot (floor_code IN ('02','04','10'),
*   trading_dt = etl_date) theo TUNG MA CK thanh phan (KHAC voi close_price
*   cap chi so o tren dang lay tu market_index_val) -- dung theo dung cong
*   thuc LLD dong 13 (von hoa/LNST cap ma, cong don len chi so).
* - outstanding_share_quantity dung lai CTE oss_latest da co san (dedup
*   ROW_NUMBER theo ds_snpst_dt DESC, khong sua lai logic cu).
* - GIA DINH can LLD/BA xac nhan lai: approval_status_code = 'APPROVED' va
*   SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI') ke thua y het pattern da
*   duyet o dtm_opr_corporate_bond_issuer_credit_monitor.sql; mapping
*   row_description_reference '60'/'21' cho LNST cung lay tu file do (LLD
*   dong 11-13 mo ta bang loi tuong tu). Ma chua co BCTC (khong co ban ghi
*   trong lnst_by_symbol) se KHONG duoc cong vao ca tu va mau, dung theo dung
*   yeu cau LLD "Ma chua co BCTC -> khong cong".
*--------------------------------------------------------------------*
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
* 2026-10-27			tuan.nguyenvanb		[DONG BO THEO CAC MODEL DA SUA: market_risk / futures_intraday] (1) idx_snpst_all / idx_constituent_hist / tr_hist: doc cua so etl_date-80..etl_date thay cho
*									<= etl_date quet toan bo lich su (giong futures_intraday 2026-10-27; du 50 phien cho MA50 + LAG). (2) tr_hist: market_id_code them 'STO' (chuan hoa IN STK, STO, STX, UPX nhu
*									market_risk 2026-10-15) va loc board_tp_code IN (G1,G2,G3,G4,G7,G8) cho KLGD/GTGD khop lenh (giong se_tr_matched_daily cua market_risk 2026-10-07). (3) idx_pe: gia dong cua tung
*									ma lay ban tin cuoi ngay (CTE sts_today, trading_time/sequence DESC - giong market_risk/futures_intraday) thay vi noi moi ban tin, tranh SUM close_price*KLLH bi nhan theo so
*									ban tin. Khong doi cot/kieu -> khong can ALTER; build lai mart + flat.
*									[BA chot 2026-10-28] Chieu chi so: chi tinh CO PHIEU (stock_tp_code='2', san 02/04/10), toan thi truong, KHONG loc board: bo board_tp_code IN (G1,G2,G3,G4,G7,G8) o tr_hist; ro thanh phan (idx_constituent_hist / idx_constituent_today) chi giu ma la co phieu qua stk_day. Khong doi cot/kieu -> build lai mart + flat.
*									[BA chot 2026-10-28] LNST (K_PTTT_234/233/235): moi cong ty lay ky bao cao GAN NHAT CO LNST (lui ve ky truoc neu ky moi nhat khong co LNST); idx_pe: tu so va mau so cung 1 tap ma (co LNST, gia dong cua > 0, KLLH > 0). Khong doi cot/kieu.
*									[FIX 2026-10-28] KLGD/GTGD (K_PTTT_229/237/238) cua chi so HNX/HNX30/HNXCon/HNXFin/HNXLCap/HNXMSCap/HNXMan/UPCOM = 0: so lenh HNX co security_symbol_code = ISIN (Issue_Code) nhung truoc day noi theo ticker. Nay noi 2 nhanh: HOSE theo ticker, HNX theo isin_code cua ma thanh phan (lay tu stk_day), giong sector_risk. Khong doi cot/kieu -> build lai mart + flat.
*									[FIX 2026-10-29] Cua so doc atomic tang 80 -> 200 ngay lich (idx_snpst_all, stk_day, idx_constituent_hist, tr_hist): K_PTTT_238 (TB 50 phien) can DU 50 phien; du lieu thua phien (UAT) 80 ngay chi du ~31 phien nen TB lech ban first-time (50 phien gan nhat toan lich su). Khong doi cot/kieu -> build lai mart + flat.
*									[FIX 2026-10-29] Ro thanh phan (idx_constituent_hist / idx_constituent_today) dung SELECT DISTINCT (chi so, ma, ngay): atm_index_constituent_snapshot co ma lap 2 dong cung ngay (UPCOM 07-20..08-20: AAV, CVN, DDG, KSQ, PCG, SDA, VE8) nen GTGD/KLGD, KLLH, LNST bi cong doi; K_PTTT_238 UPCOM lech 79,6 ty. Khong doi cot/kieu -> build lai mart + flat.
*									[2026-10-29] Dedupe ro thanh phan giong GSTT (dtm_fct_investor_category_index_trading_snpst.ics_dedup): SELECT DISTINCT (ro, ma, ngay) + loc src_stm_code = 'MDDS_JAD_CSIDXINFOR'. Khong doi cot/kieu.
*/

-- atm_market_index_snapshot la du lieu TRONG PHIEN (nhieu ban ghi / chi so / ngay,
-- phan biet bang index_time) -> PHAI lay ban ghi CUOI PHIEN (rn = 1) de dung grain
-- "1 dong / chi so / ngay", neu khong fact nhan dong va LAG/AVG 50 ngay tinh tren
-- tung lan cap nhat thay vi tung phien. Dedup giong GSTT (dtm_fct_index_constituent_snpst,
-- dtm_fct_investor_category_index_trading_snpst).
WITH idx_snpst_all AS (
    SELECT
        trading_dt
        , market_code
        , market_index_val
        , ROW_NUMBER() OVER (
            PARTITION BY market_id, market_code, trading_dt
            ORDER BY index_time DESC
        ) AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 200) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

idx_snpst_hist AS (
    SELECT
        trading_dt
        , market_code
        , market_index_val
    FROM idx_snpst_all
    WHERE rn = 1
),

-- [BA chot 2026-10-28] chieu chi so chi tinh CO PHIEU: ma la co phieu (stock_tp_code = '2', san 02/04/10) theo (ma, ngay)
stk_day AS (
    SELECT
        ticker_symbol
        , trading_dt
        , MAX(isin_code) AS isin_code
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 200) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND floor_code IN ('02','04','10')
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
    FROM {{ ref('atm_index_constituent_snapshot') }} c
    INNER JOIN stk_day
        ON stk_day.ticker_symbol = c.ticker_symbol
        AND stk_day.trading_dt = c.trading_dt
    WHERE c.src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND c.trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 200) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

tr_hist AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , execution_vol
        , execution_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 200) AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code IN ('STK','STO','STX','UPX')
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

-- [MOI 2026-09-23] Outstanding Share Quantity theo ro chi so tai etl_date
oss_all AS (
    SELECT
        lsi.ticker_symbol
        , lsi.outstanding_share_quantity
        , row_number() OVER (PARTITION BY lsi.ticker_symbol ORDER BY lsi.ds_snpst_dt DESC) AS rn
    FROM {{ ref('atm_listed_share_information') }} lsi
    WHERE lsi.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND lsi.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

oss_latest AS (
    SELECT ticker_symbol, outstanding_share_quantity
    FROM oss_all
    WHERE rn = 1
),

-- [2026-10-29] 1 dong / (ro, ma, ngay) - csidxinfor co the co nhieu ban tin cho cung 1 thanh vien (giong GSTT: DISTINCT + src_stm_code = 'MDDS_JAD_CSIDXINFOR')
idx_constituent_today AS (
    SELECT DISTINCT
        c.index_code
        , c.ticker_symbol AS symbol
    FROM {{ ref('atm_index_constituent_snapshot') }} c
    INNER JOIN stk_day
        ON stk_day.ticker_symbol = c.ticker_symbol
        AND stk_day.trading_dt = c.trading_dt
    WHERE c.src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND c.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

oss_by_index AS (
    SELECT
        idx_constituent_today.index_code AS market_code
        , SUM(oss_latest.outstanding_share_quantity) AS total_outstanding_share_quantity
    FROM idx_constituent_today
    INNER JOIN oss_latest
        ON oss_latest.ticker_symbol = idx_constituent_today.symbol
    GROUP BY idx_constituent_today.index_code
),

-- [MOI 2026-09-25] LNST theo ma CK - dung chung cho net_profit_after_tax_amt/idx_eps/idx_pe
-- Pattern dedup ky bao cao GIONG dtm_opr_corporate_bond_issuer_credit_monitor.sql
pc_rpt_sub_valid AS (
    SELECT
        pc_id
        , rpt_year
        , rpt_quarter
        , fr_code
        , submission_dt
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND approval_status_code = 'APPROVED'
        AND SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI')
        AND rpt_quarter IN (1,2,3,4)
        AND submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

pc_rpt_sub_ranked AS (
    SELECT
        pc_rpt_sub_valid.*
        , ROW_NUMBER() OVER (
            PARTITION BY pc_rpt_sub_valid.pc_id, pc_rpt_sub_valid.rpt_year, pc_rpt_sub_valid.rpt_quarter
            ORDER BY
                CASE SUBSTR(pc_rpt_sub_valid.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , pc_rpt_sub_valid.submission_dt DESC
        ) AS rn0
    FROM pc_rpt_sub_valid
),

pc_rpt_sub_dedup AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_ranked
    WHERE rn0 = 1
),

pc_rpt_sub_latest_ranked AS (
    SELECT
        pc_rpt_sub_dedup.*
        , ROW_NUMBER() OVER (
            PARTITION BY pc_rpt_sub_dedup.pc_id
            ORDER BY pc_rpt_sub_dedup.rpt_year DESC, pc_rpt_sub_dedup.rpt_quarter DESC
        ) AS rn1
    FROM pc_rpt_sub_dedup
),

pc_rpt_sub_latest AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code
    FROM pc_rpt_sub_latest_ranked
    WHERE rn1 = 1
),

-- [2026-10-28 BA chot] LNST theo tung ky da duyet, roi lay ky GAN NHAT CO LNST cua tung cong ty (lui ve ky truoc neu ky moi nhat khong co LNST)
lnst_period AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , SUM(fv.cell_val) AS lnst
    FROM pc_rpt_sub_dedup s
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
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter
),

lnst_latest AS (
    SELECT pc_id, lnst
    FROM (
        SELECT
            lnst_period.pc_id
            , lnst_period.lnst
            , ROW_NUMBER() OVER (
                PARTITION BY lnst_period.pc_id
                ORDER BY lnst_period.rpt_year DESC, lnst_period.rpt_quarter DESC
            ) AS rn
        FROM lnst_period
        WHERE lnst_period.lnst IS NOT NULL
    ) x
    WHERE x.rn = 1
),

lnst_by_symbol AS (
    SELECT
        pu_co.equity_ticker_symbol AS symbol
        , SUM(lnst_latest.lnst) AS lnst
    FROM lnst_latest
    INNER JOIN {{ ref('atm_public_company') }}_hstr pu_co
        ON pu_co.pc_id = lnst_latest.pc_id
        AND pu_co.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND pu_co.ds_rcrd_st = 'ACTIVE'
        AND pu_co.src_stm_code = 'IDS_COMPANY_PROFILES'
    GROUP BY pu_co.equity_ticker_symbol
),

-- [2026-10-27] ban tin cuoi ngay moi ma (giong market_risk/sector_risk): atm_security_trading_snapshot giu NHIEU ban tin/ngay,
-- noi truc tiep se nhan SUM(close_price * KLLH) len theo so ban tin.
sts_today_raw AS (
    SELECT
        ticker_symbol
        , close_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND floor_code IN ('02','04','10')
),

sts_today AS (
    SELECT ticker_symbol, close_price
    FROM sts_today_raw
    WHERE rn = 1
),

lnst_and_cp_by_index AS (
    SELECT
        idx_constituent_today.index_code AS market_code
        , SUM(lnst_by_symbol.lnst) AS net_profit_after_tax_amt
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL THEN oss_latest.outstanding_share_quantity END) AS eps_denominator_share_quantity
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL AND security_trading_snapshot.close_price > 0 AND oss_latest.outstanding_share_quantity > 0
                   THEN security_trading_snapshot.close_price * oss_latest.outstanding_share_quantity END) AS pe_numerator_market_cap
        , SUM(CASE WHEN lnst_by_symbol.lnst IS NOT NULL AND security_trading_snapshot.close_price > 0 AND oss_latest.outstanding_share_quantity > 0
                   THEN lnst_by_symbol.lnst END) AS pe_denominator_net_profit
    FROM idx_constituent_today
    LEFT JOIN lnst_by_symbol
        ON lnst_by_symbol.symbol = idx_constituent_today.symbol
    LEFT JOIN oss_latest
        ON oss_latest.ticker_symbol = idx_constituent_today.symbol
    LEFT JOIN sts_today security_trading_snapshot
        ON security_trading_snapshot.ticker_symbol = idx_constituent_today.symbol
    GROUP BY idx_constituent_today.index_code
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
    AS decimal(10,2))                                                   AS idx_pe
FROM windowed
LEFT JOIN oss_by_index
    ON oss_by_index.market_code = windowed.market_code
LEFT JOIN lnst_and_cp_by_index
    ON lnst_and_cp_by_index.market_code = windowed.market_code
WHERE windowed.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
