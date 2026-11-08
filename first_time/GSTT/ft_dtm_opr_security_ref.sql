-- [FIRST-TIME] ft_dtm_opr_security_ref: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_opr_security_ref (config ft_target='opr_security_ref', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_security_ref
* Program name: Dtm Opr Security Ref
* Created by: tuan.nguyenvanb
* Created date: 2026-10-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-09		tuan.nguyenvanb		[MOI, theo LLD v4.42 DTM_GSTT_opr_security_ref_MDDS_JAD_STOCKINFOR.csv] Bang tham chieu
*                                       MA CHUNG KHOAN (operational / current-state), 1 dong / symbol, TOAN BO ma co trong
*                                       JAD_STOCKINFOR (khong gioi han ma thuoc ro chi so). Tach tu 6 cot ma CK truoc day nam o
*                                       opr_security_index_constituent_ref (stock_tp_code, stock_floor_code -> floor_code,
*                                       derivative_product_nm, security_class_code -> security_class_nm, industry_code, industry_nm)
*                                       + isin_code, as_of_dt.
*                                       - Driving: atm_security_trading_snapshot (src MDDS_JAD_STOCKINFOR), ban ghi MOI NHAT cua
*                                         symbol (trading_tms DESC) - cung quy tac security_trading_snpst_dim.
*                                       - security_class_nm: nhan tieng Viet, cung quy tac security_trading_snpst_dim.stock_tp_nm.
*                                       - industry_code/industry_nm theo quy tac K_GSTT_2: join public_company (chung quyen dung
*                                         underlying_symbol, trai phieu dung 3 ky tu dau co loc loai tru no cong), CTCK dai chung
*                                         khong co trong IDS -> nganh IDS ma 07000. Doc IDS tai snapshot etl_date (current-state).
*                                       Model scd4a insert theo TEN cot. PK: symbol.
* 2026-10-09		tuan.nguyenvanb		[BACKFILL-UAT-NEW] first_time: doc atm_public_company / atm_securities_company tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc giu o dang comment BACKFILL-UAT-ORIG. [BACKFILL-UAT-NEW]
* 2026-10-12		tuan.nguyenvanb		[FIRST-TIME] Snapshot THEO TUNG NGAY (ft_hstr_by_day): moi ngay co stockinfor = 1 snapshot
*                                       (ma co mat trong ngay, ban ghi cuoi ngay), them cot ds_snpst_dt. Khong loc etl_date.
*                                       Daily doc ds_snpst_dt = etl_date -> ket qua tung ngay trung voi daily.
* 2026-10-16		tuan.nguyenvanb		[LLD v4.49] Them cot security_full_nm (sau symbol) = security_trading_snapshot.security_full_nm
*                                       cua ban ghi moi nhat (cung driving rn=1). scd4a insert theo TEN cot.
* 2026-10-17		tuan.nguyenvanb		[DONG BO atm_securities_company moi] pc_indicator -> pc_ind; provisional_status_code -> provisional_ind (int).
* 2026-10-20		tuan.nguyenvanb		[SUA theo BA] Nhanh phan loai HNX/UPCOM nay ap dung cho floor_code IN ('02','03','04') (them '03' - san phai sinh/DVX):
*                                       stock_tp_code = '4' tren san 03 -> 'Phai sinh' (truoc day san 03 roi ELSE 'Khac'). Chi doi gia tri nhan, khong doi cot/kieu, khong can ALTER.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. Khong doi cot/kieu.
* 2026-10-23		tuan.nguyenvanb		Doi nguon nganh: atm_cl_business_line (ECAT_BUSINESS_LINE_LEVEL_1) -> atm_cl_ids_business_line (IDS_CATEGORIES).
*                                       Bo dieu kien active_ind (entity moi khong co cot nay). Dong bo voi dtm_opr_security_ref.
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        full_nm AS security_full_nm,   -- [2026-10-16 LLD v4.49]
        isin_code,
        ds_snpst_dt AS trading_dt,   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
        stock_tp_code,
        floor_code,
        underlying_symbol,
        fund_tp_code,
        src_stm_code,
        -- [FIRST-TIME 2026-10-09] row_number() over (partition by symbol order by trading_tms desc, sequence desc) AS rn
        row_number() over (partition by ticker_symbol, ds_snpst_dt order by trading_time desc, sequence desc) AS rn   -- [FIRST-TIME 2026-10-12] 1 ban ghi / ma / NGAY (snapshot tung ngay, giong daily)
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    -- [FIRST-TIME 2026-10-09] WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE src_stm_code = 'MDDS_JAD_STOCKINFOR'   -- [FIRST-TIME 2026-10-12] toan bo lich su, khong phu thuoc etl_date
),

