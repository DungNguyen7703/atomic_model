/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_major_shareholder_ownership_snpst
* Program name: Dtm Fct Major Shareholder Ownership Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-25		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_major_shareholder_
*                                       ownership_snpst.csv, GSTT Nhom 33] Fact Co dong
*                                       lon, nguon doi tu atm_pc_shareholding (IDS) sang
*                                       atm_major_shareholder_ownership (VSDC), grain 1
*                                       dong / ma CK / co dong lon. So voi 1 ky truoc/1 ky
*                                       sau (opening/closing) de chon dung so lieu tai ngay
*                                       tham so (:etl_date) - neu etl_date >= ngay cuoi ky
*                                       thi lay so cuoi ky, con >= ngay dau ky thi lay so
*                                       dau ky; khong khop ky nao thi bi loai (khong xuat
*                                       hien trong fact). Dedupe theo (ticker_symbol,
*                                       identification_nbr) - lay snapshot moi nhat co
*                                       ds_snpst_dt <= etl_date (atm_major_shareholder_
*                                       ownership la incremental/snapshot, khong phai
*                                       ngay nao cung co dong moi cho moi co dong).
*                                       [DA FIX cung ngay] Cot position_code (chuc vu nguoi
*                                       noi bo, K_GSTT_104) can noi qua ip_alternative_
*                                       identification voi src_stm_code='IDS_IDENTITY' - luc
*                                       dau atm_ip_alternative_identification KHONG CO nhanh
*                                       nguon nay (chi co FIMS/FMS/NHNCK/SCMS). Da phat hien
*                                       ods_ids_identity da co san (chua duoc boc thanh
*                                       atomic) va bo sung nhanh moi atm_ip_alternative_
*                                       identification_ids_identity vao union - xem file do
*                                       va atm_ip_alternative_identification.sql.
* 2026-09-28		tuan.nguyenvanb		[DOI KIEN TRUC] Bo dedup equity_ticker o ODS
*                                       (ods_ids_company_profiles.sql) - ODS/atomic gio lay
*                                       nguyen ban ghi nguon, ke ca truong hop 1 ticker gan
*                                       nhieu pc_id (vd BID: id=266/10174 cung active). Dedup
*                                       chuyen xuong dung tai day: CTE pu_co (dedup theo
*                                       equity_ticker_symbol, uu tien pc_id nho nhat) - dung
*                                       chung cho ca position_active va pu_co_di, dam bao
*                                       khong nhan doi dong va khong chon nham 2 cong ty khac
*                                       nhau cho cung 1 ticker.
* 2026-09-30		tuan.nguyenvanb		[SUA theo LLD 2026-09-30, O_GSTT_50] BO 2 cot cap cong ty
*                                       current_foreign_holding_quantity (K_GSTT_120) va
*                                       domestic_holding_quantity (K_GSTT_121) - gay lap lai
*                                       theo tung co dong; chuyen sang REUSE Fact Public
*                                       Company Foreign Ownership Snapshot (NDTNN). Bo CTE
*                                       foreign_own_ranked/foreign_own va LEFT JOIN tuong ung.
*                                       closing_ownership_ratio (K_GSTT_178) da co san tu
*                                       2026-09-25 - khong doi. CAN ALTER TABLE DROP COLUMN
*                                       o mart + ClickHouse flat (xem scratch/deploy_gstt_ddl_20260930.sql).
* 2026-10-01		tuan.nguyenvanb		[SUA theo LLD 2026-10-01, BA dong 506-508, GSTT Nhom 35]
*                                       Co che AS-OF THEO TUNG MA CK cho K_GSTT_102/103/177:
*                                       moc ky cua tung co dong = closing_balance_date neu
*                                       <= etl_date, nguoc lai opening_balance_date neu <=
*                                       etl_date (khong ky nao <= etl_date -> loai). asof cua
*                                       ma = MAX(moc ky) OVER (PARTITION BY ticker_symbol);
*                                       CHI GIU cac co dong co moc ky = asof cua ma do (truoc
*                                       day chi can etl_date >= opening_balance_date theo tung
*                                       co dong rieng le). Cot dau ra KHONG doi -> khong can
*                                       ALTER TABLE mart / ClickHouse. Bo K_GSTT_103b (BA khong
*                                       con dong nay); K_GSTT_104 khai sinh sang Nhom 38, cot
*                                       position_code van giu (backward-compatible).
* 2026-10-02		tuan.nguyenvanb		[FIX check-loi-so-lieu, K_GSTT_102/103/177, PNG] BO
*                                       ROW_NUMBER()...rn=1 pre-dedupe theo ds_snpst_dt (cu la
*                                       CTE mj_sh_ranked). Phat hien atm_major_shareholder_
*                                       ownership (pass-through tu ods_vsdc_major_shareholder,
*                                       loc ds_snpst_dt=etl_date) moi build NAP LAI TOAN BO cac
*                                       dong-ky lich su (hang tram ky/co dong, tu 2022 den hien
*                                       tai) - TAT CA cung mang 1 gia tri ds_snpst_dt (ngay
*                                       build), KHONG PHAI "1 dong/co dong/ngay" nhu comment cu
*                                       gia dinh. ORDER BY ds_snpst_dt DESC khi moi dong deu TIE
*                                       chon rn=1 GAN NHU NGAU NHIEN trong hang tram ky ung vien
*                                       -> buoc loc as-of (mj_sh_period/asof) chi con chay tren
*                                       1 dong da-bi-chon-sai, ra sai ky (vd PNG ra ky 2022-07-01
*                                       thay vi dung ky 2026-08-27). Fix: cho TOAN BO dong-ky di
*                                       thang vao mj_sh_period de tinh asof_period_dt, roi moi
*                                       loc dung ky o mj_sh. KHONG them dedupe nao khac theo yeu
*                                       cau nguoi dung (van con truong hop hiem 2 ban ghi nguon
*                                       trung vat ly cho cung id_number - gia tri giong het nhau
*                                       nen khong anh huong so lieu, xem skill check-loi-so-lieu).
* 2026-10-02 (#2)	tuan.nguyenvanb		[FIX tiep, phat hien sau khi bo dedupe hoan toan ra 10
*                                       dong thay vi 5 nhu BA] atm_major_shareholder_ownership
*                                       build lai TOAN BO lich su MOI LAN CHAY - nhieu etl_date
*                                       (vd 2026-08-05 va 2026-08-24) deu tao ra 1 partition
*                                       ds_snpst_dt rieng NHUNG chua y het cung 1 ky dung asof ->
*                                       nhan doi dong neu khong gop lai theo build. Them lai CTE
*                                       mj_sh_ranked NHUNG dat SAU buoc loc dung ky (khac ban cu:
*                                       ban cu dedupe TRUOC gay chon sai ky) - dedupe theo
*                                       (ticker_symbol, identification_nbr, issue_dt) de GOP
*                                       partition build trung lap nhung VAN GIU truong hop 2 ban
*                                       ghi nguon trung-nhau-khac-issue_dt (BA cung dang khong
*                                       dedupe truong hop nay) - ra dung 5 dong khop BA.
* 2026-10-15		tuan.nguyenvanb		[SUA theo LLD v4.49, GSTT Nhom 35, O_GSTT_54/68] (1) THEM 6
*                                       cot map 1:1 tu atm_major_shareholder_ownership (K_GSTT_359,
*                                       364-367, 369): major_shareholder_identification_nbr,
*                                       opening_share_quantity, opening_ownership_ratio,
*                                       opening_balance_dt, closing_share_quantity,
*                                       closing_balance_dt - khong chon ky theo ngay tham so,
*                                       lay tu dong ky as-of da chon o mj_sh. (2) Data Modeler bo
*                                       dieu kien cham moc theo ma CK cho ownership_share_quantity,
*                                       ownership_ratio, ownership_update_dt: ky as-of tinh THEO
*                                       TUNG CO DONG (PARTITION BY ticker_symbol,
*                                       identification_nbr) thay vi theo ma CK - liet ke moi co
*                                       dong lon. CAN ALTER TABLE ADD COLUMN ... AFTER src_stm_code
*                                       o mart + ClickHouse flat (xem ghi chu ban giao).
* 2026-10-21		tuan.nguyenvanb		[SUA theo BA, K_GSTT_366] Chon ky as-of CHI THEO NGAY KY (closing/opening_balance_date <= ngay), khong loai ky theo
*                                       ngay nap (ds_snpst_dt/avail_dt). Truoc day cac ky nap don 1 lan vao snapshot 2026-10-19 bi loai o moi ngay < 10-19 -> flat ra ky cu 2026-08-27.
*                                       Cung ky xuat hien o nhieu snapshot thi lay snapshot moi nhat (rn). Khong doi cot/kieu/vi tri.
*--------------------------------------------------------------------*
*/

