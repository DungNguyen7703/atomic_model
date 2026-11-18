/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_cap_grp_snpst
* Program name: Fact Cap Group Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* [2026-09-24] NOI atm_status_threshold_config (DA DUOC BUILD): them CTE
* threshold_cap_group LOOKUP index_code='CAP_GROUP' + ds_rcrd_st='ACTIVE'
* tren {{ ref('atm_status_threshold_config') }} (cac cot ky thuat SCD2
* ds_rcrd_st/ds_rcrd_eff_dt/ds_rcrd_end_dt do macro mcr_scd2.sql tu them
* vao bang vat ly, KHONG xuat hien trong SELECT cua model do nhung VAN CO
* trong output khi JOIN qua ref()). market_cap.cap_group_code gio LOOKUP
* that: JOIN threshold_cap_group ON market_cap_usd BETWEEN from_value AND
* to_value -> status. from_value/to_value la INT (theo dinh nghia atomic
* model) trong khi market_cap_usd la decimal(23,2) -> CAST from_value/
* to_value sang decimal(23,2) truoc khi so sanh BETWEEN de tranh implicit
* cast sai kieu tren Spark. total_trading_val/liquidity_share_ratio gio
* GROUP BY dung cap_group_code that (SUM total_trading_val_symbol trong
* cap_classified, liquidity_share_ratio = total_trading_val cua nhom /
* tong GTGD toan thi truong trong ngay x 100, dung window SUM OVER
* PARTITION BY trading_dt de lay mau so theo dung LLD dong 5 - "SUM(...)
* GROUP BY trading_dt" o mau so).
* - Toan bo logic phu tro da duoc code san trong CTE
*   market_cap/tr_agg/cap_classified, gio da noi lai qua threshold_cap_group
*   (thay CTE cap_classified bang LOOKUP that va GROUP BY cap_group_code):
*   + market_cap_usd = close_price * outstanding_share_quantity /
*     NULLIF(ex_rate_vnd_usd, 0), tinh theo tung ma CK thoa dieu kien
*     san co so + UPCOM qua floor_code IN ('02','04','10') tren
*     atm_security_trading_snapshot (da XAC NHAN TON TAI, models/atomic/
*     product).
*   + outstanding_share_quantity: LEFT JOIN atm_listed_share_information (da
*     XAC NHAN TON TAI), src_stm_code = 'VSDC_OUTSTANDING_SHARES', lay
*     ban ghi co ds_snpst_dt <= trading_dt GAN NHAT (correlated subquery
*     MAX, vi dbt-spark khong ho tro LATERAL JOIN thuan tien trong cu
*     phap nay).
*   + ex_rate_vnd_usd: LEFT JOIN atm_cl_risk_indicator_value (da XAC
*     NHAN TON TAI, models/atomic/common), cl_risk_ind_code =
*     'EX_RATE_VND_USD', period_dt = trading_dt.
*   + total_trading_val theo tung ma CK: SUM(execution_val) tu
*     atm_securities_trade (da XAC NHAN TON TAI), market_id_code IN
*     ('STO','STX','UPX') dung DUNG literal trong LLD -- LUU Y: cac fact
*     PTTT khac (vd dtm_fct_order_size_snpst) dung 'STK' thay vi 'STO'
*     cho co so HOSE/HNX, CO THE LA LOI CHINH TA CUA LLD file nay, giu
*     nguyen 'STO' theo dung LLD va can nghiep vu/LLD xac nhan lai.
* - snpst_dt_dim_id tinh truc tiep bang date_format(trading_dt,
*   'yyyyMMdd'), khong JOIN vat ly toi dtm_cdr_dt_dim, giong convention
*   chung cua PTTT.
* - atm_security_trading_snapshot: KHONG _hstr, loc truc tiep trading_dt
*   = etl_date. atm_securities_trade: KHONG _hstr, loc truc tiep
*   trade_dt = etl_date.
* - Output nay: 1 dong / nhom von hoa (cap_group_code) / ngay giao dich,
*   dung grain theo LLD sau khi noi that atm_status_threshold_config.
*   WARNING: ma CK KHONG roi vao khoang from_value/to_value nao (LEFT JOIN
*   khong khop) se co cap_group_code = NULL va bi gom chung vao 1 "nhom
*   NULL" khi GROUP BY - CAN nghiep vu xac nhan lai threshold co phu kin
*   toan bo pham vi market_cap_usd hay khong truoc production.
*--------------------------------------------------------------------*
* 2026-10-07			tuan.nguyenvanb		market_id_code HOSE doi 'STO' -> 'STK': du lieu atm_securities_trade
*									(HOSE) chi co 'STK', 'STO' lam model BO SOT toan bo san HOSE. LLD van ghi
*									'STO' - can design sua lai LLD.
* 2026-10-09			tuan.nguyenvanb		Ap dung LLD 2026-10-09 (commit d39ed114): (1) cap_group_code phan nhom
*									bang CASE nguong cung dung SQL BA (market_cap_usd < 2 ty Small-cap, < 10 ty
*									Mid-cap, con lai Large-cap, NULL khi thieu ty gia hoac ty gia <= 0), BO
*									LOOKUP atm_status_threshold_config CAP_GROUP. (2) total_trading_val va
*									liquidity_share_ratio lay tu security_trading_snapshot.total_trading_val
*									(ban ghi trading_time moi nhat moi ma), BO nguon atm_securities_trade nen
*									het van de market_id STO/STK. (3) INNER JOIN listed_share_information (ma khong co
*									KL luu hanh VSDC bi loai khoi tu so), mau so liquidity_share_ratio = tong
*									GTGD toan bo ma thuoc san 02/04/10 (khong qua INNER JOIN).
* 2026-10-10			tuan.nguyenvanb		LOI UNRESOLVED_COLUMN trading_dt: bang atomic atm_security_trading_snapshot hien
*									KHONG con cot trading_dt (file atomic sua 2026-10-09 19:32) -> doc ngay giao dich
*									tu ds_snpst_dt (= tradingdate vi ODS loc TRADINGDATE = etl_date), dat alias
*									trading_dt de cac CTE phia sau khong doi.
* 2026-10-21			tuan.nguyenvanb		Ap dung LLD commit 142edef6 (BA STT 243, O_PTTT_38): (1) BO quy doi USD - bo CTE ex_rate / bang
*									EX_RATE_VND_USD khoi nguon, von hoa = close_price * KL luu hanh (VND); (2) nhom theo nguong VND cung: Smallcap
*									[100 ty,1.000 ty), Midcap [1.000 ty,10.000 ty], Largecap > 10.000 ty, < 100 ty -> NULL va loai khoi Fact (WHERE
*									cap_group_code IS NOT NULL o cap_group_agg); (3) NHAN doi 'Small-cap/Mid-cap/Large-cap' -> 'Smallcap/Midcap/Largecap';
*									(4) KL luu hanh noi DUNG NGAY (transaction_date = trading_dt, thay lookback ds_snpst_dt MAX <=). Mau so
*									liquidity_share_ratio giu nguyen (toan thi truong san 02/04/10, khong qua INNER JOIN) nen 3 nhom co the < 100%.
*									Cac ghi chu cu o tren ve ex_rate/threshold/lookback khong con hieu luc. Khong doi cot/kieu nen khong can ALTER.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: listed_share_information.transaction_date->transaction_dt. Khong doi cot/kieu.
* 2026-11-08			tuan.nguyenvanb		Doi nguong nhom von hoa theo yeu cau moi: Smallcap < 1.000 ty (BO can duoi 100 ty, ma von hoa < 100 ty nay vao Smallcap
*									thay vi bi loai), Midcap [1.000 ty, 10.000 ty), Largecap >= 10.000 ty (bien 10.000 ty chuyen tu Midcap sang Largecap).
*									Khong doi cot/kieu nen khong can ALTER.
* 2026-11-10			nghia.le			Theo code nguon BA (Phan bo thanh khoan theo nhom von hoa): (1) liquidity_share_ratio = GTGD nhom / TONG GTGD CUA CHINH CAC NHOM (SUM OVER theo ngay)
*									-> tong 3 nhom = 100% (truoc: mau so la GTGD toan bo ma san 02/04/10, ke ca ma khong xep duoc nhom -> < 100%); (2) GTGD theo ma lay tu SO LENH KHOP
*									(atm_securities_trade: STK/STX/UPX, board G1,G2,G3,G4,G7,G8; HNX noi ma qua isin_code) thay cho security_trading_snapshot.total_trading_val.
*									Khong doi cot/kieu nen khong can ALTER; can build lai mart + flat (va first-time) de ap dung.
* 2026-11-10			nghia.le			DOI TEN + DOI CONG THUC cot liquidity_share_ratio -> market_cap_share_ratio: nay la TY TRONG VON HOA nhom = SUM(von hoa = close_price x KL luu hanh
*									cua cac ma trong nhom) / tong von hoa 3 nhom cung ngay x 100 (tuong ung ty_trong_von_hoa_pct cua code nguon BA), thay cho ty trong GTGD (chart
*									"Phan bo ... theo Nhom von hoa" hien ty trong von hoa; khong cho nao khac dung ty trong GTGD). total_trading_val giu nguyen.
*									Khop code nguon BA moi (gdc lay ban ghi cuoi ngay, nhom LEFT JOIN gtgd_theo_ma): von hoa nhom gom CA ma khong co giao dich trong ngay (GTGD = 0).
*									CAN ALTER mart + flat ClickHouse: RENAME COLUMN liquidity_share_ratio TO market_cap_share_ratio truoc khi build.
*/

WITH se_tr_snpst_raw AS (

    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , close_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND floor_code IN ('02','04','10')

),

-- ban ghi trading_time moi nhat moi ma/ngay (LLD 2026-10-09)
se_tr_snpst AS (

    SELECT trading_dt, symbol, isin_code, close_price
    FROM se_tr_snpst_raw
    WHERE rn = 1

),

-- [2026-10-21, LLD 142edef6 / BA STT 243] KL luu hanh DUNG NGAY giao dich: listed_share_information.transaction_dt =
-- security_trading_snapshot.trading_dt (thay lookback ds_snpst_dt MAX <= trading_dt). Cot atomic: transaction_dt (design 2026-10-21).
-- ROW_NUMBER chong nhan dong neu (ma, ngay VSDC) co o nhieu snapshot.
listed_share_all AS (

    SELECT
        ticker_symbol
        , outstanding_share_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, transaction_dt ORDER BY ds_snpst_dt DESC) AS rn
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND transaction_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

listed_share_latest AS (

    SELECT
        ticker_symbol
        , outstanding_share_quantity
    FROM listed_share_all
    WHERE rn = 1

),

-- [2026-11-10, BA] GTGD theo ma CK lay tu SO LENH KHOP (trade book), KHONG con dung security_trading_snapshot.total_trading_val (khong loc board):
--   HOSE: market_id_code = 'STK' (ma giao dich = security_symbol_code); HNX/UPCOM: 'STX','UPX' (security_symbol_code cua so lenh HNX la ISIN -> doi sang ma
--   qua isin_code cua snapshot). Chi lay board G1,G2,G3,G4,G7,G8. execution_val da la gia tri khop (HNX: gia x KL).
trade_matched AS (

    SELECT
        trade_dt
        , security_symbol_code
        , market_id_code
        , execution_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code IN ('STK','STX','UPX')
        AND board_tp_code IN ('G1','G2','G3','G4','G7','G8')

),

ma_isin AS (

    SELECT DISTINCT
        isin_code
        , symbol
    FROM se_tr_snpst
    WHERE isin_code IS NOT NULL

),

trade_by_symbol AS (

    SELECT
        trade_matched.trade_dt AS trading_dt
        , CASE WHEN trade_matched.market_id_code = 'STK' THEN trade_matched.security_symbol_code ELSE ma_isin.symbol END AS symbol
        , trade_matched.execution_val
    FROM trade_matched
    LEFT JOIN ma_isin
        ON trade_matched.market_id_code IN ('STX','UPX')
        AND ma_isin.isin_code = trade_matched.security_symbol_code
    WHERE trade_matched.market_id_code = 'STK' OR ma_isin.symbol IS NOT NULL

),

gtgd_theo_ma AS (

    SELECT
        trading_dt
        , symbol
        , SUM(execution_val) AS total_trading_val
    FROM trade_by_symbol
    GROUP BY
        trading_dt
        , symbol

),

-- INNER JOIN listed_share_information (LLD): ma khong co KL luu hanh VSDC dung ngay bi loai.
-- cap_group_code (VND, KHONG quy doi USD): Smallcap < 1.000 ty, Midcap [1.000 ty, 10.000 ty), Largecap >= 10.000 ty
-- (2026-11-08). NULL chi khi thieu gia dong cua hoac KL luu hanh -> bi LOAI khoi Fact (WHERE cap_group_code IS NOT NULL).
cap_classified AS (

    SELECT
        se_tr_snpst.trading_dt
        , se_tr_snpst.symbol
        , COALESCE(gtgd_theo_ma.total_trading_val, 0) AS total_trading_val
        , (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) AS market_cap
        , CASE
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  1000000000000  THEN 'Smallcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 1000000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  10000000000000 THEN 'Midcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 10000000000000 THEN 'Largecap'
            ELSE NULL
          END AS cap_group_code
    FROM se_tr_snpst
    INNER JOIN listed_share_latest
        ON listed_share_latest.ticker_symbol = se_tr_snpst.symbol
    LEFT JOIN gtgd_theo_ma   -- [2026-11-10] LEFT (nhu BA): ma co von hoa nhung khong co GTGD van tinh von hoa vao nhom (GTGD = 0)
        ON gtgd_theo_ma.symbol = se_tr_snpst.symbol
        AND gtgd_theo_ma.trading_dt = se_tr_snpst.trading_dt

),

cap_group_agg AS (

    SELECT
        cap_classified.trading_dt
        , cap_classified.cap_group_code
        , SUM(cap_classified.total_trading_val) AS total_trading_val
        , SUM(cap_classified.market_cap) AS total_market_cap
    FROM cap_classified
    WHERE cap_classified.cap_group_code IS NOT NULL
    GROUP BY
        cap_classified.trading_dt
        , cap_classified.cap_group_code

)

SELECT
    CAST(date_format(cap_group_agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(cap_group_agg.cap_group_code AS string)                      AS cap_group_code,
    CAST(cap_group_agg.total_trading_val AS decimal(23,2))            AS total_trading_val,
    CAST(
        cap_group_agg.total_market_cap
        / NULLIF(SUM(cap_group_agg.total_market_cap) OVER (PARTITION BY cap_group_agg.trading_dt), 0) * 100
    AS decimal(5,2))                                                  AS market_cap_share_ratio
FROM cap_group_agg