se_tr_sn AS (
    SELECT
        symbol,
        security_full_nm,   -- [2026-10-16 LLD v4.49]
        isin_code,
        trading_dt,
        stock_tp_code,
        floor_code,
        underlying_symbol,
        fund_tp_code,
        src_stm_code,
        -- Khoa join public_company theo K_GSTT_2: trai phieu (stock_tp_code='1') dung 3 ky tu dau
        -- (loai tru no cong/dia phuong, cung bo loc voi dtm_fct_stock_portfolio_snpst); chung quyen
        -- (stock_tp_code='4' tren san 02/04/10) dung underlying_symbol; con lai dung symbol.
        CASE
            WHEN stock_tp_code = '1'
                 AND NOT (
                     symbol RLIKE '^[A-Za-z]{2}GB'
                     OR symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
                     OR symbol RLIKE '^(HCM|HAN)'
                 ) THEN SUBSTR(symbol,1,3)
            WHEN stock_tp_code <> '1' AND floor_code IN ('02','04','10') AND stock_tp_code = '4' THEN underlying_symbol
            WHEN stock_tp_code <> '1' THEN symbol
        END AS company_join_symbol
    FROM se_tr_sn_all
    WHERE rn = 1
),

-- 1 cong ty / equity_ticker_symbol (nguon co ticker gan >1 pc_id): uu tien id nguon nho nhat, order theo
-- pc_code (id nguon that), KHONG order theo pc_id (surrogate hash).
pu_co_all AS (
    SELECT
        equity_ticker_symbol,
        business_line_level_1_id,
        business_line_level_1_code,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint) ASC) AS rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW]
    WHERE equity_ticker_symbol IS NOT NULL AND pc_code IS NOT NULL
        -- [BACKFILL-UAT-ORIG] AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

pu_co AS (
    SELECT equity_ticker_symbol, business_line_level_1_id, business_line_level_1_code
    FROM pu_co_all
    WHERE rn = 1
),