-- [SUA 2026-10-02] BO rn=1 pre-dedupe theo ds_snpst_dt (cu la mj_sh_ranked): atm_major_shareholder_
-- ownership moi ngay nap lai TOAN BO cac dong-ky lich su (hang tram ky/co dong), tat ca CUNG mang 1
-- gia tri ds_snpst_dt (ngay build) - KHONG phai "1 dong/co dong/ngay" nhu gia dinh cu. ORDER BY
-- ds_snpst_dt DESC khi moi dong deu TIE se chon rn=1 GAN NHU NGAU NHIEN trong hang tram ky ung vien,
-- khien buoc loc as-of ben duoi chi con chay tren 1 dong da-bi-chon-sai truoc do. Fix: cho TOAN BO
-- dong-ky di thang vao buoc tinh asof_period_dt, khong dedupe truoc.
WITH mj_sh_period AS (
    SELECT
        m.*,
        CASE
            WHEN closing_balance_date <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN closing_balance_date
            WHEN opening_balance_date <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN opening_balance_date
        END AS asof_period_dt
    FROM {{ ref('atm_major_shareholder_ownership') }} m
    -- [2026-10-21 BA] bo loc ds_snpst_dt <= etl_date: ky as-of chi theo ngay ky (xem asof_period_dt)
),

