-- [FIRST-TIME] ft_dtm_opr_security_index_constituent_ref: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_opr_security_index_constituent_ref (config ft_target='opr_security_index_constituent_ref', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_security_index_constituent_ref
* Program name: Dtm Opr Security Index Constituent Ref
* Created by: tuan.nguyenvanb
* Created date: 2026-10-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-06		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_opr_security_index_constituent_ref_MDDS_JAD_CSIDXINFOR.csv,
*                                       GSTT Nhom 44/45, K_GSTT_360-361] Bang tham chieu ma thuoc ro chi
*                                       so: Index Code <-> Symbol <-> ISIN Code. Operational / current-state,
*                                       1 dong / (ro chi so x ma CK thanh vien o ngay giao dich MOI NHAT cua
*                                       ro). Phuc vu BI loc so lenh HNX security_symbol_code IN (symbol,
*                                       isin_code). Khong FK Star Schema.
*                                       - Driving: atm_index_constituent_snapshot (src MDDS_JAD_CSIDXINFOR),
*                                         giu danh sach thanh vien o trading_dt = MAX(trading_dt) cua tung
*                                         index_code (nhin lai ds_snpst_dt <= etl_date).
*                                       - isin_code: ban ghi moi nhat cua symbol trong atm_security_trading_
*                                         snapshot (MDDS_JAD_STOCKINFOR), cung quy tac security_trading_
*                                         snpst_dim (trading_tms DESC).
*                                       - index_nm: market_code = index_code, ban ghi moi nhat cua
*                                         atm_market_index_snapshot (MDDS_JAD_MARKETINFOR). NULL neu thieu
*                                         market_code (O_GSTT_3, vd HNXLCap/HNXCon).
*                                       Dedupe (index_code, symbol) theo ds_snpst_dt DESC de dam bao khoa
*                                       PK duy nhat cho scd4a (atomic append co the trung giua cac lan build).
* 2026-10-08		tuan.nguyenvanb		[LLD b6c83b76, bo sung cot] Them 8 cot: index_constituent_snpst_code,
*                                       index_id (truy vet GUID/ID nguon JAD_CSIDXINFOR, khong phai khoa),
*                                       stock_tp_code, stock_floor_code (san cua MA CK - khac floor_code
*                                       la san cua CHI SO), derivative_product_nm, security_class_code,
*                                       industry_code, industry_nm. Cot moi lay tu ban ghi moi nhat cua
*                                       symbol trong atm_security_trading_snapshot (cung quy tac isin_code).
*                                       industry_code/industry_nm theo quy tac K_GSTT_2: join public_company
*                                       (chung quyen dung underlying_symbol, trai phieu dung 3 ky tu dau co
*                                       loc loai tru no cong), CTCK dai chung khong co trong IDS -> nganh IDS
*                                       ma 07000 (atm_cl_business_line). Doc IDS tai snapshot etl_date.
*                                       Model scd4a insert theo TEN cot nen khong lech vi tri.
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-08		tuan.nguyenvanb		[SUA theo LLD 2026-10-08, O_GSTT_61] security_class_code tra ve NHAN TIENG VIET
*                                       (Trai phieu/Co phieu/ETF/Chung chi quy/Chung quyen/Phai sinh/Khac) cung quy tac va gia
*                                       tri voi security_trading_snpst_dim.stock_tp_nm; ten cot giu nguyen. Khong can ALTER.
* 2026-10-09		tuan.nguyenvanb		[SUA theo LLD v4.42 2026-10-09, tach bang] BO 6 cot ve MA CK khoi bang nay: stock_tp_code,
*                                       stock_floor_code, derivative_product_nm, security_class_code, industry_code, industry_nm.
*                                       Cac cot nay chuyen sang bang moi opr_security_ref (dtm_opr_security_ref, PK symbol, tra ma CK
*                                       toan bo JAD_STOCKINFOR). Bang nay chi con tham chieu ro chi so: index_code, symbol,
*                                       index_constituent_snpst_code, index_id, index_nm, floor_code (san cua CHI SO), add_dt, as_of_dt,
*                                       isin_code. Bo cac CTE khong con dung (pu_co, cl_bl, cl_bl_ctck, sc_ctck). Can ALTER DROP COLUMN
*                                       6 cot o bang Iceberg va ClickHouse flat (xem scratch/alter_gstt_security_ref_20261009.sql).
* 2026-10-12		tuan.nguyenvanb		[FIRST-TIME] Snapshot THEO TUNG NGAY (ft_hstr_by_day): moi ngay co csidxinfor = 1 snapshot,
*                                       chi so dung ngay giao dich gan nhat <= ngay snapshot; isin_code/index_nm lay ban ghi gan
*                                       nhat <= ngay (khoang hieu luc LEAD). Them cot ds_snpst_dt. Khong loc etl_date.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

