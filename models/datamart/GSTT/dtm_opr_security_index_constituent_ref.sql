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
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

WITH ics_all AS (
    SELECT
        index_code,
        ticker_symbol AS symbol,
        index_constituent_snpst_code,
        index_id,
        floor_code,
        add_dt,
        trading_dt,
        ds_snpst_dt,
        src_stm_code,
        MAX(trading_dt) OVER (PARTITION BY index_code) AS max_trading_dt
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_CSIDXINFOR'
        AND ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

ics AS (
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
            ROW_NUMBER() OVER (
                PARTITION BY a.index_code, a.symbol
                ORDER BY a.ds_snpst_dt DESC, a.add_dt DESC
            ) AS rn
        FROM ics_all a
        WHERE a.trading_dt = a.max_trading_dt
    ) t
    WHERE rn = 1
),

-- Ban ghi MOI NHAT cua symbol trong Security Trading Snapshot (cung quy tac security_trading_snpst_dim)
-- chi dung cho isin_code (cac cot khac cua ma CK da chuyen sang opr_security_ref).
se_tr_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        isin_code,
        row_number() over (partition by ticker_symbol order by ds_snpst_dt desc, trading_time desc, sequence desc) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

se_tr_sn AS (
    SELECT symbol, isin_code
    FROM se_tr_sn_all
    WHERE rn = 1
),

ma_in_sn_all AS (
    SELECT
        market_code,
        index_nm,
        row_number() over (partition by market_code order by trading_dt desc, index_time desc, sequence desc) AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_MARKETINFOR'
),

ma_in_sn AS (
    SELECT market_code, index_nm
    FROM ma_in_sn_all
    WHERE rn = 1
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
    CAST(ics.src_stm_code AS string)                  AS src_stm_code
FROM ics
LEFT JOIN se_tr_sn
    ON se_tr_sn.symbol = ics.symbol
LEFT JOIN ma_in_sn
    ON ma_in_sn.market_code = ics.index_code
