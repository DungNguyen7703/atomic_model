/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_corporate_bond_issuer_credit_monitor
* Program name: Operational Corporate Bond Issuer Credit Monitor
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-23		tuan.nguyenvanb		Doi chieu LLD moi (DTM_PTTT_opr_corporate_bond_issuer_credit_monitor.csv,
*									cap nhat 2026-09-21): implement 7 cot tai chinh
*									(total_liabilities_amt, owner_equity_ending_amt,
*									owner_equity_beginning_amt, owner_equity_average_amt,
*									net_profit_after_tax_amt, debt_to_equity_ratio, roe_pct)
*									truoc day PENDING -> NAY DA TINH DUOC vi cac atomic model
*									atm_pc_report_submission / atm_fr_value / atm_fr_catalog /
*									atm_fr_row / atm_fr_column DA DUOC XAY DUNG (refactor
*									2026-09-22). Doi ten cot theo dung LLD moi:
*									equity_end_period_amt -> owner_equity_ending_amt,
*									equity_begin_period_amt -> owner_equity_beginning_amt,
*									equity_average_amt -> owner_equity_average_amt,
*									net_profit_amt -> net_profit_after_tax_amt,
*									roe_ratio -> roe_pct (decimal(8,4), truoc la decimal(5,2)).
*									debt_to_equity_ratio doi kieu decimal(5,2) -> decimal(8,2)
*									theo dung LLD moi.
* 2026-09-25		tuan.nguyenvanb		Doi chieu LLD moi lan 2 (file LLD tang 15KB -> 27KB,
*									van giu nguyen 15 cot nhung etl_logic duoc LAM RO chi
*									tiet hon cho toan bo 16 dong). Doi chieu tung dong:
*									KHONG co thay doi cong thuc/dieu kien loc nao so voi
*									code hien tai (bond_outstanding_val/par_val/outstanding_vol,
*									audit_opinion_text, ranking_code, risk_rating_text, 7 cot
*									tai chinh: row_description_reference '300'/'400' (tong no),
*									'400'/'500' (VCSH), '60'/'21' (LNST), column_description_reference
*									'1'/'2' deu GIU NGUYEN). Diem quan trong nhat: LLD moi lan
*									nay VIET TRUC TIEP etl_logic bang chinh ten cot atomic
*									(pc_report_submission.approval_status_code = 'APPROVED',
*									SUBSTR(pc_report_submission.fr_code,1,2)) thay vi ten cot
*									logic (submission_status_code/fr_template_code) nhu truoc
*									-> XAC NHAN CHINH THUC 2 gia dinh mapping o phan "Ghi chu ky
*									thuat cho 7 cot tai chinh" ben duoi (khong con la suy luan
*									tu pattern GSDC nua). Gia dinh ky bao cao (:p_year/:p_month
*									= YEAR/MONTH cua etl_date) VAN CHUA duoc LLD lam ro them
*									(LLD van chi ghi placeholder :p_year/:p_month, khong noi ro
*									gia tri truyen vao) -> GIU NGUYEN gia dinh cu, van can BA
*									xac nhan.
* 2026-10-02		tuan.nguyenvanb		Design/BA cap nhat LLD lan 1 (gui note hoi design) - thu code
*									khoa join qua issuer_nm (bond_snpst <-> eq_snpst cung issuer_nm,
*									eq_snpst loc floor_code IN ('02','04','10') roi moi JOIN
*									public_company.equity_ticker_symbol). SAU DO phat hien day moi
*									chi la 1 nhanh local/draft (commit c69788dd cua dong nghiep) dang
*									xung dot voi ban chinh thuc tren remote (commit 074c2d92, nhan
*									"BA xac nhan 2026-10-02") khi user chay git pull. Da git reset
*									--hard origin/main theo yeu cau user (user khong thuoc team design,
*									khong tu quyet dinh merge) -> lay dung ban CHINH THUC cuoi cung.
* 2026-10-02		tuan.nguyenvanb		[BAN CHINH THUC] Doi chieu lai DTM_PTTT_opr_corporate_bond_issuer
*									_credit_monitor.csv sau khi da dong bo dung commit 074c2d92 tren
*									origin/main: khoa join TCPH <-> ma TP DON GIAN HON ban draft truoc -
*									KHONG co buoc eq_snpst/issuer_nm nao ca, JOIN THANG
*									public_company.equity_ticker_symbol = bond_snpst.symbol (BA xac
*									nhan truc tiep 2026-10-02: bond symbol = equity ticker symbol).
*									Sua lai code cho dung ban nay - BO CTE eq_raw/eq_snpst_last/
*									eq_snpst_dedup (khong con can thiet), bo cot issuer_nm khoi
*									bond_raw/bond_snpst (khong con dung). Giu nguyen LEFT JOIN (khac
*									INNER JOIN truoc 2026-10-02): LLD van ghi ro "[LEFT JOIN - ma TP
*									khong khop duoc TCPH van giu dong, chi tieu TCPH = NULL]" cho CA
*									issuer_symbol_code lan 7 cot tai chinh - grain van la "1 dong /
*									MA TP / ngay" (khong phai 1 dong/TCPH nhu ten goi "per TCPH" trong
*									description co the gay hieu nham). KHONG doi cot output (van 16
*									cot nhu cu) nen KHONG can ALTER TABLE, KHONG can sua ClickHouse
*									flat model.
* 2026-10-05		tuan.nguyenvanb		Design cap nhat LLD (commit 768dd18b, BA HNX Nhom 21, O_PTTT_36):
*									(1) loc trai phieu stock_tp_code = '1' + loai TP Chinh phu/dia phuong
*									(regex ^[A-Za-z]{2}GB, ^(TD|TP|CP|QH|KB|BL), ^(HCM|HAN)) thay IN ('B','1','D');
*									(2) khoa join TCPH: equity_ticker_symbol = SUBSTR(symbol,1,3);
*									(3) bond_outstanding_val/outstanding_vol lay tu atm_listed_share_information
*									(src HNX_LISTED_SECURITIES_LIST, listed_share_quantity, ticker_symbol
*									= symbol AND ds_snpst_dt = trading_dt) thay cho total_listing_vol. LLD chi
*									ghi JOIN lsi o 2 cot nay (PK issuer_symbol_code khong qua lsi) nen dung LEFT
*									JOIN de ma TP khong co dong HNX van giu dong (2 cot = NULL). Cot output
*									KHONG doi -> khong can ALTER. Luu y O_PTTT_36: HLD danh dau KPI dung cot HNX
*									outstanding_shares la PENDING (chua xac nhan) - can nguon HNX nap theo ngay.
*--------------------------------------------------------------------*
* Ghi chu:
* - Da grep toan bo models/atomic/ va XAC NHAN TON TAI day du chuoi atomic
*   phuc vu audit_opinion_text: atm_public_company, atm_pc_evaluation,
*   atm_pc_evaluation_period, atm_pc_evaluation_detail,
*   atm_pc_evaluation_criterion, atm_pc_evaluation_group (tat ca deu
*   materialized: scd4a, rieng atm_pc_evaluation_group la upsert - khong
*   co ds_snpst_dt / khong co bang _hstr, xem mcr_upsert.sql) -> cot nay
*   TINH DUOC, KHONG PENDING.
* - ranking_code: dung atm_pc_bond_evaluation (da xac nhan TON TAI, scd4a)
*   noi truc tiep pc_id + evaluation_year/evaluation_month, KHONG can di
*   qua atm_pc_evaluation/atm_pc_evaluation_period vi
*   atm_pc_bond_evaluation da co san 2 cot nay (khac mo ta trong yeu cau).
* - Ky bao cao (:p_year/:p_month) duoc GIA DINH = YEAR/MONTH cua etl_date,
*   vi model nay khong nhan tham so ngoai va chay theo lich hang ngay/thang
*   cua orchestrator. Day la GIA DINH can xac nhan lai voi nghiep vu.
* - [2026-10-02 - BAN CHINH THUC] Map issuer_symbol_code (ma TP) -> pc_id:
*   KHONG con dung bond_ticker_symbol nua (chua tung duoc BA xac nhan).
*   JOIN THANG bond_snpst.symbol (dedup ban ghi cuoi phien/ma TP) ->
*   public_company.equity_ticker_symbol - BA xac nhan truc tiep (2026-10-02)
*   bond symbol = equity ticker symbol cua TCPH do, KHONG can bang trung
*   gian nao. LEFT JOIN (khac INNER JOIN truoc 2026-10-02) nen 1 ma TP
*   khong xac dinh duoc TCPH VAN xuat hien trong fact, chi cac cot phu
*   thuoc TCPH (audit_opinion_text/ranking_code/risk_rating_text/7 cot tai
*   chinh/debt_to_equity_ratio/roe_pct) la NULL - dung het pattern da ap
*   dung o dtm_fct_corporate_bond_sector_snpst.sql cung ngay.
* - atm_security_trading_snapshot: KHONG dung hau to "_hstr" (khong phai
*   SCD4A), loc truc tiep theo ds_snpst_dt = etl_date, giong quy uoc da
*   xac nhan o dtm_fct_corporate_bond_sector_snpst.sql /
*   dtm_securities_dim.sql.
*--------------------------------------------------------------------*
* Ghi chu ky thuat cho 7 cot tai chinh (CAP NHAT 2026-09-23):
* - Nguon: atm_pc_report_submission (SCD2, ref() TRUC TIEP KHONG co hau to
*   "_hstr" - khac atm_public_company/atm_pc_bond_evaluation vi cac bang do
*   la SCD4A; loc hien hanh bang ds_rcrd_st = 'ACTIVE', KHONG loc theo
*   ds_snpst_dt vi SCD2 khong co cot nay), atm_fr_value (SCD1/Upsert, cung
*   loc ds_rcrd_st = 'ACTIVE'), atm_fr_catalog / atm_fr_row / atm_fr_column
*   (SCD2, cung quy uoc). Convention nay THAM CHIEU DUNG pattern da duoc
*   dung truoc do trong cung ngay (2026-09-23) tai
*   models/datamart/GSTT/dtm_fct_stock_portfolio_snpst.sql (CTE
*   pc_rpt_sub_valid/pc_rpt_sub_dedup_ranked va cac CTE *_by_period).
* - MAP TEN COT LOGIC (LLD) -> TEN COT ATOMIC THUC TE (CAP NHAT 2026-09-25:
*   LLD moi (27KB) da VIET TRUC TIEP etl_logic bang chinh ten cot atomic
*   -> XAC NHAN CHINH THUC, KHONG con la gia dinh/suy luan):
*     + pc_report_submission.submission_status_code -> atm_pc_report_submission.approval_status_code
*       (map tu news_status_cd cua nguon IDS_COMPANY_DATA; gia tri 'APPROVED'
*       da duoc dung dung mau nay o models/datamart/GSDC/dtm_fct_violation_rpt_snpst.sql
*       va dtm_public_company_regulatory_compliance_rpt.sql, va nay da duoc
*       LLD PTTT moi (2026-09-25) XAC NHAN LAI TRUC TIEP -> CHINH THUC DUNG).
*     + pc_report_submission.fr_template_code -> atm_pc_report_submission.fr_code
*       (map tu form.form_cd, gia tri dang 'HN'/'TH'/'ME'/'RI' prefix; da
*       duoc LLD PTTT moi (2026-09-25) XAC NHAN LAI TRUC TIEP -> CHINH THUC DUNG).
* - Logic dedup ky bao cao chuan (dung y het LLD etl_logic cua ca 7 cot,
*   khong them fallback "lui ky hop le" nhu ban GSTT vi LLD khong yeu cau):
*     + rn0: PARTITION BY pc_id, rpt_year, rpt_quarter, uu tien
*       HN(1) > TH(2) > ME(3) > RI(4), roi submission_dt DESC -> chot 1
*       ban ghi nop / ky.
*     + rn1: PARTITION BY pc_id, ORDER BY rpt_year DESC, rpt_quarter DESC
*       -> lay dung ky bao cao GAN NHAT da duoc duyet tinh den etl_date.
* - fr_catalog loc rpt_code LIKE 'BCDKT%' (Bang Can Doi Ke Toan) cho
*   total_liabilities_amt / owner_equity_*, LIKE 'BCKQKD%' (Bao Cao Ket Qua
*   Kinh Doanh) cho net_profit_after_tax_amt; financial_statement_tp_code =
*   SUBSTR(fr_code,1,2) de dam bao dung mau bieu theo dung ky da chot o
*   rn0/rn1.
* - fr_row.row_description_reference phan biet theo enterprise_tp_code:
*     + Tong no phai tra:  DN/BH = '300' , TD = '400'
*     + VCSH:              DN/BH = '400' , TD = '500'
*     + LNST:               DN/BH = '60'  , TD = '21'
*   fr_column.column_description_reference: '1' = cuoi ky, '2' = dau ky.
* - owner_equity_average_amt: neu owner_equity_beginning_amt IS NULL thi
*   lay dung owner_equity_ending_amt (theo dung BA note trong LLD), nguoc
*   lai lay trung binh cong dau ky/cuoi ky.
* - debt_to_equity_ratio = total_liabilities_amt / NULLIF(owner_equity_ending_amt, 0).
* - roe_pct = ROUND(net_profit_after_tax_amt / NULLIF(owner_equity_average_amt, 0) * 100, 4).
* - Dung LEFT JOIN tu "joined" (nhanh chinh theo issuer_symbol_code/snpst_dt)
*   sang fin_ratios theo pc_id -> TCPH chua co ky bao cao tai chinh hop le
*   nao, HOAC ma TP chua xac dinh duoc TCPH (pc_id NULL - xem note 2026-10-02
*   o tren), van xuat hien trong fact (7 cot tai chinh se la NULL), giu dung
*   grain "1 dong / MA TP / ngay" cua bang nay.
* - [Van con ton tai, chua resolve] Bang phan loai stock_tp_code chinh thuc
*   do BA cung cap cho thay HNX/UPCOM dung ma nguon goc "BO" chu khong phai
*   'B' truoc khi chuan hoa - CAN BA/Data Modeler xac nhan cot
*   atm_security_trading_snapshot.stock_tp_code dang luu gia tri DA CHUAN
*   HOA hay RAW theo tung san (LLD lan nay khong de cap lai diem nay, van
*   giu nguyen dieu kien loc IN ('B','1','D') nhu cu - xem chi tiet trong
*   note tai dtm_fct_corporate_bond_sector_snpst.sql).
*--------------------------------------------------------------------*
* 2026-10-05b			tuan.nguyenvanb		LLD (commit 96bfadb3): cot khoi luong HNX doi tu outstanding_share_quantity
*									sang listed_share_quantity (HNX listed_shares - "tam thay outstanding_shares
*									cua BA", O_PTTT_36). Chi doi ten cot nguon, logic giu nguyen. Cot output KHONG
*									doi -> khong can ALTER.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
* 2026-11-06		tuan.nguyenvanb		[DOI MAPPING THEO BA 2 cot audit_opinion_text, risk_rating_text] (1) audit_opinion_text: bo chuoi danh gia TAI_CHINH_YKKT; lay y kien kiem toan tu IDS DATA_VALUES (atm_fr_field_value) loc truong FORM_FIELDS co field_format chua AUDITOR_OPINION (atm_fr_x_fr_field_relationship); gia tri = NVL(lookup_value_vn nhom AUDITOR_OPINION (atomic atm_cl_value schema IDS.AUDITOR_OPINION - nguon IDS.LOOKUP_VALUES) hoac text_val); noi qua pc_rpt_submission_code = atm_pc_report_submission.pc_rpt_submission_code; chi lay ho so APPROVED mau HN/TH/ME/RI quy 5 (BCTC nam) va 6 (ban nien); chon ky co ngay ket thuc moi nhat (nam = 31/12 ban nien = 30/06) roi uu tien HN > TH > ME > RI roi submission_dt moi nhat. (2) risk_rating_text: ranking_code A = Binh thuong; B = Canh bao; NULL = Chua co thong tin; con lai = Rui ro (truoc day nhom Thap/Trung binh/Cao/Chua xep hang). Khong doi ten/kieu/vi tri cot -> khong can ALTER; can build lai mart + flat. Can chay truoc ods_ids_data_values, ods_ids_form_fields, ods_ids_lookup_values, atm_fr_field_value, atm_fr_x_fr_field_relationship, atm_cl_value.
* 2026-11-06		tuan.nguyenvanb		[DOI QUY TAC KY BCTC 7 cot tai chinh THEO BA] Chi lay bao cao cua QUY CHUA NGAY GD (QUARTER cua ngay) neu co; khong co thi lui DUNG 1 QUY (Q1 lui ve Q4 nam truoc); van khong co thi NULL (khong lui tiep). Truoc day lay ky gan nhat da duyet bat ke xa bao nhieu. Cach tinh chi so ky = nam * 4 + quy; uu tien HN > TH > ME > RI trong cung ky va rn1 chon ky moi nhat trong 2 ky nhu cu. Anh huong total_liabilities_amt, owner_equity_*_amt, net_profit_after_tax_amt, debt_to_equity_ratio, roe_pct. Khong doi cot -> khong can ALTER; can build lai mart + flat.
* 2026-11-06b		tuan.nguyenvanb		[CHON KY BCTC THEO CO SO LIEU + THEM COT financial_period_end_dt THEO BA] Moi to chuc phat hanh: neu quy chua ngay co SO LIEU (it nhat 1 trong 4 gia tri tong no, VCSH cuoi ky, VCSH dau ky, LNST khac NULL) thi lay quy do; khong co thi lui DUNG 1 quy va lay len bat ke co so lieu hay khong (khong lui tiep). Thay cho ban truoc chon theo co ho so. Them cot financial_period_end_dt (date) = ngay cuoi quy cua so lieu tren dong (luon co gia tri: quy hien tai neu co so lieu, nguoc lai quy lien truoc), dat SAU roe_pct. Mart scd4a insert theo TEN cot nhung can ALTER ADD COLUMN mart + _hstr; flat ClickHouse insert theo VI TRI nen ALTER ADD COLUMN AFTER roe_pct (xem scratch/alter_pttt_bond_monitor_financial_period_20261106.sql).
*/

WITH bond_raw AS (

    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , trading_time
        , sequence
        , src_stm_code
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
        , src_stm_code
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

pu_co AS (

    SELECT
        pc_id
        , equity_ticker_symbol
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL

),

bond_eval AS (

    SELECT
        pc_id
        , ranking_code
    FROM {{ ref('atm_pc_bond_evaluation') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_EVALUATION_CBONDS'
        AND evaluation_year = YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
        AND evaluation_month = MONTH(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))

),

-- === Y kien kiem toan (IDS DATA_VALUES / FORM_FIELDS / LOOKUP_VALUES) - theo BA 2026-11-06 ===
audit_field AS (

    SELECT fr_x_fr_field_rltnp_id
    FROM {{ ref('atm_fr_x_fr_field_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORM_FIELDS'
        AND field_format LIKE '%AUDITOR_OPINION%'

),

audit_val AS (

    SELECT
        fv.pc_rpt_submission_code
        , fv.text_val
    FROM {{ ref('atm_fr_field_value') }} fv
    INNER JOIN audit_field
        ON audit_field.fr_x_fr_field_rltnp_id = fv.fr_x_fr_field_rltnp_id
    WHERE fv.ds_rcrd_st = 'ACTIVE'
        AND fv.src_stm_code = 'IDS_DATA_VALUES'
        AND fv.text_val IS NOT NULL

),

audit_lookup AS (

    SELECT
        cl_code AS lookup_cd
        , cl_nm AS lookup_value_vn
    FROM {{ ref('atm_cl_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_LOOKUP_VALUES'
        AND schema_code = 'IDS.AUDITOR_OPINION'

),

audit_sub AS (

    SELECT
        s.pc_id
        , s.fr_code
        , s.submission_dt
        , s.pc_rpt_submission_code
        , CASE WHEN s.rpt_quarter = 5 THEN make_date(s.rpt_year, 12, 31) ELSE make_date(s.rpt_year, 6, 30) END AS period_end_dt
        , NVL(audit_lookup.lookup_value_vn, audit_val.text_val) AS audit_opinion_text
    FROM (
        SELECT pc_id, rpt_year, rpt_quarter, fr_code, submission_dt, pc_rpt_submission_code
        FROM {{ ref('atm_pc_report_submission') }}
        WHERE ds_rcrd_st = 'ACTIVE'
            AND approval_status_code = 'APPROVED'
            AND SUBSTR(fr_code,1,2) IN ('HN','TH','ME','RI')
            AND rpt_quarter IN (5,6)
            AND submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ) s
    INNER JOIN audit_val
        ON audit_val.pc_rpt_submission_code = s.pc_rpt_submission_code
    LEFT JOIN audit_lookup
        ON audit_lookup.lookup_cd = audit_val.text_val

),

audit_opinion_ranked AS (

    SELECT
        audit_sub.*
        , ROW_NUMBER() OVER (
            PARTITION BY audit_sub.pc_id
            ORDER BY
                audit_sub.period_end_dt DESC
                , CASE SUBSTR(audit_sub.fr_code,1,2)
                    WHEN 'HN' THEN 1
                    WHEN 'TH' THEN 2
                    WHEN 'ME' THEN 3
                    WHEN 'RI' THEN 4
                END
                , audit_sub.submission_dt DESC
                , CAST(audit_sub.pc_rpt_submission_code AS bigint) DESC
        ) AS rn
    FROM audit_sub

),

audit_opinion AS (

    SELECT pc_id, audit_opinion_text
    FROM audit_opinion_ranked
    WHERE rn = 1

),

-- === Financial statement chain (BCDKT/BCKQKD gan nhat da duyet) ===
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
        AND (rpt_year * 4 + rpt_quarter) IN (
            YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd')) * 4 + QUARTER(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
            , YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd')) * 4 + QUARTER(to_date('{{ var("etl_date") }}','yyyy-MM-dd')) - 1
        )

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

cal_period AS (

    SELECT
        YEAR(x.etl_dt) * 4 + QUARTER(x.etl_dt) AS cur_idx
        , CASE WHEN QUARTER(x.etl_dt) = 1 THEN YEAR(x.etl_dt) - 1 ELSE YEAR(x.etl_dt) END AS prev_year
        , CASE WHEN QUARTER(x.etl_dt) = 1 THEN 4 ELSE QUARTER(x.etl_dt) - 1 END AS prev_q
    FROM (SELECT to_date('{{ var("etl_date") }}','yyyy-MM-dd') AS etl_dt) x

),

fin_value_joined AS (

    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , fc.rpt_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
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
        AND (fc.rpt_code LIKE 'BCDKT%' OR fc.rpt_code LIKE 'BCKQKD%')
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'

),

fin_pivot AS (

    SELECT
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '300')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '400')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS total_liabilities_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS owner_equity_ending_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCDKT%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
                )
                AND fin_value_joined.column_description_reference = '2'
            THEN fin_value_joined.cell_val
          END) AS owner_equity_beginning_amt
        , MAX(CASE
            WHEN fin_value_joined.rpt_code LIKE 'BCKQKD%'
                AND (
                    (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '60')
                    OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '21')
                )
                AND fin_value_joined.column_description_reference = '1'
            THEN fin_value_joined.cell_val
          END) AS net_profit_after_tax_amt
    FROM fin_value_joined
    GROUP BY
        fin_value_joined.pc_id
        , fin_value_joined.rpt_year
        , fin_value_joined.rpt_quarter

),

-- [2026-11-06 THEO BA] toi da 2 ky ung vien moi to chuc: quy chua ngay (is_cur) va quy lien truoc; ho so da duoc loc o pc_rpt_sub_valid
fin_candidate AS (

    SELECT
        d.pc_id
        , d.rpt_year
        , d.rpt_quarter
        , (d.rpt_year * 4 + d.rpt_quarter = cal_period.cur_idx) AS is_cur
        , fin_pivot.total_liabilities_amt
        , fin_pivot.owner_equity_ending_amt
        , fin_pivot.owner_equity_beginning_amt
        , fin_pivot.net_profit_after_tax_amt
        , (
            fin_pivot.total_liabilities_amt IS NOT NULL
            OR fin_pivot.owner_equity_ending_amt IS NOT NULL
            OR fin_pivot.owner_equity_beginning_amt IS NOT NULL
            OR fin_pivot.net_profit_after_tax_amt IS NOT NULL
        ) AS has_data
    FROM pc_rpt_sub_dedup d
    CROSS JOIN cal_period
    LEFT JOIN fin_pivot
        ON fin_pivot.pc_id = d.pc_id
        AND fin_pivot.rpt_year = d.rpt_year
        AND fin_pivot.rpt_quarter = d.rpt_quarter

),

fin_choice AS (

    SELECT
        pc_id
        , MAX(CASE WHEN is_cur AND has_data THEN 1 ELSE 0 END) AS cur_has_data
    FROM fin_candidate
    GROUP BY pc_id

),

fin_ratios AS (

    SELECT
        c.pc_id
        , c.rpt_year
        , c.rpt_quarter
        , c.total_liabilities_amt
        , c.owner_equity_ending_amt
        , c.owner_equity_beginning_amt
        , CASE
            WHEN c.owner_equity_beginning_amt IS NULL THEN c.owner_equity_ending_amt
            ELSE (c.owner_equity_beginning_amt + c.owner_equity_ending_amt) / 2
          END AS owner_equity_average_amt
        , c.net_profit_after_tax_amt
    FROM fin_candidate c
    INNER JOIN fin_choice ch
        ON ch.pc_id = c.pc_id
    WHERE (ch.cur_has_data = 1 AND c.is_cur)
        OR (ch.cur_has_data = 0 AND NOT c.is_cur)

),

joined AS (

    SELECT
        bond_snpst.symbol
        , bond_snpst.trading_dt
        , lsi_hnx.listed_share_quantity
        , bond_snpst.src_stm_code
        , pu_co.pc_id
    FROM bond_snpst
    LEFT JOIN lsi_hnx
        ON lsi_hnx.ticker_symbol = bond_snpst.symbol
        AND lsi_hnx.ds_snpst_dt = bond_snpst.trading_dt
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = SUBSTR(bond_snpst.symbol, 1, 3)

)

SELECT
    CAST(joined.symbol AS string)                              AS issuer_symbol_code,
    CAST(joined.trading_dt AS date)                             AS snpst_dt,
    CAST(100000 * joined.listed_share_quantity AS decimal(23,2)) AS bond_outstanding_val,
    CAST(100000 AS decimal(23,2))                               AS par_val,
    CAST(joined.listed_share_quantity AS decimal(23,2))    AS outstanding_vol,
    CAST(audit_opinion.audit_opinion_text AS string)            AS audit_opinion_text,
    CAST(bond_eval.ranking_code AS string)                      AS ranking_code,
    CAST(
        CASE
            WHEN bond_eval.ranking_code IN ('A') THEN 'Bình thường'
            WHEN bond_eval.ranking_code IN ('B') THEN 'Cảnh báo'
            WHEN bond_eval.ranking_code IS NULL THEN 'Chưa có thông tin'
            ELSE 'Rủi ro'
        END
    AS string)                                                  AS risk_rating_text,
    CAST(fin_ratios.total_liabilities_amt AS decimal(23,2))     AS total_liabilities_amt,
    CAST(fin_ratios.owner_equity_ending_amt AS decimal(23,2))   AS owner_equity_ending_amt,
    CAST(fin_ratios.owner_equity_beginning_amt AS decimal(23,2)) AS owner_equity_beginning_amt,
    CAST(fin_ratios.owner_equity_average_amt AS decimal(23,2)) AS owner_equity_average_amt,
    CAST(fin_ratios.net_profit_after_tax_amt AS decimal(23,2)) AS net_profit_after_tax_amt,
    CAST(
        fin_ratios.total_liabilities_amt / NULLIF(fin_ratios.owner_equity_ending_amt, 0)
    AS decimal(8,2))                                            AS debt_to_equity_ratio,
    CAST(
        ROUND(fin_ratios.net_profit_after_tax_amt / NULLIF(fin_ratios.owner_equity_average_amt, 0) * 100, 4)
    AS decimal(8,4))                                            AS roe_pct,
    CAST(last_day(make_date(COALESCE(fin_ratios.rpt_year, cal_period.prev_year), COALESCE(fin_ratios.rpt_quarter, cal_period.prev_q) * 3, 1)) AS date) AS financial_period_end_dt,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt,
    CAST(joined.src_stm_code AS string)                         AS src_stm_code
FROM joined
CROSS JOIN cal_period
LEFT JOIN bond_eval
    ON bond_eval.pc_id = joined.pc_id
LEFT JOIN audit_opinion
    ON audit_opinion.pc_id = joined.pc_id
LEFT JOIN fin_ratios
    ON fin_ratios.pc_id = joined.pc_id
