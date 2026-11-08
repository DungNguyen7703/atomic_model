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
*/

WITH se_tr_snpst_raw AS (

    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , close_price
        , total_trading_val
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

    SELECT trading_dt, symbol, close_price, total_trading_val
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

-- INNER JOIN listed_share_information (LLD): ma khong co KL luu hanh VSDC dung ngay bi loai.
-- cap_group_code (VND, KHONG quy doi USD, nguong cung theo SQL BA): Smallcap [100 ty, 1.000 ty), Midcap [1.000 ty, 10.000 ty],
-- Largecap > 10.000 ty; von hoa < 100 ty -> NULL va bi LOAI khoi Fact (BA: WHERE nhom_von_hoa IS NOT NULL).
cap_classified AS (

    SELECT
        se_tr_snpst.trading_dt
        , se_tr_snpst.symbol
        , se_tr_snpst.total_trading_val
        , CASE
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 100000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  1000000000000  THEN 'Smallcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 1000000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <= 10000000000000 THEN 'Midcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >  10000000000000 THEN 'Largecap'
            ELSE NULL
          END AS cap_group_code
    FROM se_tr_snpst
    INNER JOIN listed_share_latest
        ON listed_share_latest.ticker_symbol = se_tr_snpst.symbol

),

cap_group_agg AS (

    SELECT
        cap_classified.trading_dt
        , cap_classified.cap_group_code
        , SUM(cap_classified.total_trading_val) AS total_trading_val
    FROM cap_classified
    WHERE cap_classified.cap_group_code IS NOT NULL
    GROUP BY
        cap_classified.trading_dt
        , cap_classified.cap_group_code

),

-- mau so liquidity_share_ratio (LLD): SUM(total_trading_val) toan bo ma san 02/04/10
-- trong ngay, KHONG qua INNER JOIN listed_share_information
market_total AS (

    SELECT
        se_tr_snpst.trading_dt
        , SUM(se_tr_snpst.total_trading_val) AS market_total_trading_val
    FROM se_tr_snpst
    GROUP BY se_tr_snpst.trading_dt

)

SELECT
    CAST(date_format(cap_group_agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(cap_group_agg.cap_group_code AS string)                      AS cap_group_code,
    CAST(cap_group_agg.total_trading_val AS decimal(23,2))            AS total_trading_val,
    CAST(
        cap_group_agg.total_trading_val
        / NULLIF(market_total.market_total_trading_val, 0) * 100
    AS decimal(5,2))                                                  AS liquidity_share_ratio
FROM cap_group_agg
LEFT JOIN market_total
    ON market_total.trading_dt = cap_group_agg.trading_dt
