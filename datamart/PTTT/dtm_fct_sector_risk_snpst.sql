/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_sector_risk_snpst
* Program name: Fact Sector Risk Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* [2026-09-23] CAP NHAT THEO LLD MOI (DTM_PTTT_fct_sector_risk_snpst.csv,
* ban 18755 bytes) - LLD moi da chinh thuc hoa/mo rong bang nay (truoc day
* chi co 1 cot total_val_sector, cac cot con lai la BO SUNG theo HLD). Thay
* doi chinh:
*   1. RENAME cot FK "sector_dim_id" -> "industry_dim_id" theo dung ten LLD
*      moi (ban chat khong doi: van LOOKUP dtm_sector_dim theo industry_code
*      = business_line_level_1_code, xem ghi chu dtm_sector_dim.sql).
*   2. BO 3 cot avg_pdrawdown_sector/avg_pvolatility_sector/avg_pselling_sector
*      KHOI OUTPUT - LLD moi KHONG liet ke 3 cot nay trong danh sach
*      datamart_column (chi con stress_score_sector la output chinh thuc),
*      nen coi day la bang chung ro rang LLD da doi -> bo theo dung huong
*      dan (khac voi truoc day khi chua co LLD chinh thuc, phai giu lai
*      theo HLD). Cac CTE tinh Pdrawdown_i/Pvolatility_i/Pselling_i van giu
*      nguyen o muc PER MA CK vi la sub-component bat buoc cua cong thuc
*      stress_score_sector moi.
*   3. THEM 9 cot moi theo LLD: total_market_cap_sector, sector_liquid_score,
*      stress_score_sector_previous_day, sector_stress_delta, sector_rating,
*      sector_debt_score, total_trading_val_matched_sector,
*      foreign_net_val_sector, proprietary_net_val_sector,
*      total_outstanding_share_quantity_sector.
*   4. CONG THUC stress_score_sector DOI: LLD moi ghi ro la WEIGHTED AVERAGE
*      theo TY TRONG VON HOA (weight_i = market_cap_i / SUM(market_cap_nganh)),
*      KHONG con la AVG(stress_score_i) don gian nhu truoc (khi chua co LLD,
*      da tam dung AVG don gian). Da sua theo dung cong thuc LLD.
*   5. market_id_code: LLD viet 'STO','STX','UPX' cho foreign_net_val_sector/
*      proprietary_net_val_sector/total_trading_val_matched_sector - day la
*      LOI COPY-PASTE DA BIET cua thiet ke (xem ghi chu 2026-09-23 trong
*      dtm_fct_foreign_net_trade_snpst.sql: khong ton tai 'STO' o bat ky
*      atomic/model nao trong repo, gia tri thuc te la 'STK') -> da sua
*      thanh 'STK' cho dung convention thuc te, giong tat ca cac fact PTTT
*      theo co phieu khac.
*
* CAC GAP/PENDING DA XU LY (cap nhat 2026-09-25 - xem muc 1/2/3 cua khoi
* [2026-09-25] o tren de biet chi tiet):
*   - stress_score_sector (va do do sector_rating, sector_stress_delta):
*     [2026-09-25] DA NOI - atm_risk_weight_config DA DUOC BUILD, W1/W2/W3
*     gio LOOKUP weight THAT theo risk_factor_code (CANH BAO rieng ve
*     risk_factor_group xem muc 1 o tren), KHONG con hardcode 1/3.
*   - Pselling_i: [2026-09-25] DA NOI - atm_security_match_log DA DUOC BUILD,
*     Pselling gio dung DATA THAT (SUM(match_vol) WHERE trade_direction_code=
*     'S'), KHONG con la PROXY theo huong bien dong gia nua (xem muc 2 o tren
*     va khoi CANH BAO Pselling da duoc viet lai o cuoi file).
*   - sector_rating: [2026-09-24] DA NOI - atm_status_threshold_config nay
*     DA DUOC BUILD (models/atomic/business_direction). Them LEFT JOIN
*     {{ ref('atm_status_threshold_config') }} theo index_code='STRESS_SCORE'
*     AND ds_rcrd_st='ACTIVE' (cot ky thuat SCD2 do macro mcr_scd2.sql tu
*     them vao bang vat ly, khong xuat hien trong SELECT cua model do
*     nhung van co trong output cua ref()) AND stress_score_sector BETWEEN
*     from_value AND to_value -> status AS sector_rating, dung dung LLD
*     dong 10 (Sector Rating). from_value/to_value la INT, stress_score_sector
*     la decimal(5,2) -> CAST from_value/to_value sang decimal(5,2) truoc
*     khi so sanh BETWEEN.
*
* [2026-09-25] CAP NHAT THEO LLD MOI NHAT (2026-09-24, 16 dong du lieu):
*   1. stress_score_sector - W1/W2/W3: atm_risk_weight_config DA DUOC BUILD
*      (models/atomic/business_direction/atm_risk_weight_config.sql, cot
*      risk_factor_code/risk_factor_nm/risk_factor_group/weight, SCD2 qua
*      ds_rcrd_st/ds_rcrd_eff_dt/ds_rcrd_end_dt). Da BO hardcode 1/3, THEM CTE
*      risk_wc_sector LOOKUP risk_factor_code IN ('W1_DRAWDOWN','W2_VOLATILITY',
*      'W3_SELLING') AND ds_rcrd_st='ACTIVE', pivot MAX(CASE...) lay w1/w2/w3
*      that, dung dung PATTERN da dung cho beta_* trong
*      dtm_fct_market_risk_snpst.sql (risk_wc/risk_wc_scalar). CANH BAO: atomic
*      KHONG co cot risk_factor_type/data_dt nhu LLD viet ("risk_factor_type=
*      'Chi so ap luc nganh'", "data_dt=MAX(data_dt)<=snapshot_date") - CHI
*      JOIN theo risk_factor_code (dieu kien chac chan, giong het cach lam o
*      beta_* cua market_risk_snpst) va thay data_dt=MAX(...) bang ds_rcrd_st=
*      'ACTIVE' (SCD2 "ban ghi dang hieu luc" thay cho "ban ghi moi nhat theo
*      ngay"). CAN Data Modeler/LLD xac nhan risk_factor_group thuc te co dung
*      la 1 nhom rieng ("Chi so ap luc nganh"/STRESS_SCORE_SECTOR) khong bi
*      trung risk_factor_code voi nhom khac (RISK_INDEX/SENTIMENTINDEX) truoc
*      production - neu trung, phai bo sung dieu kien risk_factor_group.
*   2. Pselling: DOI TU PROXY (huong bien dong gia) SANG DATA THAT tu
*      atm_security_match_log (models/atomic/transaction/atm_security_match_log
*      .sql) - model nay DA TON TAI, cot symbol/trading_dt/trade_direction_code/
*      match_vol. Model do CHI filter TRADINGDATE = etl_date trong CTE noi bo
*      cua chinh no (ja_tr), nhung la mot bang vat ly TICH LUY lich su qua cac
*      lan chay dbt hang ngay (incremental/append, khong co _hstr) - nen o day
*      ref() va TU LOC lai theo khoang date_sub(etl_date,60)->etl_date, giong
*      het pattern se_tr_snpst/se_tr_daily_vol da dung trong file nay. Da THEM
*      CTE se_match_daily_sell (SUM(match_vol) GROUP BY symbol,trading_dt WHERE
*      trade_direction_code='S') va se_match_sell_20d (SUM(...) OVER 20 phien,
*      dung khung voi se_tr_daily_vol/sum_vol_20d hien co - xem GHI CHU N=20
*      dau file, van giu nguyen quyet dinh N=20 vi LLD khong chot lai con so
*      moi). pselling_i = SUM(daily_sell_vol 20 phien)/SUM(execution_vol 20
*      phien, market_id_code IN ('STK','STX','UPX') - xem muc 3 duoi). DA XOA
*      HOAN TOAN logic proxy (CASE WHEN close_price < prev_close_price) va cot
*      sell_pressure_vol/sum_vol_20d dung rieng cho proxy o symbol_return/
*      symbol_calc (thay bang tham chieu sang se_match_sell_20d/sum_vol_20d).
*   3. market_id_code mau so Pselling: LLD ghi 'STO','STX','UPX' - GIU NGUYEN
*      'STK' (khong doi thanh 'STO') vi day la LOI COPY-PASTE DA BIET cua
*      thiet ke, dung convention thuc te 'STK' giong toan bo cac cho khac
*      trong file nay (xem muc 5 cua bang cap nhat 2026-09-23 o tren va ghi
*      chu goc trong dtm_fct_foreign_net_trade_snpst.sql).
*   4. THEM 2 COT MOI theo LLD dong 16/17: net_profit_after_tax_amt_sector
*      (SUM LNST quy gan nhat da cong bo cua cac cong ty trong nganh) va
*      sector_pe (SUM(close_price*outstanding_share_quantity) / SUM(LNST) cua
*      cac ma CO LNST trong nganh). Da THEM CTE fin_pivot_pe (pivot LNST tu
*      fin_value_joined, dieu kien rpt_code LIKE 'BCKQKD%', row_description
*      _reference DN/BH='60' TD='21', column_description_reference='1' - dung
*      y het pattern fin_pivot_pc da co san cho total_liabilities/owner_equity,
*      chi khac dieu kien row_description_reference va rpt_code) o muc PER
*      pc_id, roi JOIN theo ca business_line_level_1_code (cho SUM nganh cua
*      net_profit_after_tax_amt_sector) va theo tung ma CK qua oss_latest/
*      se_tr_snpst (cho tu so cua sector_pe, dung dung LLD dong 17: LEFT JOIN
*      security_trading_snapshot theo equity_ticker_symbol tai etl_date).
*
* [2026-09-24] SUA sector_debt_score TU PENDING SANG TINH DUOC: bao cao truoc
* ghi nham la con thieu 2 atomic "fr_row_template"/"fr_column_template" -
* thuc ra day CHI LA TEN GOI TRONG LLD, physical model TUONG UNG DA TON TAI
* trong repo la atm_fr_row / atm_fr_column (cung 1 chain pc_report_submission
* -> fr_value -> fr_catalog -> fr_row/fr_column DA DUOC DUNG THANH CONG cho
* 7 cot tai chinh cua dtm_opr_corporate_bond_issuer_credit_monitor.sql, xem
* file do de doi chieu). Da them CTE tinh TotalLiabilities_i/OwnerEquity_i
* THEO TUNG pc_id (dung dung logic dedup ky bao cao HN>TH>ME>RI + ky gan nhat
* cua credit_monitor), roi JOIN sang pu_co (business_line_level_1_code) va
* SUM ca 2 ve theo nganh truoc khi chia, dung theo cong thuc LLD (BA dong 195):
* sector_debt_score = SUM(TotalLiabilities_i toan nganh) / SUM(OwnerEquity_i
* toan nganh), giu nguyen ty le tho (KHONG quy doi ra diem 0-100 vi BA chua
* cho nguong cu the).
*
* GIA DINH KY THUAT MOI (CAN LLD REVIEW LAI TRUOC PRODUCTION):
*   - total_market_cap_sector dung DE TINH TROMG SO cho stress_score_sector
*     tren CA CUA SO 60 NGAY LICH (de co the tinh stress_score_sector_previous
*     _day bang LAG), nhung outstanding_share_quantity CHI lay 1 LAN duy nhat
*     (ban ghi VSDC gan nhat <= etl_date, ROW_NUMBER dedupe) roi ap dung
*     CHUNG cho toan bo cac ngay trong cua so lich su - KHONG lookback rieng
*     tung ngay giao dich (qua ton kem tren Spark voi ~60 ngay x hang nghin
*     ma CK). Day la XAP XI hop ly vi so luong CP luu hanh it doi trong ngan
*     han, nhung se lam stress_score_sector_previous_day/sector_stress_delta
*     cua NHUNG NGAY XA etl_date (dau cua so 60 ngay) kem chinh xac hon so
*     voi ngay hien tai - chap nhan duoc vi output CHI LAY dung 1 ngay
*     etl_date (LAG 1 buoc), gia tri quan trong nhat (ngay hom truoc etl_date)
*     van nam rat gan moc lay outstanding_share_quantity.
*   - sector_liquid_score: LLD ghi cong thuc la ty le thuan tuy
*     (total_val_sector / total_market_cap_sector), KHONG nhan 100 nhu cac
*     cot Percentage khac (price_change_percentage, pdrawdown_i...) - da
*     lam DUNG THEO VAN BAN LLD (khong tu y nhan 100), du domain ghi la
*     "Percentage" - CAN LLD xac nhan lai co can nhan 100 hay khong.
*--------------------------------------------------------------------*
* Ghi chu ky thuat khac (giu nguyen tu ban truoc):
* - KIEN TRUC: bang ten "Sector Risk Snapshot" va grain chuan la 1 dong /
*   nganh / ngay (khong phai 1 dong / ma CK / ngay), nen CTE trung gian
*   (symbol_*) tinh DAY DU cac chi so rui ro o muc PER MA CK truoc, chi
*   SELECT cuoi cung moi AVG/SUM len dung grain nganh/ngay (phuong an (b)
*   theo yeu cau, khong denormalize industry_dim_id xuong grain ma CK).
* - atm_security_trading_snapshot: incremental_rebase/snapshot, partition_by
*   ds_snpst_dt, KHONG co _hstr -> doc truc tiep theo trading_dt. De co du
*   du lieu cho window 30 phien (Pvolatility) va 20 phien (Pdrawdown/
*   Pselling), lay du lieu trong khoang date_sub(etl_date, 60) -> etl_date
*   (dem du 60 ngay lich de chac chan >= 30 phien giao dich, du bien
*   nghi le/cuoi tuan), roi loc lai dung etl_date o buoc cuoi (buoc cuoi
*   nay nay da doi thanh LAG 1 buoc de lay them ngay truoc etl_date, xem
*   sector_stress_lag).
* - atm_public_company: SCD4A -> doc tu _hstr, loc chuan ds_snpst_dt/
*   ds_rcrd_st/src_stm_code. Khoa join ma CK <-> nganh: equity_ticker_symbol
*   (atm_public_company) = symbol (atm_security_trading_snapshot). Cong ty
*   khong co equity_ticker_symbol (khong niem yet co phieu) se khong xuat
*   hien trong fact nay do INNER JOIN.
* - atm_securities_trade: incremental_rebase/append, KHONG co _hstr, loc
*   truc tiep theo trade_dt, filter market_id_code IN ('STK','STX','UPX')
*   giong cac fact PTTT khac (fct_order_size_snpst, fct_foreign_net_trade
*   _snpst, fct_investor_flow_snpst). Khoi luong khop lenh duoc SUM truoc
*   theo (symbol, trade_dt) roi moi JOIN voi close_price theo (symbol,
*   trading_dt) - tranh nhan chong (cross join) giua nhieu dong trade cung
*   ngay voi 1 gia dong cua theo ngay.
* - total_val_sector: LLD goc ghi "SUM(close_price * execution_vol) ...
*   securities_trade.trading_dt" - da sua loi danh may nghi van thanh
*   securities_trade.trade_dt (dung ten cot that trong atm_securities_trade,
*   khong co cot trading_dt o bang nay).
* - Khong loc them theo stock_tp_code cua atm_security_trading_snapshot vi
*   khong xac nhan duoc gia tri ma code chinh xac cho "co phieu thuong" -
*   INNER JOIN voi atm_public_company.equity_ticker_symbol da du dieu kien
*   de gioi han dung tap ma co phieu cua cong ty dai chung.
* - industry_dim_id LOOKUP tu dtm_sector_dim (build o buoc 3.1) theo
*   industry_code = business_line_level_1_code, dieu kien ds_rcrd_st =
*   'ACTIVE' (dimension SCD4A) - giong cach lookup dtm_corp_bond_industry_dim
*   trong dtm_fct_corporate_bond_sector_snpst.sql.
*
* !!! CANH BAO / GIA DINH QUAN TRONG VE Pdrawdown/Pvolatility/Pselling !!!
*   1. "N phien" trong cong thuc Pdrawdown va Pselling KHONG duoc HLD chot
*      con so cu the -> TAM DUNG N = 20 phien giao dich gan nhat (cung khung
*      voi cua so tinh Pselling). Rieng Pvolatility HLD ghi ro 30 phien nen
*      giu dung N = 30.
*   2. [2026-09-25] Pselling_i - DA DOI TU PROXY SANG DATA THAT: truoc day
*      (khi atm_security_match_log chua co) phai dung PROXY theo huong bien
*      dong gia (coi 1 phien la "phien ban ap luc" khi close_price THAP HON
*      phien truoc, roi lay ty le khoi luong khop lenh trong cac phien giam
*      gia) vi atm_securities_trade/atm_security_trading_snapshot KHONG co cot
*      xac dinh duoc chieu mua/ban cua 1 giao dich khop lenh. Nay
*      atm_security_match_log DA DUOC BUILD (models/atomic/transaction), co
*      san cot trade_direction_code phan biet duoc chieu khop (gia tri 'S' =
*      ban, doi chieu ODS_MDDS_JAD_TRANSLOG.LASTCOLOR) va match_vol (khoi
*      luong khop cua tung giao dich) - nen Pselling_i gio TINH DUNG THEO LLD:
*      Pselling_i = SUM(match_vol WHERE trade_direction_code='S') trong N=20
*      phien / SUM(execution_vol WHERE market_id_code IN ('STK','STX','UPX'))
*      trong N=20 phien (xem CTE se_match_daily_sell/se_match_sell_20d va
*      symbol_calc). KHONG con la gia dinh/proxy nua - CHI con 1 diem can luu
*      y: trade_direction_code='S' suy tu LASTCOLOR cua nguon MDDS JAD
*      TRANSLOG, CAN Data Modeler xac nhan lai gia tri 'S' la dung "ben ban"
*      (khong phai 'B'/'Buy' bi doi ten nguoc) truoc khi dua vao production.
*--------------------------------------------------------------------*
* 2026-10-05b			tuan.nguyenvanb		LLD (commit 96bfadb3): total_val_sector va sector_liquid_score them
*									floor_code IN ('02','04','10') AND stock_tp_code = '2' -> ap dung vao CTE
*									se_tr_snpst (nguon chung cua symbol_daily). CTE nay cung cap cho cac chi tieu
*									khac cua nganh nhung chi gom ma co ticker trong public_company (INNER JOIN
*									pu_co) nen anh huong chu yeu la bo ma khong phai co phieu.
* 2026-10-06			tuan.nguyenvanb		RA SOAT DATATYPE (dev quyet dinh, thong nhat): cac chi tieu dang PHAN SO NHO
*									(khong nhan 100: log-return, daily return, volatility, systemic_vol_current/max,
*									illiquidity_ratio, sector_liquid_score) bi decimal(5,2) cat ve 0.00/0.01 (VD log_ret
*									0.000306 -> 0.00). Doi sang decimal(38,20). Cac cot beta, epsilon va weight di thang
*									tu atm_risk_weight_config.weight -> CHUOI stg/ods/atomic cung doi decimal(38,20)
*									(truoc: stg decimal(10,4) -> atomic decimal(5,2) cat 4 chu so thap phan).
* 2026-10-07			tuan.nguyenvanb		Doi chieu lai LLD (audit tung cot): (1) Pdrawdown va Pselling dung cua
*									so 30 phien (29 PRECEDING) thay vi 20 phien (19 PRECEDING) dung LLD;
*									doi ten max_close_20d/sum_vol_20d/sell_vol_20d thanh phien ban 30d.
*									(2) sector_pe: tu so chi cong cac ma CO LNST (CASE WHEN lnst IS NOT NULL)
*									dung LLD, truoc day ma co bao cao nhung thieu dong LNST van vao tu so.
* 2026-10-09			tuan.nguyenvanb		Ap dung LLD 2026-10-09 (commit d39ed114, O_PTTT_43): (1) se_tr_snpst lay ban ghi
*									trading_time MOI NHAT moi ma/ngay (truoc day doc moi ban ghi trong ngay nen fan-out
*									close_price/sector_pe), chi loc floor 02/04/10 (stock_tp_code='2' chuyen xuong
*									rieng total_val_sector va sector_liquid_score). (2) total_val_sector =
*									SUM(snapshot.total_trading_val) (thay close_price x execution_vol); sector_liquid_score
*									= total_val_sector / von hoa nganh stock_tp '2'. (3) Pselling dung mau so snapshot.
*									total_trading_vol thay SUM(execution_vol) cua securities_trade (BO CTE se_tr_daily_vol).
*									(4) total_trading_val_matched_sector = SUM(snapshot.total_trading_val) tai etl_date
*									(floor 02/04/10, khong loc stock_tp). (5) foreign_net_val_sector/proprietary_net_val
*									_sector: noi ma -> nganh qua snapshot (HOSE symbol, HNX isin_code = security_symbol
*									_code - A17 LLD chua xac nhan); giu market_id STK thay STO. (6) se_tr_pe doc tu
*									se_tr_snpst (da dedup). total_market_cap_sector/stress_score_sector KHONG loc stock_tp.
* 2026-10-10			tuan.nguyenvanb		LOI UNRESOLVED_COLUMN trading_dt: bang atomic atm_security_trading_snapshot hien
*									KHONG con cot trading_dt (file atomic sua 2026-10-09 19:32) -> doc ngay giao dich
*									tu ds_snpst_dt (= tradingdate vi ODS loc TRADINGDATE = etl_date), dat alias
*									trading_dt de cac CTE phia sau khong doi.
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. security_match_log.symbol->ticker_symbol. Khong doi cot/kieu.
* 2026-10-23			tuan.nguyenvanb		[LLD CHOT CUA SO 20 PHIEN - Nhom 7 StressScore] Pvolatility (sigma), Pdrawdown (max_close), Pselling (sum_vol/sell_vol) cung tinh tren 20 phien:
*									ROWS BETWEEN 29 -> 19 PRECEDING (doi alias *_30d -> *_20d); cua so doc atomic date_sub 60 -> 50 ngay lich (LLD A19-R6 INTERVAL 50 DAY).
*									Khong doi cot/kieu -> khong can ALTER. Cac ghi chu cu o tren ve '30 phien' la lich su.
* 2026-10-27			tuan.nguyenvanb		[DONG BO THEO CAC MODEL DA SUA: market_risk] (1) foreign_net_val_sector / proprietary_net_val_sector: phan loai NDTNN theo ky tu thu 4 so tai khoan MUA/BAN IN ('E','F'),
*									tu doanh IN ('A','E','P') thay cho buy/sell_foreign_investor_tp_code IN ('10','20') / buy/sell_client_house_cl_code = '30' (giong market_risk / foreign_net_trade /
*									proprietary_net_trade 2026-10-19). (2) se_tr_trade_day: market_id_code them 'STO' (chuan hoa IN STK, STO, STX, UPX nhu market_risk 2026-10-15).
*									Khong doi cot/kieu -> khong can ALTER; build lai mart + flat.
* 2026-10-27			tuan.nguyenvanb		[NHOM 'CHUA PHAN NGANH' - BA] pu_co: business_line_level_1_code NULL/rong -> 'UNCLASSIFIED' (dtm_sector_dim them dong tuong ung, ten 'Chua phan nganh'). Truoc day nhom NULL
*									khong noi duoc cac CTE theo nganh (NULL = NULL sai) nen sector_debt_score (K_PTTT_97) / KLGD khop / NDTNN / tu doanh / KLLH / LNST cua nhom nay NULL va industry_nm NULL;
*									nay moi chi tieu cua nhom duoc tinh nhu cac nganh khac. Khong doi cot/kieu.
* 2026-10-28		tuan.nguyenvanb		[BA chot] K_PTTT_262/242/243 chi tinh CO PHIEU: total_trading_val_matched_sector them stock_tp_code = '2'; sts (foreign/proprietary net) them
*									floor_code IN ('02','04','10') AND stock_tp_code = '2'. Khong doi cot/kieu. Cac chi tieu khac (stress, von hoa...) giu nguyen.
* 2026-10-28		tuan.nguyenvanb		[BA chot] Co phieu KHONG co ho so cong ty (khong noi duoc atm_public_company) gom vao 'Chua phan nganh' (UNCLASSIFIED) cho K_PTTT_262/242/243:
*									se_tr_matched_sector / se_tr_trade_sector doi INNER JOIN pu_co -> LEFT JOIN + COALESCE(..., 'UNCLASSIFIED'). Khong doi cot/kieu.
*									[BA chot 2026-10-28] LNST (K_PTTT_275/244): moi cong ty lay ky bao cao GAN NHAT CO LNST (lui ve ky truoc neu ky moi nhat khong co LNST) thay vi ky nop gan nhat; sector_pe: tu so va mau so cung 1 tap ma (co LNST, gia dong cua > 0, KLLH > 0). net_profit_after_tax_amt_sector giu tong LNST cac ma co LNST. Khong doi cot/kieu.
*									[BA chot 2026-10-28] pu_co dedupe 1 ho so / ma (ROW_NUMBER PARTITION BY equity_ticker_symbol ORDER BY CAST(pc_code AS bigint) = id ho so IDS nho nhat, giong cau test BA): ma co 2 ho so ACTIVE (vd SST) khong con bi nhan doi o cac chi tieu theo nganh. Khong doi cot/kieu.
*/

WITH se_tr_snpst_raw AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , close_price
        , stock_tp_code
        , total_trading_val
        , total_trading_vol
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 50)
                          AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND floor_code IN ('02','04','10')
),