mj_sh_asof AS (
    SELECT
        mj_sh_period.*,
        -- [SUA 2026-10-15 LLD v4.49] ky as-of theo TUNG CO DONG (bo dieu kien cham moc theo ma CK)
        MAX(asof_period_dt) OVER (PARTITION BY ticker_symbol, identification_nbr) AS ticker_asof_dt
    FROM mj_sh_period
),

-- [SUA 2026-10-02 #2] atm_major_shareholder_ownership build lai TOAN BO lich su moi lan chay
-- -> nhieu etl_date khac nhau (vd 2026-08-05 va 2026-08-24) deu co ds_snpst_dt <= etl_date VA
-- CUNG chua y het 1 ky dung asof -> nhan doi dong NEU khong gop lai theo partition build. Dedupe
-- O DAY (SAU khi da loc dung ky, KHONG truoc nhu ban cu mj_sh_ranked) theo (ticker_symbol,
-- identification_nbr, issue_dt) - CO them issue_dt de KHONG xoa truong hop 2 ban ghi nguon
-- trung nhau nhung khac issue_dt (xem skill check-loi-so-lieu, case PNG) - BA dang KHONG dedupe
-- truong hop nay nen van dem ca 2, giu dung khac theo BA.
mj_sh_ranked AS (
    SELECT
        mj_sh_asof.*,
        ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, identification_nbr, issue_dt
            ORDER BY ds_snpst_dt DESC
        ) AS rn
    FROM mj_sh_asof
    WHERE asof_period_dt IS NOT NULL
        AND asof_period_dt = ticker_asof_dt
),

mj_sh AS (
    SELECT *
    FROM mj_sh_ranked
    WHERE rn = 1
),

-- [SUA 2026-09-28] ODS/atomic khong con dedup theo equity_ticker (xem ods_ids_company_
-- profiles.sql) - nguon co truong hop >1 pc_id cung gan 1 equity_ticker (vd BID: id=266
-- va id=10174 cung active). Dedup ngay tai pu_co: 1 dong/equity_ticker, uu tien id nguon
-- nho nhat. CHU Y: order theo pc_code (CAST(co_pr.id AS string) - id nguon that, xem atm_
-- public_company.sql), KHONG order theo pc_id (surrogate key hash generate_surrogate_
-- key_bigint(...), khong con thu tu tuong ung voi id nguon). pu_co_di PHAI join qua
-- pu_co.pc_code (khong tu dedup rieng theo equity_ticker_symbol) de dam bao dtm_public_
-- company_dim tra ve DUNG 1 cong ty da chon o pu_co - tranh truong hop pu_co va pu_co_di
-- chon nham 2 cong ty khac nhau cho cung 1 ticker.
pu_co_all AS (
    SELECT
        pc_id,
        pc_code,
        equity_ticker_symbol,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint) ASC) as rn
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