cl_bl AS (
    SELECT
        cl_ids_business_line_id,
        cl_ids_business_line_code,
        cl_ids_business_line_nm
    FROM {{ ref('atm_cl_ids_business_line') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

-- Nganh IDS ma 07000 - fallback cua CTCK dai chung khong co trong IDS (BA 2026-10-07, O_GSTT_37)
cl_bl_ctck AS (
    SELECT cl_ids_business_line_code, cl_ids_business_line_nm
    FROM cl_bl
    WHERE cl_ids_business_line_code = '07000'
    LIMIT 1
),

-- CTCK dai chung (SCMS.SC_FIRM_INFO.PUBLIC_COMPANY = 1, khong o trang thai tam), khop theo
-- UPPER(TRIM(securities_code)); dedupe 1 dong / ma de khong nhan dong khi LEFT JOIN.
sc_ctck_all AS (
    SELECT
        UPPER(TRIM(securities_code)) AS symbol_key,
        sc_code,
        row_number() over (partition by UPPER(TRIM(securities_code)) order by sc_code) AS rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_securities_company') }}_hstr
    FROM {{ ref('atm_securities_company') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND pc_ind = 1
        AND (provisional_ind = 0 OR provisional_ind IS NULL)
        AND securities_code IS NOT NULL
),

sc_ctck AS (
    SELECT symbol_key, sc_code
    FROM sc_ctck_all
    WHERE rn = 1
)

SELECT
    CAST(se_tr_sn.symbol AS string)                   AS symbol,
    CAST(se_tr_sn.security_full_nm AS string)         AS security_full_nm,   -- [2026-10-16 LLD v4.49]
    CAST(se_tr_sn.isin_code AS string)                AS isin_code,
    CAST(se_tr_sn.trading_dt AS date)                 AS as_of_dt,
    CAST(se_tr_sn.stock_tp_code AS string)            AS stock_tp_code,
    CAST(se_tr_sn.floor_code AS string)               AS floor_code,
    CAST(NULLIF(
        CASE WHEN se_tr_sn.floor_code IN ('02','04','03')
             THEN CONCAT_WS('',
                    CASE WHEN se_tr_sn.stock_tp_code = '4' THEN 'HĐTL' END,
                    CASE WHEN se_tr_sn.underlying_symbol IN ('GB05','GB10') THEN 'TPCP' ELSE se_tr_sn.underlying_symbol END)
        END, '') AS string)                           AS derivative_product_nm,
    CAST(CASE
        WHEN se_tr_sn.floor_code = '10' THEN
            CASE WHEN se_tr_sn.stock_tp_code = '1' THEN 'Trái phiếu'
                 WHEN se_tr_sn.stock_tp_code = '2' THEN 'Cổ phiếu'
                 WHEN se_tr_sn.stock_tp_code = '3' AND se_tr_sn.fund_tp_code = 'E' THEN 'ETF'
                 WHEN se_tr_sn.stock_tp_code = '3' AND se_tr_sn.fund_tp_code = 'M' THEN 'Chứng chỉ quỹ'
                 WHEN se_tr_sn.stock_tp_code = '4' THEN 'Chứng quyền'
                 ELSE 'Khác' END
        WHEN se_tr_sn.floor_code IN ('02','03','04') THEN   -- [2026-10-20 BA] them san 03 (phai sinh)
            CASE WHEN se_tr_sn.stock_tp_code = '1' THEN 'Trái phiếu'
                 WHEN se_tr_sn.stock_tp_code = '2' THEN 'Cổ phiếu'
                 WHEN se_tr_sn.stock_tp_code = '3' THEN 'Chứng chỉ quỹ'
                 WHEN se_tr_sn.stock_tp_code = '4' THEN 'Phái sinh'
                 WHEN se_tr_sn.stock_tp_code = '5' THEN 'Chứng quyền'
                 WHEN se_tr_sn.stock_tp_code = '6' THEN 'ETF'
                 ELSE 'Khác' END
        ELSE 'Khác'
    END AS string)                                    AS security_class_nm,
    CAST(COALESCE(NULLIF(TRIM(pu_co.business_line_level_1_code), ''),
                  CASE WHEN sc_ctck.sc_code IS NOT NULL THEN cl_bl_ctck.cl_ids_business_line_code END) AS string) AS industry_code,
    CAST(COALESCE(NULLIF(TRIM(cl_bl_pc.cl_ids_business_line_nm), ''),
                  CASE WHEN sc_ctck.sc_code IS NOT NULL THEN NULLIF(TRIM(cl_bl_ctck.cl_ids_business_line_nm), '') END) AS string) AS industry_nm,
    CAST(se_tr_sn.src_stm_code AS string)             AS src_stm_code,
    CAST(se_tr_sn.trading_dt AS date)                 AS ds_snpst_dt   -- [FIRST-TIME 2026-10-12] ngay snapshot (ft_hstr_by_day)
FROM se_tr_sn
LEFT JOIN pu_co
    ON pu_co.equity_ticker_symbol = se_tr_sn.company_join_symbol
LEFT JOIN cl_bl cl_bl_pc
    ON cl_bl_pc.cl_ids_business_line_id = pu_co.business_line_level_1_id
LEFT JOIN sc_ctck
    ON sc_ctck.symbol_key = UPPER(TRIM(se_tr_sn.symbol))
LEFT JOIN cl_bl_ctck
    ON 1 = 1