-- [2026-10-09 LLD] ban ghi trading_time MOI NHAT moi ma/ngay (JAD_STOCKINFOR co nhieu
-- snapshot/ngay; total_trading_val/vol la so khop cong don tu dau ngay). Chi loc san
-- 02/04/10; stock_tp_code = '2' chi ap dung rieng cho total_val_sector va sector_liquid_score
-- (xem sector_day_agg) - total_market_cap_sector/stress_score_sector/total_trading_val_matched
-- _sector KHONG loc stock_tp_code theo LLD.
se_tr_snpst AS (
    SELECT symbol, trading_dt, close_price, stock_tp_code, total_trading_val, total_trading_vol
    FROM se_tr_snpst_raw
    WHERE rn = 1
),

pu_co AS (
    SELECT pc_id, equity_ticker_symbol, business_line_level_1_code
    FROM (
        SELECT
            pc_id
            , equity_ticker_symbol
            , COALESCE(NULLIF(TRIM(cl_ids_business_line_level_1_code), ''), 'UNCLASSIFIED') AS business_line_level_1_code   -- [2026-10-27] cty chua co nganh -> nhom 'Chua phan nganh' (BA)
            , ROW_NUMBER() OVER (
                PARTITION BY equity_ticker_symbol
                ORDER BY CAST(pc_code AS bigint) ASC   -- [2026-10-28 BA chot] 1 ho so / ma: id ho so IDS nho nhat (khong dung pc_id hash)
            ) AS rn_pc
        FROM {{ ref('atm_public_company') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'IDS_COMPANY_PROFILES'
            AND equity_ticker_symbol IS NOT NULL
    ) x
    WHERE x.rn_pc = 1
),

-- [MOI 2026-09-24] Chain BCTC cho sector_debt_score - dung y het pattern da
-- dung o dtm_opr_corporate_bond_issuer_credit_monitor.sql (pc_rpt_sub_valid/
-- ranked/dedup/latest_ranked/latest), chi khac la chay tren TOAN BO pc_id
-- (khong chi TCPH phat hanh trai phieu) vi sector_debt_score can No phai tra/
-- VCSH cua MOI cong ty dai chung trong nganh.
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

fin_value_joined AS (
    SELECT
        s.pc_id
        , fc.rpt_code
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
    FROM pc_rpt_sub_latest s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCDKT%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
),

fin_pivot_pc AS (
    SELECT
        fin_value_joined.pc_id
        , MAX(CASE
            WHEN (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '300')
                OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '400')
                THEN
                    CASE WHEN fin_value_joined.column_description_reference = '1' THEN fin_value_joined.cell_val END
          END) AS total_liabilities_amt
        , MAX(CASE
            WHEN (fin_value_joined.enterprise_tp_code IN ('DN','BH') AND fin_value_joined.row_description_reference = '400')
                OR (fin_value_joined.enterprise_tp_code = 'TD' AND fin_value_joined.row_description_reference = '500')
                THEN
                    CASE WHEN fin_value_joined.column_description_reference = '1' THEN fin_value_joined.cell_val END
          END) AS owner_equity_ending_amt
    FROM fin_value_joined
    GROUP BY fin_value_joined.pc_id
),

sector_debt_agg AS (
    SELECT
        pu_co.business_line_level_1_code
        , SUM(fin_pivot_pc.total_liabilities_amt)  AS total_liabilities_sector
        , SUM(fin_pivot_pc.owner_equity_ending_amt) AS owner_equity_sector
    FROM pu_co
    INNER JOIN fin_pivot_pc
        ON fin_pivot_pc.pc_id = pu_co.pc_id
    GROUP BY pu_co.business_line_level_1_code
),

-- [MOI 2026-09-23] Outstanding Share Quantity - 1 ban ghi/ma CK, ban ghi gan
-- nhat <= etl_date (ROW_NUMBER dedupe, khong dung MAX(...) correlated
-- subquery cua LLD - cung pattern chuan hoa da dung o dtm_fct_stock_portfolio
-- _snpst.sql/GSTT va dtm_fct_market_statistics_snpst.sql). Ap dung 1 gia tri
-- duy nhat cho toan bo cua so lich su, xem canh bao dau file.
oss_all AS (
    SELECT
        ticker_symbol
        , outstanding_share_quantity
        , row_number() OVER (PARTITION BY ticker_symbol ORDER BY ds_snpst_dt DESC) AS rn
    FROM {{ ref('atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

oss_latest AS (
    SELECT ticker_symbol, outstanding_share_quantity
    FROM oss_all
    WHERE rn = 1
),

-- [MOI 2026-09-25] W1/W2/W3 THAT tu atm_risk_weight_config - JOIN CHI theo
-- risk_factor_code (dieu kien chac chan, dung PATTERN da dung cho beta_* trong
-- dtm_fct_market_risk_snpst.sql), ds_rcrd_st='ACTIVE' thay cho "data_dt=MAX(
-- data_dt)<=snapshot_date" cua LLD (atomic khong co cot data_dt, chi co SCD2).
-- CANH BAO: KHONG loc them risk_factor_group ("Chi so ap luc nganh") vi chua
-- xac nhan duoc gia tri thuc te - xem ghi chu dau file.
risk_wc_sector AS (
    SELECT risk_factor_code, weight
    FROM {{ ref('atm_risk_weight_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND risk_factor_code IN ('PDRAWDOWN','PVOLATILITY','PSELLING')
),

risk_wc_sector_scalar AS (
    SELECT
        MAX(CASE WHEN risk_factor_code = 'PDRAWDOWN' THEN weight END)   AS w1_drawdown
        , MAX(CASE WHEN risk_factor_code = 'PVOLATILITY' THEN weight END) AS w2_volatility
        , MAX(CASE WHEN risk_factor_code = 'PSELLING' THEN weight END)    AS w3_selling
    FROM risk_wc_sector
),

-- [MOI 2026-09-25] Pselling THAT tu atm_security_match_log (thay cho proxy
-- huong bien dong gia) - xem canh bao dau file. daily_sell_vol = SUM(match_vol)
-- GROUP BY symbol, trading_dt WHERE trade_direction_code = 'S'.
se_match_daily_sell AS (
    SELECT
        ticker_symbol AS symbol
        , trading_dt
        , SUM(match_vol) AS daily_sell_vol
    FROM {{ ref('atm_security_match_log') }}
    WHERE trading_dt BETWEEN date_sub(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 50)
                          AND to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trade_direction_code = 'S'
    GROUP BY ticker_symbol, trading_dt
),

-- ===== grain trung gian: 1 dong / ma CK / ngay =====
symbol_daily AS (
    SELECT
        se_tr_snpst.symbol
        , se_tr_snpst.trading_dt
        , pu_co.business_line_level_1_code
        , se_tr_snpst.close_price
        , se_tr_snpst.stock_tp_code
        , COALESCE(se_tr_snpst.total_trading_vol, 0) AS daily_vol
        , COALESCE(se_tr_snpst.total_trading_val, 0) AS daily_val
        , COALESCE(se_match_daily_sell.daily_sell_vol, 0) AS daily_sell_vol
        , se_tr_snpst.close_price * COALESCE(oss_latest.outstanding_share_quantity, 0) AS market_cap
    FROM se_tr_snpst
    INNER JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_snpst.symbol
    LEFT JOIN se_match_daily_sell
        ON se_match_daily_sell.symbol = se_tr_snpst.symbol
        AND se_match_daily_sell.trading_dt = se_tr_snpst.trading_dt
    LEFT JOIN oss_latest
        ON oss_latest.ticker_symbol = se_tr_snpst.symbol
),

symbol_window AS (
    SELECT
        symbol_daily.*
        , LAG(close_price) OVER (PARTITION BY symbol ORDER BY trading_dt)                                  AS prev_close_price
        , MAX(close_price)     OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS max_close_20d
        , SUM(daily_vol)       OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sum_vol_20d
        , SUM(daily_sell_vol)  OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sell_vol_20d
    FROM symbol_daily
),

symbol_return AS (
    SELECT
        symbol_window.*
        , LN(close_price / NULLIF(prev_close_price, 0)) AS daily_log_return
    FROM symbol_window
),

symbol_calc AS (
    SELECT
        symbol_return.*
        , STDDEV_SAMP(daily_log_return) OVER (PARTITION BY symbol ORDER BY trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS sigma_20d
    FROM symbol_return
),

-- sigma_min / sigma_max toan thi truong theo tung ngay, dung de chuan hoa Pvolatility
market_sigma AS (
    SELECT
        trading_dt
        , MIN(sigma_20d) AS sigma_min
        , MAX(sigma_20d) AS sigma_max
    FROM symbol_calc
    WHERE sigma_20d IS NOT NULL
    GROUP BY trading_dt
),

-- [SUA 2026-09-23] BO dieu kien "WHERE trading_dt = etl_date" o day (khac
-- ban truoc): can giu DAY DU lich su trong cua so 60 ngay de tinh duoc
-- stress_score_sector_previous_day (LAG 1 buoc o muc nganh/ngay ben duoi),
-- chi loc dung etl_date o SELECT cuoi cung (cung convention voi
-- dtm_fct_market_statistics_snpst.sql).
symbol_risk AS (
    SELECT
        symbol_calc.symbol
        , symbol_calc.trading_dt
        , symbol_calc.business_line_level_1_code
        , symbol_calc.close_price
        , symbol_calc.stock_tp_code
        , symbol_calc.daily_vol
        , symbol_calc.daily_val
        , symbol_calc.market_cap
        , CAST((symbol_calc.max_close_20d - symbol_calc.close_price) / NULLIF(symbol_calc.max_close_20d, 0) * 100 AS decimal(5,2)) AS pdrawdown_i
        , CAST(
              (symbol_calc.sigma_20d - market_sigma.sigma_min)
              / NULLIF(market_sigma.sigma_max - market_sigma.sigma_min, 0) * 100
          AS decimal(5,2))                                                                                                          AS pvolatility_i
        , CAST(symbol_calc.sell_vol_20d / NULLIF(symbol_calc.sum_vol_20d, 0) * 100 AS decimal(5,2))                                 AS pselling_i
    FROM symbol_calc
    LEFT JOIN market_sigma
        ON market_sigma.trading_dt = symbol_calc.trading_dt
),

symbol_risk_score AS (
    SELECT
        symbol_risk.*
        -- [2026-09-25] W1/W2/W3 THAT tu risk_wc_sector_scalar (xem CTE o tren),
        -- thay cho hardcode 1/3 truoc day. CROSS JOIN an toan vi risk_wc_sector
        -- _scalar chi co 1 dong (aggregate khong GROUP BY).
        , CAST(
              COALESCE(risk_wc_sector_scalar.w1_drawdown, 0)   * COALESCE(symbol_risk.pdrawdown_i, 0)
            + COALESCE(risk_wc_sector_scalar.w2_volatility, 0) * COALESCE(symbol_risk.pvolatility_i, 0)
            + COALESCE(risk_wc_sector_scalar.w3_selling, 0)    * COALESCE(symbol_risk.pselling_i, 0)
          AS decimal(5,2)) AS stress_score_i
    FROM symbol_risk
    CROSS JOIN risk_wc_sector_scalar
),

-- [MOI 2026-09-23] Sector-day aggregate: total_val_sector, total_market_cap
-- _sector va stress_score_sector (WEIGHTED AVERAGE theo ty trong von hoa
-- market_cap_i / SUM(market_cap nganh,ngay) theo dung cong thuc LLD moi,
-- thay cho AVG don gian truoc day).
sector_day_agg AS (
    SELECT
        symbol_risk_score.business_line_level_1_code
        , symbol_risk_score.trading_dt
        , SUM(CASE WHEN symbol_risk_score.stock_tp_code = '2' THEN symbol_risk_score.daily_val END)   AS total_val_sector
        , SUM(symbol_risk_score.market_cap)                                     AS total_market_cap_sector
        , SUM(CASE WHEN symbol_risk_score.stock_tp_code = '2' THEN symbol_risk_score.market_cap END) AS total_market_cap_sector_stock
        , SUM(symbol_risk_score.stress_score_i * symbol_risk_score.market_cap)
            / NULLIF(SUM(symbol_risk_score.market_cap), 0)                      AS stress_score_sector_raw
    FROM symbol_risk_score
    GROUP BY symbol_risk_score.business_line_level_1_code, symbol_risk_score.trading_dt
),

-- LAG 1 buoc o muc nganh/ngay de lay stress_score_sector cua ky truoc
sector_stress_lag AS (
    SELECT
        sector_day_agg.*
        , CAST(sector_day_agg.stress_score_sector_raw AS decimal(5,2)) AS stress_score_sector
        , CAST(
              LAG(sector_day_agg.stress_score_sector_raw) OVER (
                  PARTITION BY sector_day_agg.business_line_level_1_code
                  ORDER BY sector_day_agg.trading_dt
              )
          AS decimal(5,2)) AS stress_score_sector_previous_day
    FROM sector_day_agg
),

-- [MOI 2026-09-23] Cac cot chi tinh cho DUNG etl_date (khong can lich su):
-- total_trading_val_matched_sector, foreign_net_val_sector,
-- proprietary_net_val_sector - theo dung LLD (WHERE trade_dt = :etl_date).
-- [2026-10-09 LLD O_PTTT_43] total_trading_val_matched_sector = SUM(snapshot.total_trading_val)
-- cua ban ghi trading_time moi nhat moi ma, floor 02/04/10, KHONG loc stock_tp_code, tai etl_date.
se_tr_matched_sector AS (
    SELECT
        COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED') AS business_line_level_1_code   -- [2026-10-28 BA chot] co phieu khong co ho so cong ty -> Chua phan nganh
        , SUM(se_tr_snpst.total_trading_val) AS total_trading_val_matched_sector
    FROM se_tr_snpst
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_snpst.symbol
    WHERE se_tr_snpst.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND se_tr_snpst.stock_tp_code = '2'   -- [2026-10-28 BA chot] chi lay CO PHIEU (bo chung quyen, chung chi quy, trai phieu)
    GROUP BY COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED')
),

-- [2026-10-09 LLD O_PTTT_43] foreign/proprietary net: giu atm_securities_trade (can co loai NDT cua
-- so lenh) nhung noi ma -> nganh qua security_trading_snapshot (sts): HOSE symbol =
-- security_symbol_code; HNX isin_code = security_symbol_code (A17 - LLD chua xac nhan ISSUE_CODE
-- HNX la ISIN). sts lay ban ghi trading_time moi nhat cua ngay etl_date.
sts_raw AS (
    SELECT
        ticker_symbol AS symbol
        , isin_code
        , ds_snpst_dt AS trading_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND floor_code IN ('02','04','10')   -- [2026-10-28 BA chot] foreign/proprietary net chi tinh CO PHIEU san 02/04/10
        AND stock_tp_code = '2'
),

sts AS (
    SELECT symbol, isin_code, trading_dt
    FROM sts_raw
    WHERE rn = 1
),

se_tr_trade_day AS (
    SELECT
        sts.symbol
        , se_tr.execution_vol
        , se_tr.execution_price
        , se_tr.buy_account_nbr
        , se_tr.sell_account_nbr
    FROM {{ ref('atm_securities_trade') }} se_tr
    INNER JOIN sts
        ON sts.trading_dt = se_tr.trade_dt
        AND (
            (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND sts.symbol = se_tr.security_symbol_code)
            OR (se_tr.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND sts.isin_code = se_tr.security_symbol_code)
        )
    WHERE se_tr.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND se_tr.market_id_code IN ('STK','STO','STX','UPX')
),

se_tr_trade_sector AS (
    SELECT
        COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED') AS business_line_level_1_code   -- [2026-10-28 BA chot] co phieu khong co ho so cong ty -> Chua phan nganh
        , SUM(CASE WHEN SUBSTR(se_tr_trade_day.buy_account_nbr, 4, 1) IN ('E','F')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)
          - SUM(CASE WHEN SUBSTR(se_tr_trade_day.sell_account_nbr, 4, 1) IN ('E','F')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)  AS foreign_net_val_sector
        , SUM(CASE WHEN SUBSTR(se_tr_trade_day.buy_account_nbr, 4, 1) IN ('A','E','P')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)
          - SUM(CASE WHEN SUBSTR(se_tr_trade_day.sell_account_nbr, 4, 1) IN ('A','E','P')
                THEN se_tr_trade_day.execution_vol * se_tr_trade_day.execution_price ELSE 0 END)   AS proprietary_net_val_sector
    FROM se_tr_trade_day
    LEFT JOIN pu_co
        ON pu_co.equity_ticker_symbol = se_tr_trade_day.symbol
    GROUP BY COALESCE(pu_co.business_line_level_1_code, 'UNCLASSIFIED')
),

-- [MOI 2026-09-23] total_outstanding_share_quantity_sector - dung lai
-- oss_latest (1 ban ghi/ma CK, gan nhat <= etl_date) JOIN pu_co theo nganh.
oss_by_sector AS (
    SELECT
        pu_co.business_line_level_1_code
        , SUM(oss_latest.outstanding_share_quantity) AS total_outstanding_share_quantity_sector
    FROM pu_co
    INNER JOIN oss_latest
        ON oss_latest.ticker_symbol = pu_co.equity_ticker_symbol
    GROUP BY pu_co.business_line_level_1_code
),

-- [MOI 2026-09-24] LOOKUP status_threshold_config cho sector_rating, xem
-- ghi chu dau file.
threshold_stress_score AS (
    SELECT
        from_value
        , to_value
        , status AS sector_rating
    FROM {{ ref('atm_status_threshold_config') }}
    WHERE index_code = 'STRESS_SCORE'
        AND ds_rcrd_st = 'ACTIVE'
),

-- [MOI 2026-09-25] Chain LNST (Loi Nhuan Sau Thue) cho net_profit_after_tax
-- _amt_sector va sector_pe - dung LAI pc_rpt_sub_latest (cung logic dedup ky
-- bao cao HN>TH>ME>RI + ky gan nhat da dung cho sector_debt_score), chi khac
-- fin_value_joined_pl loc rpt_code LIKE 'BCKQKD%' (Bao cao Ket qua Kinh doanh)
-- thay vi 'BCDKT%' (Bang Can doi Ke toan) cua fin_value_joined.
fin_value_joined_pl AS (
    SELECT
        s.pc_id
        , s.rpt_year
        , s.rpt_quarter
        , fc.enterprise_tp_code
        , frt.row_description_reference
        , fclt.column_description_reference
        , fv.cell_val
    FROM pc_rpt_sub_dedup s   -- [2026-10-28 BA chot] doc moi ky da duyet (khong chi ky nop gan nhat) de lui ve ky gan nhat CO LNST
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
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.ds_rcrd_st = 'ACTIVE'
),

-- Pivot LNST theo pc_id: row_description_reference DN/BH='60' (LNST sau thue
-- TNDN), TD='21' (theo LLD dong 16/17), column_description_reference='1'
-- (cot ky nay, giong het column filter da dung cho total_liabilities/
-- owner_equity).
fin_pivot_pl_period AS (
    SELECT
        fin_value_joined_pl.pc_id
        , fin_value_joined_pl.rpt_year
        , fin_value_joined_pl.rpt_quarter
        , MAX(CASE
            WHEN (fin_value_joined_pl.enterprise_tp_code IN ('DN','BH') AND fin_value_joined_pl.row_description_reference = '60')
                OR (fin_value_joined_pl.enterprise_tp_code = 'TD' AND fin_value_joined_pl.row_description_reference = '21')
                THEN
                    CASE WHEN fin_value_joined_pl.column_description_reference = '1' THEN fin_value_joined_pl.cell_val END
          END) AS net_profit_after_tax_amt
    FROM fin_value_joined_pl
    GROUP BY fin_value_joined_pl.pc_id, fin_value_joined_pl.rpt_year, fin_value_joined_pl.rpt_quarter
),

-- [2026-10-28 BA chot] ky bao cao GAN NHAT CO LNST cua tung cong ty (lui ve ky truoc neu ky moi nhat khong co LNST)
fin_pivot_pl AS (
    SELECT pc_id, net_profit_after_tax_amt
    FROM (
        SELECT
            p.pc_id
            , p.net_profit_after_tax_amt
            , ROW_NUMBER() OVER (PARTITION BY p.pc_id ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS rn
        FROM fin_pivot_pl_period p
        WHERE p.net_profit_after_tax_amt IS NOT NULL
    ) x
    WHERE x.rn = 1
),

-- Gia dong cua TAI DUNG etl_date (khong phai ca so 60 ngay), floor_code IN
-- ('02','04','10') - dung dung LLD dong 17 (tu so sector_pe).
se_tr_pe AS (
    SELECT
        symbol
        , close_price
    FROM se_tr_snpst
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- [MOI 2026-09-25] SUM LNST toan nganh (net_profit_after_tax_amt_sector) va
-- tu so sector_pe (SUM close_price*outstanding_share_quantity cua CHINH cac
-- ma CO LNST - INNER JOIN fin_pivot_pl dam bao chi tinh ma co LNST, tuong
-- duong dieu kien "WHEN lnst.lnst IS NOT NULL" cua LLD). Mau so sector_pe =
-- chinh net_profit_after_tax_amt_sector (2 chi tieu dung chung 1 SUM LNST
-- nganh theo dung cong thuc LLD dong 16/17).
sector_pl_agg AS (
    SELECT
        pu_co.business_line_level_1_code
        , SUM(fin_pivot_pl.net_profit_after_tax_amt)             AS net_profit_after_tax_amt_sector
        , SUM(CASE WHEN fin_pivot_pl.net_profit_after_tax_amt IS NOT NULL
                    AND se_tr_pe.close_price > 0 AND oss_latest.outstanding_share_quantity > 0
                   THEN se_tr_pe.close_price * oss_latest.outstanding_share_quantity END) AS sector_pe_numerator
        , SUM(CASE WHEN se_tr_pe.close_price > 0 AND oss_latest.outstanding_share_quantity > 0
                   THEN fin_pivot_pl.net_profit_after_tax_amt END) AS sector_pe_denominator
    FROM pu_co
    INNER JOIN fin_pivot_pl
        ON fin_pivot_pl.pc_id = pu_co.pc_id
    LEFT JOIN oss_latest
        ON oss_latest.ticker_symbol = pu_co.equity_ticker_symbol
    LEFT JOIN se_tr_pe
        ON se_tr_pe.symbol = pu_co.equity_ticker_symbol
    GROUP BY pu_co.business_line_level_1_code
)

SELECT
    CAST(date_format(sector_stress_lag.trading_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(sc.sector_dim_id AS string)                                          AS industry_dim_id,
    CAST(sector_stress_lag.total_val_sector AS decimal(23,2))                 AS total_val_sector,
    CAST(sector_stress_lag.total_market_cap_sector AS decimal(23,2))          AS total_market_cap_sector,
    CAST(sector_stress_lag.stress_score_sector AS decimal(5,2))               AS stress_score_sector,
    CAST(
        sector_stress_lag.total_val_sector / NULLIF(sector_stress_lag.total_market_cap_sector_stock, 0)
    AS decimal(38,20))                                                          AS sector_liquid_score,
    CAST(sector_stress_lag.stress_score_sector_previous_day AS decimal(5,2))  AS stress_score_sector_previous_day,
    CAST(
        sector_stress_lag.stress_score_sector - sector_stress_lag.stress_score_sector_previous_day
    AS decimal(5,2))                                                          AS sector_stress_delta,
    CAST(threshold_stress_score.sector_rating AS string)                      AS sector_rating,
    CAST(
        sector_debt_agg.total_liabilities_sector / NULLIF(sector_debt_agg.owner_equity_sector, 0)
    AS decimal(8,4))                                                          AS sector_debt_score,
    CAST(se_tr_matched_sector.total_trading_val_matched_sector AS decimal(23,2)) AS total_trading_val_matched_sector,
    CAST(se_tr_trade_sector.foreign_net_val_sector AS decimal(23,2))          AS foreign_net_val_sector,
    CAST(se_tr_trade_sector.proprietary_net_val_sector AS decimal(23,2))      AS proprietary_net_val_sector,
    CAST(oss_by_sector.total_outstanding_share_quantity_sector AS bigint)     AS total_outstanding_share_quantity_sector,
    CAST(sector_pl_agg.net_profit_after_tax_amt_sector AS decimal(23,2))      AS net_profit_after_tax_amt_sector, -- [MOI 2026-09-25] LLD dong 16
    CAST(
        ROUND(sector_pl_agg.sector_pe_numerator / NULLIF(sector_pl_agg.sector_pe_denominator, 0), 2)
    AS decimal(10,2))                                                        AS sector_pe -- [MOI 2026-09-25] LLD dong 17
FROM sector_stress_lag
LEFT JOIN {{ ref('dtm_sector_dim') }} sc
    ON sc.industry_code = sector_stress_lag.business_line_level_1_code
    AND sc.ds_rcrd_st = 'ACTIVE'
LEFT JOIN se_tr_matched_sector
    ON se_tr_matched_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
LEFT JOIN se_tr_trade_sector
    ON se_tr_trade_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
LEFT JOIN oss_by_sector
    ON oss_by_sector.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
LEFT JOIN sector_debt_agg
    ON sector_debt_agg.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
LEFT JOIN sector_pl_agg
    ON sector_pl_agg.business_line_level_1_code = sector_stress_lag.business_line_level_1_code
LEFT JOIN threshold_stress_score
    ON sector_stress_lag.stress_score_sector
        BETWEEN CAST(threshold_stress_score.from_value AS decimal(5,2))
            AND CAST(threshold_stress_score.to_value AS decimal(5,2))
WHERE sector_stress_lag.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