pu_co AS (
    SELECT pc_id, pc_code, equity_ticker_symbol
    FROM pu_co_all
    WHERE rn = 1
),

pu_co_di AS (
    SELECT
        public_company_dim_id,
        public_company_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- [GAP xem ghi chu dau file] atm_ip_alternative_identification hien khong co nhanh
-- IDS_IDENTITY - JOIN nay se luon khong khop (position_code luon rong) cho toi khi nguon
-- duoc bo sung, nhung giu dung cau truc LLD (noi qua identification_nbr + ticker_symbol
-- cua CHINH dong co dong do) de tu dong hoat dong sau nay.
ip_alt_id AS (
    SELECT identification_nbr, ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}
    WHERE src_stm_code = 'IDS_IDENTITY'
),

position_active AS (
    SELECT
        m.ticker_symbol,
        m.identification_nbr,
        lep.position_code
    FROM mj_sh m
    INNER JOIN ip_alt_id ia
        ON ia.identification_nbr = m.identification_nbr
    INNER JOIN pu_co
        ON pu_co.equity_ticker_symbol = m.ticker_symbol
    INNER JOIN {{ ref('atm_legal_entity_position') }} lep
        ON  lep.legal_entity_id = ia.ip_id
        AND lep.pc_id = pu_co.pc_id
        AND (lep.appointment_dt IS NULL OR lep.appointment_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
        AND (lep.dismissal_dt IS NULL OR lep.dismissal_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

position_agg AS (
    SELECT ticker_symbol, identification_nbr, collect_set(position_code) AS position_code
    FROM position_active
    GROUP BY ticker_symbol, identification_nbr
)

SELECT
    CAST(date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)                                          AS public_company_dim_id,
    CAST(mj_sh.ticker_symbol AS string)                                                     AS ticker_symbol,
    CAST(mj_sh.major_shareholder_ownership_id AS string)                                     AS major_shareholder_ownership_id,
    CAST(mj_sh.major_shareholder_nm AS string)                                               AS major_shareholder_nm,
    CAST(
        CASE
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.closing_balance_date THEN mj_sh.closing_share_quantity
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.opening_balance_date THEN mj_sh.opening_share_quantity
        END AS bigint)                                                                      AS ownership_share_quantity,
    CAST(
        CASE
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.closing_balance_date THEN mj_sh.closing_ratio
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.opening_balance_date THEN mj_sh.opening_ratio
        END AS decimal(7,4))                                                                AS ownership_ratio,
    CAST(mj_sh.closing_ratio AS decimal(7,4))                                                AS closing_ownership_ratio,
    CAST(
        CASE
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.closing_balance_date THEN mj_sh.closing_balance_date
            WHEN to_date('{{ var("etl_date") }}','yyyy-MM-dd') >= mj_sh.opening_balance_date THEN mj_sh.opening_balance_date
        END AS date)                                                                        AS ownership_update_dt,
    COALESCE(position_agg.position_code, array())                                            AS position_code,
    CAST(mj_sh.src_stm_code AS string)                                                       AS src_stm_code,
    CAST(mj_sh.identification_nbr AS string)                                                 AS major_shareholder_identification_nbr,
    CAST(mj_sh.opening_share_quantity AS bigint)                                             AS opening_share_quantity,
    CAST(mj_sh.opening_ratio AS decimal(7,4))                                                AS opening_ownership_ratio,
    CAST(mj_sh.opening_balance_date AS date)                                                 AS opening_balance_dt,
    CAST(mj_sh.closing_share_quantity AS bigint)                                             AS closing_share_quantity,
    CAST(mj_sh.closing_balance_date AS date)                                                 AS closing_balance_dt
FROM mj_sh
LEFT JOIN pu_co
    ON pu_co.equity_ticker_symbol = mj_sh.ticker_symbol
LEFT JOIN pu_co_di
    ON pu_co_di.public_company_code = pu_co.pc_code
LEFT JOIN position_agg
    ON  position_agg.ticker_symbol = mj_sh.ticker_symbol
    AND position_agg.identification_nbr = mj_sh.identification_nbr
