/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_corporate_bond_sector_snpst
* Program name: Fact Corporate Bond Sector Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		Design/BA cap nhat LLD lan 1 (gui note hoi design) - thu code
*									khoa join qua issuer_nm (bond_snpst <-> eq_snpst cung issuer_nm,
*									eq_snpst loc floor_code IN ('02','04','10') roi moi JOIN
*									public_company.equity_ticker_symbol). SAU DO phat hien day moi
*									chi la 1 nhanh local/draft (commit c69788dd cua dong nghiep) dang
*									xung dot voi ban chinh thuc tren remote (commit 074c2d92, nhan
*									"BA xac nhan 2026-10-02") khi user chay git pull. Da git reset
*									--hard origin/main theo yeu cau user (user khong thuoc team design,
*									khong tu quyet dinh merge) -> lay dung ban CHINH THUC cuoi cung.
* 2026-10-02		tuan.nguyenvanb		[BAN CHINH THUC] Doi chieu lai DTM_PTTT_fct_corporate_bond_sector_snpst.csv
*									sau khi da dong bo dung commit 074c2d92 tren origin/main: khoa join
*									TCPH <-> ma TP DON GIAN HON ban draft truoc - KHONG co buoc eq_snpst/
*									issuer_nm nao ca, JOIN THANG public_company.equity_ticker_symbol =
*									bond_snpst.symbol (BA xac nhan truc tiep bond symbol = equity ticker
*									symbol, khong can di qua issuer_nm). Sua lai code cho dung ban nay -
*									BO CTE eq_raw/eq_snpst_last/eq_snpst_dedup (khong con can thiet),
*									bo cot issuer_nm khoi bond_raw/bond_snpst (khong con dung).
*									Giu nguyen phan bond_outstanding_val_total: SUM DOC LAP tren toan bo
*									bond_snpst (ca ma TP chua khop nganh), dung SQL BA Nhom 20. KHONG
*									doi cot output (van 3 cot bond_outstanding_val/_total/_ratio nhu cu)
*									nen KHONG can ALTER TABLE, KHONG can sua ClickHouse flat model.
* 2026-10-05		tuan.nguyenvanb		Design cap nhat LLD (commit 768dd18b, BA HNX Nhom 18-21, O_PTTT_36):
*									(1) loc trai phieu stock_tp_code = '1' + loai TP Chinh phu/dia phuong
*									(regex ^[A-Za-z]{2}GB, ^(TD|TP|CP|QH|KB|BL), ^(HCM|HAN)) - thay IN ('B','1','D');
*									(2) khoa join TCPH: equity_ticker_symbol = SUBSTR(symbol,1,3) (thay cho
*									= symbol); (3) khoi luong luu hanh lay tu atm_listed_share_information
*									(src HNX_LISTED_SECURITIES_LIST, listed_share_quantity, INNER JOIN
*									ticker_symbol = symbol AND ds_snpst_dt = trading_dt) thay cho
*									total_listing_vol cua JAD_STOCKINFOR; bond_outstanding_val_total cung tinh
*									tren tap nay. Cot output KHONG doi -> khong can ALTER. Luu y O_PTTT_36: HLD
*									danh dau cot HNX outstanding_shares "chua xac nhan" (KPI PENDING) - atomic
*									atm_listed_share_information_hnx_listed_securities_list DA map outstanding_shares
*									tu ODS, can dam bao nguon HNX nap theo ngay thi moi co du lieu.
*--------------------------------------------------------------------*
* Ghi chu:
* - [2026-10-02 - BAN CHINH THUC] Khoa join TCPH <-> ma TP theo dung LLD
*   (dong 3 cua CSV): KHONG dung bond_ticker_symbol nua (chua tung duoc BA
*   xac nhan). JOIN THANG public_company.equity_ticker_symbol =
*   bond_snpst.symbol - BA xac nhan truc tiep (2026-10-02) rang ma trai
*   phieu (bond symbol) CHINH LA ma co phieu niem yet (equity ticker) cua
*   TCPH do, KHONG can bang trung gian nao. Cot equity_ticker_symbol da ton
*   tai san trong atm_public_company (grep xac nhan, khong can them cot
*   atomic moi).
*   Dedup CHI 1 cho: bond_snpst = ROW_NUMBER() PARTITION BY symbol ORDER BY
*   trading_time DESC = 1 (1 ban ghi/ma TP/ngay - ban ghi cuoi phien).
*   joined (ma TP <-> nganh) VAN la INNER JOIN (ma TP khong khop duoc TCPH/
*   nganh thi KHONG the xep vao nganh nao - dung ban chat "theo nganh" cua
*   bang nay), nhung bond_outstanding_val_total (mau so Ty trong) duoc tinh
*   DOC LAP tren bond_snpst (khong qua join), nen VAN gom du ca cac ma TP
*   chua khop duoc nganh - xem CTE mkt_total.
* - atm_public_company duoc materialize theo strategy SCD4A nen phai doc
*   tu bang phu _hstr va loc chuan ds_snpst_dt/ds_rcrd_st/src_stm_code.
* - corp_bond_industry_dim la model dimension da build lai o buoc 3.1,
*   join truc tiep vao bang hien hanh (khong phai _hstr) theo
*   industry_code = business_line_level_1_code, kem dieu kien
*   ds_rcrd_st = 'ACTIVE' de chi lay ban ghi nganh dang hieu luc.
* - Menh gia trai phieu 100000 la hardcode theo business rule da chot
*   (giong quy uoc dang dung o opr_corporate_bond_issuer_credit_monitor.sql).
* - [Van con ton tai, chua resolve] Bang phan loai stock_tp_code chinh thuc
*   do BA cung cap cho thay HNX/UPCOM dung ma nguon goc "BO" chu khong phai
*   'B' truoc khi chuan hoa - CAN BA/Data Modeler xac nhan cot
*   atm_security_trading_snapshot.stock_tp_code dang luu gia tri DA CHUAN
*   HOA hay RAW theo tung san (LLD lan nay khong de cap lai diem nay, van
*   giu nguyen dieu kien loc IN ('B','1','D') nhu cu).
*--------------------------------------------------------------------*
* 2026-10-05b			tuan.nguyenvanb		LLD (commit 96bfadb3): cot khoi luong HNX doi tu outstanding_share_quantity
*									sang listed_share_quantity (HNX listed_shares - "tam thay outstanding_shares
*									cua BA", O_PTTT_36). Chi doi ten cot nguon, logic giu nguyen. Cot output KHONG
*									doi -> khong can ALTER.
* 2026-10-06			tuan.nguyenvanb		Dev chot: join listed_share_information (HNX) theo SUBSTR(bond_snpst.symbol, 1, 3) thay vi ca ma
*									trai phieu, vi ticker_symbol cua HNX khong khop ma trai phieu day du (join cu ra rong,
*									model tra NULL). Luu y: 1 TCPH co nhieu ma trai phieu se cung khop 1 dong HNX nen khoi
*									luong bi lap theo so ma trai phieu cua TCPH do - can doi chieu voi BA.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-10-28			tuan.nguyenvanb		[FIX] bond_vol: noi lsi_hnx theo MA TRAI PHIEU DAY DU (ticker_symbol = symbol) thay cho SUBSTR(symbol,1,3). HNX_LISTED_SECURITIES_LIST chua ca
*									co phieu (ma 3 ky tu) lan trai phieu; noi 3 ky tu khop nham dong CO PHIEU cung TCPH (so CP x 100.000) -> bond_outstanding_val/_total gap ~221 lan
*									(flat 28.638 nghin ty vs dung ~129,4 nghin ty ngay 2026-10-06). Phep noi sang atm_public_company van SUBSTR(symbol,1,3) = equity_ticker_symbol. Khong doi cot/kieu.
*									[2026-10-29] enriched: LEFT JOIN dtm_corp_bond_industry_dim them loc src_stm_code = 'IDS_CATEGORIES' (tranh nhan dong do ban ghi dim ACTIVE tu nguon cu). Khong doi cot/kieu -> build lai mart + flat.
*/

WITH bond_raw AS (
    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , trading_time
        , sequence
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND stock_tp_code = '1'
        AND NOT (
            ticker_symbol RLIKE '^[A-Za-z]{2}GB'
            OR ticker_symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
            OR ticker_symbol RLIKE '^(HCM|HAN)'
        )
),

bond_snpst AS (
    SELECT
        symbol
        , trading_dt
    FROM (
        SELECT
            bond_raw.*
            , ROW_NUMBER() OVER (
                PARTITION BY bond_raw.symbol
                ORDER BY bond_raw.trading_time DESC, bond_raw.sequence DESC
            ) AS rn
        FROM bond_raw
    ) ranked
    WHERE rn = 1
),

lsi_hnx AS (
    SELECT
        ticker_symbol
        , ds_snpst_dt
        , listed_share_quantity
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'HNX_LISTED_SECURITIES_LIST'
        AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

bond_vol AS (
    SELECT
        bond_snpst.symbol
        , bond_snpst.trading_dt
        , lsi_hnx.listed_share_quantity
    FROM bond_snpst
    INNER JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = bond_snpst.symbol
        AND lsi_hnx.ds_snpst_dt = bond_snpst.trading_dt
),

pu_co AS (
    SELECT
        cl_ids_business_line_level_1_code AS business_line_level_1_code
        , equity_ticker_symbol
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

joined AS (
    SELECT
        bond_vol.trading_dt
        , pu_co.business_line_level_1_code
        , bond_vol.listed_share_quantity
    FROM bond_vol
    INNER JOIN pu_co
        ON pu_co.equity_ticker_symbol = SUBSTR(bond_vol.symbol, 1, 3)
),

agg AS (
    SELECT
        joined.trading_dt
        , joined.business_line_level_1_code
        , SUM(100000 * joined.listed_share_quantity) AS bond_outstanding_val
    FROM joined
    GROUP BY
        joined.trading_dt
        , joined.business_line_level_1_code
),

mkt_total AS (
    SELECT
        bond_vol.trading_dt
        , SUM(100000 * bond_vol.listed_share_quantity) AS bond_outstanding_val_total
    FROM bond_vol
    GROUP BY bond_vol.trading_dt
),

enriched AS (
    SELECT
        CAST(date_format(agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
        CAST(cbi.corp_bond_industry_dim_id AS string)           AS corp_bond_industry_dim_id,
        CAST(agg.bond_outstanding_val AS decimal(23,2))         AS bond_outstanding_val,
        agg.trading_dt
    FROM agg
    LEFT JOIN {{ ref('dtm_corp_bond_industry_dim') }} cbi
        ON cbi.industry_code = agg.business_line_level_1_code
        AND cbi.ds_rcrd_st = 'ACTIVE'
        AND cbi.src_stm_code = 'IDS_CATEGORIES'  -- [2026-10-29] loc src_stm_code: bang dim scd4a chi so sanh/ngung hieu luc ban ghi thuoc source_system IDS_CATEGORIES -> ban ghi cu tu nguon khac (truoc 2026-10-23) van ACTIVE, khong loc se nhan dong
)

SELECT
    enriched.snpst_dt_dim_id,
    enriched.corp_bond_industry_dim_id,
    enriched.bond_outstanding_val,
    CAST(mkt_total.bond_outstanding_val_total AS decimal(23,2)) AS bond_outstanding_val_total,
    CAST(
        enriched.bond_outstanding_val
        / NULLIF(mkt_total.bond_outstanding_val_total, 0)
        * 100
    AS decimal(5,2)) AS bond_outstanding_ratio
FROM enriched
LEFT JOIN mkt_total
    ON mkt_total.trading_dt = enriched.trading_dt