-- [FIRST-TIME 2026-10-12] Snapshot THEO TUNG NGAY (ft_hstr_by_day), khong phu thuoc etl_date.
-- Ngay snapshot D = moi ngay co du lieu JAD_CSIDXINFOR. Tai ngay D, moi chi so dung ngay giao dich GAN NHAT <= D cua
-- chinh no (giong daily: MAX(trading_dt) OVER (PARTITION BY index_code) voi ds_snpst_dt <= etl_date).
-- isin_code / index_nm lay ban ghi GAN NHAT <= D (giong daily: rn = 1 tren lich su <= etl_date).
WITH ics_dedup AS (
    SELECT
        index_code,
        symbol,
        index_constituent_snpst_code,
        index_id,
        floor_code,
        add_dt,
        trading_dt,
        src_stm_code
    FROM (
        SELECT
            a.*,
            a.ticker_symbol AS symbol,
            ROW_NUMBER() OVER (
                PARTITION BY a.index_code, a.ticker_symbol, a.trading_dt
                ORDER BY a.ds_snpst_dt DESC, a.add_dt DESC
            ) AS rn
        FROM {{ ft_ref('ft_atm_index_constituent_snapshot') }} a
        WHERE a.src_stm_code = 'MDDS_JAD_CSIDXINFOR'
    ) t
    WHERE rn = 1
),

snap_days AS (
    SELECT DISTINCT trading_dt AS snpst_dt
    FROM ics_dedup
),

-- Khoang hieu luc ngay giao dich cua tung chi so: [trading_dt, next_trading_dt)
idx_dates AS (
    SELECT
        index_code,
        trading_dt,
        LEAD(trading_dt) OVER (PARTITION BY index_code ORDER BY trading_dt) AS next_trading_dt
    FROM (SELECT DISTINCT index_code, trading_dt FROM ics_dedup) d
),

idx_asof AS (
    SELECT /*+ BROADCAST(sd) */
        sd.snpst_dt,
        i.index_code,
        i.trading_dt
    FROM snap_days sd
    JOIN idx_dates i
        ON  sd.snpst_dt >= i.trading_dt
        AND (i.next_trading_dt IS NULL OR sd.snpst_dt < i.next_trading_dt)
),

ics AS (
    SELECT
        a.snpst_dt,
        c.index_code,
        c.symbol,
        c.index_constituent_snpst_code,
        c.index_id,
        c.floor_code,
        c.add_dt,
        c.trading_dt,
        c.src_stm_code
    FROM idx_asof a
    JOIN ics_dedup c
        ON  c.index_code = a.index_code
        AND c.trading_dt = a.trading_dt
),

-- isin_code: ban ghi cuoi ngay cua ma, hieu luc den ngay co ban ghi tiep theo
se_tr_sn_day AS (
    SELECT symbol, isin_code, ds_snpst_dt AS from_dt
    FROM (
        SELECT
            ticker_symbol AS symbol,
            isin_code,
            ds_snpst_dt,
            row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) AS rn
        FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
        WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'
    ) x
    WHERE rn = 1
),

se_tr_sn AS (
    SELECT
        symbol,
        isin_code,
        from_dt,
        LEAD(from_dt) OVER (PARTITION BY symbol ORDER BY from_dt) AS to_dt
    FROM se_tr_sn_day
),

-- index_nm: ban ghi cuoi ngay cua chi so, hieu luc den ngay co ban ghi tiep theo
ma_in_sn_day AS (
    SELECT market_code, index_nm, trading_dt AS from_dt
    FROM (
        SELECT
            market_code,
            index_nm,
            trading_dt,
            row_number() over (partition by market_code, trading_dt order by index_time desc, sequence desc) AS rn
        FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
        WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
    ) x
    WHERE rn = 1
),

ma_in_sn AS (
    SELECT
        market_code,
        index_nm,
        from_dt,
        LEAD(from_dt) OVER (PARTITION BY market_code ORDER BY from_dt) AS to_dt
    FROM ma_in_sn_day
)

SELECT
    CAST(ics.index_code AS string)                    AS index_code,
    CAST(ics.symbol AS string)                        AS symbol,
    CAST(ics.index_constituent_snpst_code AS string)  AS index_constituent_snpst_code,
    CAST(ics.index_id AS string)                      AS index_id,
    CAST(ma_in_sn.index_nm AS string)                 AS index_nm,
    CAST(ics.floor_code AS string)                    AS floor_code,
    CAST(ics.add_dt AS date)                          AS add_dt,
    CAST(ics.trading_dt AS date)                      AS as_of_dt,
    CAST(se_tr_sn.isin_code AS string)                AS isin_code,
    CAST(ics.src_stm_code AS string)                  AS src_stm_code,
    CAST(ics.snpst_dt AS date)                        AS ds_snpst_dt
FROM ics
LEFT JOIN se_tr_sn
    ON  se_tr_sn.symbol = ics.symbol
    AND ics.snpst_dt >= se_tr_sn.from_dt
    AND (se_tr_sn.to_dt IS NULL OR ics.snpst_dt < se_tr_sn.to_dt)
LEFT JOIN ma_in_sn
    ON  ma_in_sn.market_code = ics.index_code
    AND ics.snpst_dt >= ma_in_sn.from_dt
    AND (ma_in_sn.to_dt IS NULL OR ics.snpst_dt < ma_in_sn.to_dt)
