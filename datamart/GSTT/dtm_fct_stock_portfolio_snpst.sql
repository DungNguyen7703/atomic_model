/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_stock_portfolio_snpst
* Program name: Dtm Fct Stock Portfolio Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		tuan.nguyenvanb		[SUA theo LLD v4.49] (1) Them 2 cot measure moi
*                                       foreign_buy_derivative_vol / foreign_sell_derivative_vol
*                                       (K_GSTT_374, K_GSTT_375 - KL mua/ban phai sinh cua NDTNN,
*                                       market_id_code='DVX', board_tp_code NOT IN T1-T4,T6,R1,
*                                       xac dinh NDTNN qua SUBSTR(buy/sell_account_nbr,4,1) IN
*                                       F,E theo dung etl_logic LLD) - them vao CTE se_tr_dv_frn;
*                                       chen SAU foreign_net_derivative_vol, TRUOC
*                                       fr_period_end_dt_dim_id. Model insert theo VI TRI cot:
*                                       ALTER ... ADD COLUMN ... AFTER foreign_net_derivative_vol.
*                                       (2) Chuan hoa Market ID co phieu/CCQ thanh
*                                       IN (UPX,STX,STK,STO) o se_tr_mt, se_tr_mt_matched,
*                                       se_tr_ng, se_tr_ng_frn (truoc thieu STO).
*                                       (3) se_tr_dv_frn (foreign_net_derivative_vol, K_GSTT_148)
*                                       them dieu kien board_tp_code NOT IN T1-T4,T6,R1 (DVX co
*                                       bang thoa thuan). Nhom Top (total_vol/val, high/low) khong
*                                       doi logic.
* 2026-09-29b		tuan.nguyenvanb		[LLD a27bc1b, fallback Nganh CTCK, O_GSTT_37] Them cot
*                                       moi securities_company_dim_id (FK, reuse QLKD
*                                       Securities Company, nguon SCMS.SC_FIRM_INFO) - dung
*                                       lam fallback K_GSTT_2 (Nganh) khi mã CK la CTCK dai
*                                       chung khong co trong IDS.COMPANY_PROFILES nen
*                                       public_company_dim_id NULL. Them dieu kien loai tru
*                                       trai phieu Chinh phu/Kho bac (pattern [xx]GB..., tien
*                                       to TD/TP/CP/QH/KB/BL, HCM.../HAN...) truoc khi ap
*                                       SUBSTR(symbol,1,3) cho nhanh trai phieu, tranh gan
*                                       nham Nganh khi trung ten ngau nhien voi ticker co
*                                       phieu that. Model la incremental_rebase/append (insert
*                                       theo VI TRI cot) - cot moi PHAI ALTER ADD COLUMN ...
*                                       AFTER public_company_dim_id dung vi tri (xem DDL kem
*                                       theo). CANH BAO: gia tri thuc te cua provisional_
*                                       status_code chua duoc xac nhan ('0'/NULL theo gia
*                                       dinh LLD) - can Data Modeler xac nhan lai; danh sach
*                                       tien to trai phieu Chinh phu cung CHUA duoc xac nhan
*                                       day du 100% (xem O_GSTT_37).
* 2026-09-29		tuan.nguyenvanb		[LLD 38edf44, redesign Nhom 34] Them 5 cot vat ly moi:
*                                       weighted_average_outstanding_share_quantity(_ttm),
*                                       owner_equity_weighted_average_outstanding_share_
*                                       quantity(_ttm), owner_equity_average_4_quarter -
*                                       thay AVG(outstanding_share_quantity) theo quy LICH
*                                       (sai, da xac minh qua check-loi-so-lieu case ACB:
*                                       KLLH binh quan phai la WAOS gia quyen theo so ngay
*                                       hieu luc, neo dung khung ky BCTC gan nhat, khong
*                                       phai quy duong lich cua ngay giao dich). Dao nguoc
*                                       quyet dinh cu 2026-09-04 (VCSH binh quan 4 quy tung
*                                       la SUM, nay sua thanh AVG dung). CANH BAO: 2 cot
*                                       owner_equity_weighted_average_outstanding_share_
*                                       quantity(_ttm) hien TAM THOI dung chung khung ngay
*                                       voi nhanh LNST (owner_equity_val goc cung dang dung
*                                       chung ranking, khong doc lap nhu LLD mo ta) - xem
*                                       chi tiet canh bao ngay truoc CTE waos_frame_quy.
*                                       Model la incremental_rebase/append (insert theo VI
*                                       TRI cot) - 5 cot moi PHAI ALTER ADD COLUMN ... AFTER
*                                       owner_equity dung vi tri (xem DDL kem theo).
* 2026-09-28b		tuan.nguyenvanb		[DOI KIEN TRUC] Bo dedup equity_ticker o ODS (ods_ids_
*                                       company_profiles.sql) - ODS/atomic gio lay nguyen ban
*                                       ghi nguon, ke ca truong hop 1 ticker gan nhieu pc_id
*                                       (vd BID: id=266/10174 cung active). Dedup chuyen xuong
*                                       lai CTE pu_co tai day (them lai row_number partition
*                                       by equity_ticker_symbol order by CAST(pc_code AS
*                                       bigint) - LUU Y dung pc_code (=id nguon that) chu
*                                       KHONG dung pc_id (surrogate key hash, khong con thu
*                                       tu tuong ung voi id nguon) - tuong tu patch tam thoi
*                                       2026-09-25 da revert ngay ben duoi, nhung lan nay la
*                                       fix CHINH THUC theo kien truc moi, khong phai tam
*                                       thoi. CTE pc_fin_all da co dedupe tu truoc (2026-09-
*                                       17) nhung dang order by pc_id (SAI - cung loi hash
*                                       key nhu tren) - sua lai order by CAST(pc_code AS
*                                       bigint) cho dong bo, vi anh huong truc tiep viec chon
*                                       dung cong ty khi lay Revenue/NPAT/VCSH (pc_financials).
* 2026-09-30b		tuan.nguyenvanb		[REVIEW LLD 2026-09-30] (1) THEM 4 cot thieu: total_derivative_
*                                       negotiated_vol/val (DVX + board T1..R1, CTE se_tr_dv_ng)
*                                       va bond_negotiated_vol/val (BDO/HCX + board T1..R1, CTE
*                                       se_tr_bd_ng), chen ngay sau total_derivative_val va
*                                       bond_trading_val. (2) se_tr_bd: market_id_code doi
*                                       ('HCX') -> ('BDO','HCX') theo LLD. Giu nguyen foreign_
*                                       net_negotiated_vol (co trong mart, LLD khong co - cho
*                                       Data Modeler chot). CAN ALTER ADD COLUMN ... AFTER (xem
*                                       scratch/deploy_gstt_ddl_20260930.sql).
* 2026-09-30		tuan.nguyenvanb		[SUA theo LLD 2026-09-30] BO 10 cot individual_net_val,
*                                       domestic_institution_net_val, individual_buy/sell_
*                                       val/vol, domestic_institution_buy/sell_val/vol khoi
*                                       Fact Stock Portfolio Snapshot (LLD chi con 46 cot) -
*                                       GD theo phan loai NDT (ca nhan/to chuc trong nuoc)
*                                       nam o fct_investor_category_trading_snpst. Bo luon
*                                       phan tinh toan tuong ung trong CTE se_tr_mt. CAN ALTER
*                                       TABLE DROP COLUMN o mart + ClickHouse flat (xem
*                                       scratch/deploy_gstt_ddl_20260930.sql).
* 2026-09-28		tuan.nguyenvanb		[FIX BUG TRAN SO] Toan bo cot so luong/khoi luong dang
*                                       CAST(...AS int) doi sang CAST(...AS bigint) - INT32
*                                       toi da 2.147.483.647, cac mã co free_float_share_
*                                       quantity/khoi luong vuot nguong nay bi WRAP-AROUND
*                                       (vd ACB: dung 5.524.388.622 nhung ra 1.229.421.326 =
*                                       5.524.388.622 - 4.294.967.296). Phat hien qua doi
*                                       chieu K_GSTT_75/76 - atomic dung, BA dung, mart sai
*                                       ON DINH qua nhieu lan build (ke ca build don le,
*                                       khong dong thoi) => xac nhan la bug CODE (CAST), khong
*                                       phai Spark/Iceberg stale cache nhu nghi truoc do. Cac
*                                       cot doi: total_vol, total_matched_vol, total_derivative_
*                                       vol, total_negotiated_vol, foreign_net_vol, foreign_buy_
*                                       vol, foreign_sell_vol, proprietary_buy_vol, proprietary_
*                                       sell_vol, bond_trading_vol, individual_buy_vol,
*                                       individual_sell_vol, domestic_institution_buy_vol,
*                                       domestic_institution_sell_vol, free_float_share_quantity,
*                                       foreign_net_negotiated_vol, foreign_net_derivative_vol.
*                                       CAN ALTER TABLE doi kieu cot vat ly Iceberg tuong ung
*                                       TRUOC khi chay lai model (xem scratch/alter_
*                                       fct_stock_portfolio_snpst_int_to_bigint.sql).
* 2026-09-26		tuan.nguyenvanb		[REVERT] pu_co fan-out (1 ma/ngay ra 2-3 dong public_
*                                       company_dim_id, gay idx_market_cap/idx_pe/idx_pb sai
*                                       tren dtm_fct_index_constituent_snpst) - da xac dinh
*                                       dung ROOT CAUSE nam o tang ODS (ods_ids_company_
*                                       profiles thieu dedupe equity_ticker so voi ban v1 da
*                                       fix tu 2026-09-12), KHONG phai o pu_co. Revert patch
*                                       tam thoi o day, fix dung cho tai ods_ids_company_
*                                       profiles.sql (xem changelog file do) de bao ve dung 1
*                                       lan cho toan bo downstream (atm_public_company, pc_fin,
*                                       pu_co, dtm_public_company_dim...) thay vi va tung cho.
* 2026-09-25b		tuan.nguyenvanb		[LLD moi tu Data Modeler, lan 2 cung ngay] To chuc
*                                       trong nuoc (domestic_institution_buy/sell_val/vol)
*                                       DOI TIEP - ban dau ngay (individual_* / domestic_
*                                       institution_* voi dieu kien AND don gian) van SAI:
*                                       tap [foreign='00' AND investor_tp<>'8000'] VAN CHUA
*                                       ca lenh tu doanh (khong loai truoc qua dieu kien AND
*                                       client_house='10'), phai TRU RIENG so hang tu doanh
*                                       (client_house='30') ra. Cong thuc dung: TC = SUM(
*                                       foreign='00' AND investor_tp<>'8000') - SUM(client_
*                                       house='30'). individual_* KHONG doi (van dung dieu
*                                       kien AND nhu truoc). Dung y het fct_investor_category_
*                                       trading_snpst - xem changelog day du tai do.
* 2026-09-25		tuan.nguyenvanb		[LLD moi tu Data Modeler, khop BA STT 28 dong 402]
*                                       Sua lai 10 cot individual_* / domestic_institution_*
*                                       (buy/sell val/vol) trong CTE se_tr_mt: Ca nhan trong
*                                       nuoc = client_house_cl_code='10' AND foreign_investor_
*                                       tp_code='00' AND investor_tp_code='8000'; To chuc
*                                       trong nuoc = giong het nhung investor_tp_code<>'8000'.
*                                       Bo hoan toan bang ma dai re nhanh theo src_stm_code
*                                       HOSE/HNX va loai tru cheo <>'30'/NOT IN('10','20')
*                                       cua ban 2026-09-19 (LLD xac nhan da loi thoi). Khong
*                                       loc board_tp_code (Nhom 35 khong gioi han khop lenh,
*                                       dong nhat co so voi foreign_* / proprietary_*).
* 2026-09-23/24	tuan.nguyenvanb		[DA DIEU TRA XONG, KHONG SUA CODE MART - LOI O ODS]
*                                       Phat hien qua doi chieu HVN: LNST TTM sai (dashboard
*                                       1,254,465,458,111 vs BA test 4,186,036,104,931). Da thu
*                                       nhieu huong sua tai pc_rpt_sub_valid (prs.submission_dt
*                                       <= etl_date, roi prs.ds_rcrd_eff_dt/end_dt point-in-
*                                       time cua SCD2) - CA HAI DEU SAI/KHONG GIAI QUYET DUOC,
*                                       da REVERT HET ve nguyen ban (chi con ds_rcrd_st=
*                                       'ACTIVE', khong them dieu kien nao).
*                                       ROOT CAUSE THAT SU (xac nhan qua doi chieu truc tiep
*                                       STG vs ODS): STG (UAT_IDS_STG.company_data/data, co
*                                       ds_snpst_dt giu dung lich su tung ngay) tai 2026-08-28
*                                       cho thay bao cao Q2/2026 cua HVN con la DRAFT (chua
*                                       duyet) - dung nhu BA test (doc truc tiep STG loc dung
*                                       ds_snpst_dt=Den_ngay). NHUNG ODS (UAT_IDS_ods.company_
*                                       data/data) la UPSERT/SCD1 (KHONG giu lich su, chi luu
*                                       DONG MOI NHAT theo id) - dang cho thay ds_snpst_dt=
*                                       2026-09-21 (APPROVED) cho CUNG ban ghi Q2/2026, vi job
*                                       daily that (ngay 21/09) da chay SAU lan backdate 28/08,
*                                       ghi de ODS ve trang thai moi nhat. atm_pc_report_
*                                       submission/atm_fr_value build tu ODS nen ke thua dung
*                                       trang thai SAI nay (khong lien quan gi SCD2/atomic).
*                                       ods_ids_data.sql/ods_ids_company_data.sql da kiem tra
*                                       KHONG SAI (co dung WHERE ds_snpst_dt=etl_date) - loi
*                                       chi la do THU TU CHAY (backdate 28/08 chay TRUOC, sau
*                                       do job that ngay moi hon ghi de len).
*                                       FIX: KHONG sua code mart. Da TRUNCATE + chay lai
*                                       stg_ids_data/company_data/forms -> ods_ids_data/
*                                       company_data/forms -> atm_pc_report_submission/
*                                       atm_fr_value -> dtm_fct_stock_portfolio_snpst ->
*                                       gstt_fct_stock_portfolio_snpst_flat cho dung 2026-08-28
*                                       LA LAN CHAY CUOI CUNG (xem scratch/backdate_fix_ods_
*                                       atm_20260828.json). LUU Y: day la fix MOT LAN, KHONG
*                                       BEN VUNG - vi ODS khong giu lich su, bat ky job daily
*                                       that nao chay cho ngay SAU 28/08 sau lan fix nay se lai
*                                       ghi de ODS va lam sai lai. Voi xu ly DAILY THUC TE (moi
*                                       ngay chay dung ngay hien tai, khong co backdate xen vao
*                                       giua) van de nay KHONG xay ra.
* 2026-09-23		tuan.nguyenvanb		[FIX QUAN TRONG, phat hien qua doi chieu CW] JOIN
*                                       pc_financials o SELECT cuoi dang dung SAI se_tr_sn.
*                                       company_join_symbol (= underlying_symbol cho chung
*                                       quyen stock_tp_code='4') thay vi se_tr_sn.symbol -
*                                       khien CW nhan NHAM tai chinh (revenue/LNST TTM/VCSH,
*                                       keo theo PE/PB) cua chinh CONG TY CO SO, thay vi phai
*                                       la NULL (CW khong phai co phieu cong ty, khong co
*                                       BCTC rieng). Phat hien qua doi chieu 2 ma CW cung co
*                                       so (CSTB2606/CSTB2604, underlying=STB) ra PE/PB GIONG
*                                       HET nhau - dau hieu ro dang bi gop chung 1 nguon tai
*                                       chinh. Day la REGRESSION cua bug da tung fix (xem
*                                       changelog 2026-09-11 "revert pc_financials/free_float_
*                                       val ve se_tr_sn.symbol") - bi quay lai dung company_
*                                       join_symbol o 1 lan sua sau do. Da doi lai ve
*                                       se_tr_sn.symbol. free_float_val/oss_val/prior_val
*                                       kiem tra lai deu dang dung dung symbol, khong bi anh
*                                       huong. company_join_symbol chi con dung dung cho JOIN
*                                       pu_co (Nganh) - CW xep nganh theo cong ty co so la
*                                       chu dich dung thiet ke, khong doi.
* 2026-09-23		tuan.nguyenvanb		[FIX QUAN TRONG, phat hien qua doi chieu HKT] pc_rpt_
*                                       sub_recent4 TRUOC DAY rank tren TOAN BO pc_rpt_sub_
*                                       dedup (moi ky nop bao cao, bat ke form dung/sai) -
*                                       SAI cho case ky FORM SAI HOAN TOAN (HKT 2025-Q4: nop
*                                       dang RI nhung du lieu nam duoi catalog ME, khong
*                                       chi tieu nao khop) - van bi tinh la anchor, VCSH=0
*                                       SAI thay vi phai LUI ve ky hop le gan nhat (2025-Q3).
*                                       DOI sang rank tren pc_rpt_valid_periods (UNION cac ky
*                                       CO IT NHAT 1 trong 3 chi tieu Doanh thu/LNST/VCSH khop
*                                       dung form - dung y het khai niem Chitiet_DN cua cau
*                                       test). Van GIU NGUYEN quy tac 0-fill cho ky hop le
*                                       nhung thieu 1 chi tieu rieng (AMV 2026-Q1 - khong doi).
*                                       Da doi chieu dung voi cau test HKT: von_hoa khop 100%,
*                                       VCSH gio se ra dung tu ky 2025-Q3 thay vi 0.
* 2026-09-22		tuan.nguyenvanb		[FIX QUAN TRONG, BA CHOT lai qua doi chieu AMV] Doi
*                                       cach xac dinh "ky gan nhat" cho LNST/VCSH (npat_val/
*                                       owner_equity_val/npat_ttm_val): TRUOC DAY moi chi
*                                       tieu tu lui rieng ve ky KHAC de tim ky "co du lieu"
*                                       (vd LNST lui ve 2025-Q1 vi 2026-Q1 khong co LNST) -
*                                       SAI theo BA. DUNG: phai neo theo ky NOP BAO CAO gan
*                                       nhat cua cong ty (bat ky co du lieu LNST/VCSH hay
*                                       khong), ky nao thieu thi tinh 0, KHONG lui ky. CTE moi
*                                       pc_rpt_sub_recent4 (rank tren pc_rpt_sub_dedup, khong
*                                       phai tren npat_by_period/owner_equity_by_period nua).
*                                       npat_ttm_val: SUM 4 ky nop bao cao gan nhat (khong con
*                                       yeu cau CASE COUNT(*)=4, thay bang COALESCE(...,0)).
*                                       Da xac nhan qua doi chieu that: AMV ky 2026-Q1 chi
*                                       nop VCSH (LNST NULL) - BA xac nhan van tinh LNST ky
*                                       do = 0 trong TTM. 4 ky dung theo luat moi la 2025-Q2/
*                                       Q3/Q4 + 2026-Q1(=0) -> ket qua ~-51,784,269,987 (KHOP
*                                       cau test BA, THAY THE ket qua -55,171,263,845 cua
*                                       logic loi cu - logic cu lui ve lay them 2025-Q1 la SAI
*                                       theo BA). LUU Y: dashboard ClickHouse dang hien
*                                       -55,171,263,845 (theo mart CU, truoc fix nay) - se doi
*                                       sau khi mart chay lai voi logic moi. revenue_val
*                                       (Doanh thu) CHUA doi - BA chua xac nhan co ap dung
*                                       tuong tu khong, CAN HOI LAI.
* 2026-09-22		tuan.nguyenvanb		[LLD moi, bo sung gap qua doi chieu BA<->KPI] Them cot
*                                       moi foreign_net_derivative_vol - KL mua rong NDTNN
*                                       tren thi truong phai sinh (market_id_code='DVX',
*                                       khop lenh, khong co board type thoa thuan rieng cho
*                                       phai sinh). CTE moi se_tr_dv_frn, cung pattern voi
*                                       se_tr_ng_frn (buy/sell_foreign_investor_tp_code IN
*                                       ('10','20')).
* 2026-09-22		tuan.nguyenvanb		[CHOT phuong an cuoi] Doi JOIN Nganh cho trai phieu
*                                       (stock_tp_code='1') tu equity_ticker_symbol=issuer_nm
*                                       (MDDS, ap dung 2026-09-21) sang equity_ticker_symbol=
*                                       SUBSTR(symbol,1,3) - lay 3 ky tu dau cua chinh ma
*                                       trai phieu lam ma cong ty phat hanh, theo dung quy
*                                       uoc dat ma trai phieu doanh nghiep VN. Ly do doi:
*                                       issuer_nm phu thuoc du lieu nguon MDDS khong sach
*                                       (BIDV/BVBV/HDA thay vi BID/BVB/HDB - da ghi nhan o
*                                       lan sua truoc). Bo cot issuer_nm khoi CTE se_tr_sn_all/
*                                       se_tr_sn (khong con dung). CAN DOI CHIEU LAI voi cau
*                                       test BA (tuong tu 3 bien the loi da biet o issuer_nm)
*                                       truoc khi coi la final.
* 2026-09-21		tuan.nguyenvanb		[FIX QUAN TRONG] JOIN Nganh cho trai phieu
*                                       (stock_tp_code='1') doi tu pu_co.pc_nm = issuer_nm
*                                       (join theo TEN cong ty - anti-pattern, LLD cu ghi
*                                       nham "Issuer Name") sang pu_co.equity_ticker_symbol
*                                       = issuer_nm (join theo MA). Xac nhan qua sample du
*                                       lieu that: cot issuername ben MDDS (tmp_jad_
*                                       stockinfor_eod) cho trai phieu THUC CHAT luu MA
*                                       TICKER cong ty phat hanh (VD KLB, LPB, CTG, SHB,
*                                       VHM...), khong phai ten day du - va cau test BA
*                                       tham khao cung join equity_ticker=issuername (ma
*                                       voi ma), khong join ten voi ten. Con sot vai bien
*                                       the sai chinh ta nguon (BIDV/BVBV/HDA thay vi
*                                       BID/BVB/HDB) - da bao BA/Design, khong xu ly duoc
*                                       bang logic join, can map cung thu cong neu can
*                                       chinh xac 100%. Bo cot pc_nm khoi CTE pu_co (khong
*                                       con dung).
* 2026-09-19		tuan.nguyenvanb		[BA CONFIRM] Doi chieu case ma SLS (HNX30, 20260826) -
*                                       cong ty nien do tai chinh lech (FY end 30/06), 2 ky
*                                       gan nhat (2026 Q1/Q2) co nop bao cao nhung THIEU
*                                       du lieu BCDKT/VCSH (chi co KQKD). revenue_val/
*                                       npat_val/npat_ttm_val/owner_equity_val dang LUI VE
*                                       ky gan nhat CO DU LIEU (bo qua ky trong) - BA DA
*                                       CHOT day la hanh vi DUNG (khong loai cong ty khoi
*                                       tong khi thieu 1 phan bao cao). Cau test BA doi
*                                       chieu KHONG co buoc lui ky nay nen ra NULL cho SLS -
*                                       XAC NHAN loi/gioi han nam o cau test, KHONG PHAI o
*                                       model. Giu nguyen logic hien tai, KHONG sua.
* 2026-09-19		tuan.nguyenvanb		[LLD de8cd57c] Dong bo theo cap nhat GSTT moi nhat:
*                                       (1) them cot high_price/low_price (direct tu
*                                       security_trading_snapshot, phuc vu K_GSTT_106/107
*                                       Gia cao/thap nhat 52 tuan - BA dao nguoc quyet
*                                       dinh cu dung Close Price, quay lai dung High/Low
*                                       Price); (2) them prior_market_cap/prior_free_float_
*                                       market_cap (von hoa mã tai PHIEN GIAO DICH LIEN
*                                       TRUOC that su - xem O_GSTT_25, phuc vu K_GSTT_74/76
*                                       Ty trong trong chi so, truoc day dung nham von hoa
*                                       ngay T gay lech 1 phien so voi Return_i/prior_index) -
*                                       implement bang SELF-REFERENCE {{ this }} (doc lai
*                                       gia tri da luu tren dong T-1), khong recompute tu
*                                       atomic; (3) [FIX QUAN TRONG, BA cap nhat STT 28]
*                                       Phan loai Ca nhan/To chuc trong nuoc doi lai dung
*                                       Investor Type Code (re nhanh theo src_stm_code HOSE/
*                                       HNX vi cung ma so khac nghia giua 2 san) - THAY THE
*                                       cach lam SUBSTRING(account_nbr,4,1) cu (da bi BA thu
*                                       hoi), xem CTE se_tr_mt. CAN RAISE DESIGN neu con lech
*                                       so voi test moi.
* 2026-09-19		tuan.nguyenvanb		[RENAME] cdr_dt_dim_id -> snpst_dt_dim_id. Dong bo
*                                       ten cot voi convention cac Fact "_snpst" khac (VD
*                                       dtm_fct_index_constituent_snpst, dtm_fct_market_index_snpst
*                                       dung "snpst_dt_dim_id"), tranh nham lan voi PK cua
*                                       chinh dtm_cdr_dt_dim ("cdr_dt_dim_id"). Rename bang
*                                       ALTER TABLE ... RENAME COLUMN tren Iceberg - an toan,
*                                       khong rewrite du lieu (Iceberg track theo field-id,
*                                       khong theo ten, partition spec tu dong cap nhat theo).
*                                       Da sua downstream: gstt_fct_stock_portfolio_snpst_flat.sql
*                                       (JOIN/WHERE) va schema_dtm_gstt.yml (partition_by).
* 2026-09-17		tuan.nguyenvanb		[FIX] owner_equity/net_profit_after_tax/revenue/
*                                       npat_ttm luon NULL - JOIN atm_fr_catalog dung SAI
*                                       2 cot (doi chieu cau test BA + LLD):
*                                       (1) fc.fr_catalog_code LIKE 'BCKQKD%'/'BCDKT%' -
*                                       fr_catalog_code map tu re_ca.id (ID so), so LIKE
*                                       voi ma bao cao luon FALSE -> doi sang fc.rpt_code
*                                       (map tu report_cd, dung nhu test: rc.report_cd).
*                                       (2) fc.financial_statement_component_tp_code =
*                                       SUBSTR(fr_template_code,1,2) - cot nay map tu
*                                       ref_cd, khong phai loai BCTC -> doi sang
*                                       fc.financial_statement_tp_code (map tu
*                                       financial_statement_cd, dung nhu test:
*                                       rc.FINANCIAL_STATEMENT_CD va dung nhu LLD).
*                                       (3) [BO SUNG cung ngay] Van NULL sau (1)(2) -
*                                       trace tiep ra 5 khac biet nua so voi cau test, da
*                                       viet lai toan bo khoi tai chinh: doc _hstr thay vi
*                                       current-state, bo EXISTS violation_report (402->13
*                                       dong tren SHB), bo ep cung ky lien truoc (SHB khong
*                                       nop Q2/2026), dedupe theo ky TRUOC khi xep hang
*                                       (TTM tung gom 4 dong cung 1 ky), loc rpt_quarter
*                                       IN (1,2,3,4) (nguon IDS con ky 5/6). Xem ghi chu
*                                       chi tiet tai CTE pc_rpt_sub_valid. CAN RAISE DESIGN.
* 2026-09-16		tuan.nguyenvanb		[LLD b8868c9e] Remap outstanding_share_quantity tu
*                                       pc_share_statistics_hstr (IDS, khong co du lieu
*                                       hang ngay tren HNX/UPCOM -> ra rong) sang
*                                       listed_share_information (VSDC outstanding_shares,
*                                       src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo
*                                       dung nguon/pattern voi free_float_share_quantity
*                                       (lookback theo symbol, khong con qua pc_id).
* 2026-08-26		tuan.nguyenvanb		bo sung cong thuc outstanding_share_quantity/revenue/net_profit_after_tax/net_profit_after_tax_ttm/owner_equity theo LLD
* 2026-09-09		tuan.nguyenvanb		Cap nhat theo LLD 2026-09-04..09: (1) them close_price
*                                       (direct tu security_trading_snapshot), (2) sua
*                                       outstanding_share_quantity sang lookback (<=
*                                       trading_dt) thay vi khop dung ngay, (3) them
*                                       foreign_net_negotiated_vol (CTE rieng se_tr_ng_frn,
*                                       CO 'R1' - khac se_tr_ng cu KHONG co 'R1', xem
*                                       ghi chu O_GSTT_20 chua sua), (4) them
*                                       fr_period_end_dt_dim_id (format truc tiep, KHONG
*                                       join dtm_cdr_dt_dim - dung quy uoc cdr_dt_dim_id
*                                       chung cua GSTT), (5) them free_float_share_quantity
*                                       - CANH BAO phu thuoc atm_listed_share_information
*                                       CHUA TON TAI, xem canh bao chi tiet o CTE free_float_val.
*                                       Khong doi join financial_statement_component_tp_code
*                                       o revenue_val/npat_val/npat_ttm_val/owner_equity_val -
*                                       da xac nhan qua test round 1 la dung, giu nguyen.
* 2026-09-11		tuan.nguyenvanb		[FIX QUAN TRONG theo logic BA test moi] Toan bo JOIN
*                                       tu Fact toi atm_securities_trade (se_tr_mt/se_tr_dv/
*                                       se_tr_ng/se_tr_ng_frn/se_tr_bd) va toi Public Company
*                                       (pu_co) truoc day deu dung se_tr_sn.symbol (ticker
*                                       MDDS) - DUNG cho HOSE nhung SAI cho HNX/UPCOM/FDS:
*                                       atm_securities_trade phia HNX luu security_symbol_code
*                                       = issue_code (ISIN), khong phai ticker - JOIN cu bi
*                                       NULL toan bo du lieu khop lenh cua cac san nay. Them
*                                       2 cot tinh san trong se_tr_sn: trade_join_symbol (ISIN
*                                       cho floor 02/04/03, symbol cho floor 10 - dung JOIN
*                                       toi atm_securities_trade) va company_join_symbol
*                                       (underlying_symbol khi la chung quyen stock_tp_code=
*                                       '4', nguoc lai la symbol - CHI dung cho pu_co/Nganh).
*                                       in_co_sn/in_co_di/se_tr_sn_di van giu nguyen symbol goc.
* 2026-09-11		tuan.nguyenvanb		[FIX theo tu-review cua BA, issue Thuy] Ban sua dau
*                                       (cung ngay) ap NHAM company_join_symbol (CW dung
*                                       underlying_symbol) sang ca pc_financials (Revenue/
*                                       NPAT/NPAT_TTM/Owner Equity) va free_float_val - LLD
*                                       xac nhan CASE nay CHI ap dung cho pu_co (Nganh), cac
*                                       cho khac phai giu nguyen symbol MDDS thuan (tranh gan
*                                       nham tai chinh cong ty co so cho ma chung quyen). Da
*                                       revert pc_financials/free_float_val ve se_tr_sn.symbol.
*                                       Dong thoi bo sung filter con thieu (dong O_GSTT_20):
*                                       se_tr_ng them market_id_code IN ('UPX','STX','STK')
*                                       + 'R1' vao board_tp_code; se_tr_ng_frn them
*                                       market_id_code IN ('UPX','STX','STK').
* 2026-09-14		tuan.nguyenvanb		[SUA THEO HLD v4.13 + LLD cap nhat 2026-09-14]
*                                       (1) Bo FK index_constituent_dim_id - tach rieng sang
*                                       model moi dtm_fct_index_constituent_snpst (Bridge,
*                                       1 mã/1 chỉ số/ngày) de het fan-out theo ro chi so.
*                                       Xoa cac CTE in_co_sn_all/in_co_sn/in_co_di. (2) Them
*                                       cot moi total_matched_vol/total_matched_val (CTE
*                                       se_tr_mt_matched) - khop lenh THUAN, loai tru thoa
*                                       thuan (board_tp_code NOT IN T1-T4,T6,R1), phuc vu
*                                       nhom Top - KHONG doi nghia total_vol/total_val cu
*                                       (van giu nguyen, bao gom ca thoa thuan). (3) Bo sung
*                                       nhanh JOIN Nganh cho trai phieu (stock_tp_code='1'):
*                                       pu_co.pc_nm = issuer_nm (thay vi nhet issuer_nm vao
*                                       company_join_symbol roi so voi equity_ticker_symbol -
*                                       sai kieu du lieu, luon NULL). (4) fix not thieu dong
*                                       bo o npat_ttm_val: fclt join van dung
*                                       fr_column_template_code (id noi bo) - da doi ve
*                                       column_code + fr_catalog_id giong 3 CTE tai chinh
*                                       kia. (5) free_float_val doi lai sang ROW_NUMBER
*                                       dedupe (thay vi MAX(...) correlated subquery) -
*                                       MAX khong chong duoc data trung (tung la nguyen nhan
*                                       fan-out truoc khi fix o nguon), ROW_NUMBER an toan
*                                       hon du nguon co sach hay khong.
* 2026-10-06		tuan.nguyenvanb		[SUA theo LLD v4.32, rule GSDC - DTM_GSTT_fct_stock_portfolio_snpst.csv
*                                       dong Revenue/Net Profit After Tax] Revenue va Net Profit After
*                                       Tax (point-in-time) doi sang rule bao cao tai chinh cua GSDC:
*                                       BCTC DINH KY QUY (financial_report.news_tp_code='DINH_KY',
*                                       fr_code LIKE '%QUAR'), 1 bao cao/ky (HN>TH>ME>RI) roi lay ky
*                                       GAN NHAT co submission_dt <= etl_date; fr_value dedupe theo
*                                       ds_rcrd_udt_dt/ds_rcrd_isrt_dt/fr_val_code DESC, data_val IS
*                                       NOT NULL, fr_catalog.fr_year = rpt_year. Thay CTE revenue_val/
*                                       npat_val (them gsdc_fr_periodic/gsdc_sub_ranked/gsdc_sub_anchor/
*                                       gsdc_fr_value). Khac cu: (1) KHONG lui ky khi ky gan nhat thieu
*                                       chi tieu -> NULL (truoc: revenue lay ky gan nhat co revenue;
*                                       LNST COALESCE 0). (2) moc thoi gian la submission_dt (truoc:
*                                       period_end_dt). Net Profit After Tax TTM, Owner Equity, Fr Period
*                                       End Date, WAOS GIU NGUYEN. Cot dau ra KHONG doi -> khong can ALTER.
* 2026-10-16		tuan.nguyenvanb		[LLD v4.50, commit 1d908c6d] Them 2 cot securities_company_owner_equity (VCSH ky QUY gan nhat) va
*                                       securities_company_net_profit_after_tax_ttm (LNST 4 quy truot) cua CTCK tu SCMS
*                                       (TS359/TS223/TS221, TS121/TS119) - ghi o CUOI SELECT (sau fr_period_end_dt_dim_id) -> ALTER ... AFTER
*                                       fr_period_end_dt_dim_id. Gia dinh BCTCHN/BCTCRL qua cell_id nhu PTTT market_risk, can DM xac nhan.
* 2026-10-17		tuan.nguyenvanb		[DONG BO atm_securities_company moi] pc_indicator -> pc_ind; provisional_status_code (string '0') -> provisional_ind (int 0).
* 2026-10-19		tuan.nguyenvanb		[BA XAC NHAN] LNST TTM / VCSH cua CTCK (SCMS) dung CUNG rule voi IDS: ky hop le = co it nhat 1 chi tieu; TTM = SUM 4 ky nop gan nhat
*                                       (ky thieu LNST tinh 0, khong du 4 ky nop -> NULL); VCSH = ky gan nhat, thieu -> 0 (khong lui ky). Khong doi cot -> khong can ALTER.
* 2026-10-19		tuan.nguyenvanb		[UAT doi atm_sc_periodic_report / atm_sc_report_input_submission scd4a -> scd2] them spr.ds_rcrd_st/rpt_sub.ds_rcrd_st = 'ACTIVE' (scd2 giu ca ban ghi INACTIVE).
* 2026-10-23		tuan.nguyenvanb		[THEO BA] VCSH/LNST CTCK (SCMS): (1) bo dieu kien lnst/vcsh IS NOT NULL o scms_ctck_ranked (ky hop le = co bao cao nop);
*                                       (2) loc form qua atm_sc_report.rpt_code IN (BCTCHN,BCTCRL), TS121/TS359 chi lay tu BCTCHN, TS119/TS223/TS221 chi tu BCTCRL;
*                                       (3) ky da co BCTCHN thi chi lay hop nhat, khong roi xuong BCTCRL (has_hn). Khong doi cot -> khong can ALTER.
*                                       (4) loc SHEET_ID theo sheetCode nhu cau Oracle nguon (06620/TS359, 06622/TS121, 06608/TS223+TS221, 06610/TS119) qua
*                                       atomic moi atm_sc_report_deep_config (CTE scms_ctck_sheet) - CAN build atomic nay truoc khi chay.
* 2026-10-24		tuan.nguyenvanb		[TOI UU] Khoi SCMS: loc atm_sc_report_input_value xuong dung (sheet,cell) bang bang khoa nho scms_ctck_sheet (VALUES) o CTE scms_ctck_cell
*                                       truoc khi join ban nop (bo CASE trong dieu kien join); them ds_rcrd_st='ACTIVE' cho atm_sc_report. Khong doi ket qua/cot.
* 2026-10-24		tuan.nguyenvanb		[THEO BA] Khoi SCMS: gop ky o muc (CTCK, nam, ky) bang SUM xuyen cac ban nop moi nhat (truoc: MAX theo tung ban nop) - giong SUM ... GROUP BY cua BA; bo qua rn_sub theo form_report_id, xep hang theo (ky, loai bao cao). Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		[SUA, LLD v4.56-v4.57, O_GSTT_75] 4 cot proprietary_buy/sell_vol/val (se_tr_mt): Tu doanh xac dinh theo SO TK
*                                       mua/ban: SUBSTR(account_nbr,4,1) IN ('P','E') AND NOT IN ('F','E') = chi con 'P' (TK loai 'E' tinh Nuoc ngoai, loai tru
*                                       nhau theo thu tu uu tien Nuoc ngoai -> Tu doanh), thay buy/sell_client_house_cl_code='30'. Khong doi cot/kieu -> khong ALTER.
*                                       LUU Y: foreign_buy/sell_vol/val, foreign_net_negotiated_vol, foreign_net_derivative_vol van dung
*                                       foreign_investor_tp_code IN ('10','20') (LLD v4.49 da doi sang SUBSTR(account_nbr,4,1) IN F,E) - CHUA doi, cho xac nhan.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*--------------------------------------------------------------------*
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: listed_share_information.transaction_date->transaction_dt. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[DOI THEO CAU TEST BA, thay quy tac loai tru 2026-10-22 truoc do] Phan loai NDT DOC LAP nhu BA: Tu doanh = ky tu thu 4 IN ('P','E'); Nuoc ngoai = IN ('F','E'); Ca nhan = loai NDT '3', To chuc = '5' (khong xet ky tu thu 4) - mot lenh co the tinh vao nhieu nhom (TK loai E vua Tu doanh vua Nuoc ngoai). Pham vi sua: proprietary_*. Khong doi cot. CAN DONG BO LLD O_GSTT_75 (LLD dang ghi loai tru nhau).
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78] (a) THEM 30 cot cuoi bang: 24 cot lo chan/lo le (round_lot_*, odd_lot_*, derivative_*, bond_*; CTE se_tr_lot 1 lan quet),
*                                       open_interest_quantity (atm_end_of_day_open_interest, ma phai sinh stock_tp_code 4 san 02/03/04), ceiling_price, floor_price, open_price,
*                                       free_float_market_cap, market_cap. Gia tinh von hoa: san 04 UPCOM = VWAP ban tin cuoi ngay cua phien ke tiep (ngay nho nhat lon hon T tren
*                                       atm_market_index_snapshot), NULL neu chua co VWAP, VWAP = 0 thi lay gia tham chieu T; HOSE/HNX = gia dong cua. prior_market_cap / prior_free_float_market_cap
*                                       nay doc lai market_cap / free_float_market_cap da luu o dong T-1. (b) net_profit_after_tax_ttm va WAOS TTM: ky gan nhat la NAM (rpt_quarter 5) -> lay ky nam,
*                                       la QUY -> 4 quy gan nhat (phai du 4 quy); cac chi tieu khac (owner_equity, WAOS quy...) chi xet ky quy nhu cu. Can atomic moi vol_weighted_average_price.
*                                       Chay daily ngay T thi von hoa UPCOM NULL cho den khi co phien ke tiep - phai chay lai ngay T. Bang vat ly can ALTER ADD COLUMN theo vi tri (xem script).
* 2026-11-09		tuan.nguyenvanb		[LLD O_GSTT_80] Von hoa (market_cap, free_float_market_cap) theo SQL moi cua BA: (1) so CP VSDC khop DUNG ngay giao dich T (transaction_dt = T, khong lookback; thieu ban ghi -> von hoa NULL;
*                                       cac cot outstanding_share_quantity/free_float_share_quantity van lookback) qua CTE cap_shares; (2) phien ke tiep T+1 (gia UPCOM) = ngay nho nhat > T va <= T+1 thang trong HOP NHAT ngay giao dich
*                                       so lenh HNX (atm_securities_trade, ORDERTRADE_TRADE_BOOK_HNX) va atm_market_index_snapshot. Khong doi cot/kieu -> khong ALTER.
*/

/*
!!! CANH BAO - MODEL PHU THUOC ATOMIC CHUA TON TAI !!!
Cac cot outstanding_share_quantity, revenue, net_profit_after_tax, net_profit_after_tax_ttm,
owner_equity trong model nay phu thuoc 6 atomic model duoi day — DA GREP XAC NHAN LAI
(models/atomic) CHUA TON TAI trong repo tai thoi diem code (2026-08-26):
  1. atm_pc_report_submission     (nguon: pc_report_submission — ky bao cao, trang thai duyet, template)
  2. atm_fr_value                 (nguon: fr_value — gia tri tung dong/cot bao cao tai chinh)
  3. atm_fr_catalog                (nguon: fr_catalog — danh muc mau bieu BCTC, enterprise_tp_code)
  4. atm_fr_row_template           (nguon: fr_row_template — dinh nghia dong bao cao)
  5. atm_fr_column_template        (nguon: fr_column_template — dinh nghia cot bao cao)
  6. atm_pc_share_statistics       (nguon: pc_share_statistics_hstr — lich su so CP dang luu hanh theo ngay)
Model chi chay dung khi 6 atomic tren duoc build xong. atm_public_company va
atm_violation_report da co san trong repo nen duoc dung truc tiep (khong nam trong
danh sach thieu).
*/

WITH se_tr_sn_all AS (
    SELECT
        ticker_symbol AS symbol,
        ds_snpst_dt AS trading_dt,   -- [DOI THEO ATOMIC MOI 2026-10-09] atm_security_trading_snapshot bo trading_dt
        trading_time,
        close_price,
        reference_price,
        high_price,
        low_price,
        open_price,
        ceiling_price,
        floor_price,
        floor_code,
        stock_tp_code,
        underlying_symbol,
        isin_code,
        row_number() over (partition by ticker_symbol order by trading_time desc, sequence desc) as rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- [SUA 2026-09-11 theo logic test moi] atm_securities_trade (nguon so lenh/khop lenh) dung
-- KHAC khoa dinh danh giua 2 san: HNX/UPCOM/FDS (floor_code 02/04/03) dung issue_code = ISIN
-- (xem atm_securities_trade_ordertrade_trade_book_hnx.sql: security_symbol_code = issue_code),
-- con HOSE (floor_code 10) dung symbol thuong (atm_...hose.sql: security_symbol_code = symbol).
-- Truoc day toan bo cac JOIN ben duoi deu dung symbol - DUNG cho HOSE nhung SAI cho HNX/UPCOM/
-- FDS (so nham ticker voi ISIN -> LEFT JOIN ra NULL toan bo du lieu khop lenh cua cac san nay).
-- Tuong tu, JOIN toi Public Company (nganh/cong ty) cho chung quyen (stock_tp_code='4') phai
-- dung underlying_symbol (ma co so) thay vi ma CW cua chinh no.
se_tr_sn AS (
    SELECT
        symbol,
        trading_dt,
        close_price,
        reference_price,
        high_price,
        low_price,
        open_price,
        ceiling_price,
        floor_price,
        floor_code,
        stock_tp_code,
        CASE WHEN floor_code IN ('02','04','03') THEN isin_code ELSE symbol END AS trade_join_symbol,
        -- [SUA 2026-09-14] Bo nhanh trai phieu (stock_tp_code='1') khoi day - trai phieu
        -- gio join Nganh rieng qua 3 ky tu dau symbol (xem JOIN pu_co o SELECT cuoi), khong
        -- con nhet issuer_nm vao day de so voi equity_ticker_symbol (sai kieu du lieu).
        CASE
            WHEN stock_tp_code = '4' THEN underlying_symbol
            ELSE symbol
        END AS company_join_symbol
    FROM se_tr_sn_all
    WHERE rn = 1
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc a] Gia VWAP cua PHIEN GIAO DICH KE TIEP (T+1) - dung cho von hoa UPCOM.
-- Phien ke tiep = ngay nho nhat lon hon ngay giao dich co tren atm_market_index_snapshot; ban tin cuoi ngay cua phien do.
-- Chay daily tai ngay T chua co phien T+1 nen von hoa UPCOM la NULL, phai chay lai ngay T sau khi co du lieu phien ke tiep.
se_tr_nxt_dt AS (
    -- [SUA 2026-11-09, LLD O_GSTT_80] T+1 = ngay nho nhat > T va <= T + 1 thang trong HOP NHAT ngay giao dich so lenh HNX va market_index_snapshot
    SELECT MIN(nd.dt) AS nxt_dt
    FROM (
        SELECT hnx.trade_dt AS dt
        FROM {{ ref('atm_securities_trade') }} hnx
        WHERE hnx.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
            AND hnx.trade_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND hnx.trade_dt <= ADD_MONTHS(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 1)
        UNION
        SELECT m2.trading_dt AS dt
        FROM {{ ref('atm_market_index_snapshot') }} m2
        WHERE m2.trading_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND m2.trading_dt <= ADD_MONTHS(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 1)
    ) nd
),

se_tr_nxt AS (
    SELECT symbol, vol_weighted_average_price
    FROM (
        SELECT
            ticker_symbol AS symbol,
            vol_weighted_average_price,
            row_number() over (partition by ticker_symbol order by trading_time desc, sequence desc) AS rn
        FROM {{ ref('atm_security_trading_snapshot') }}
        WHERE ds_snpst_dt = (SELECT nxt_dt FROM se_tr_nxt_dt)
    ) x
    WHERE rn = 1
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc b] Khoi luong hop dong mo (OI) cuoi ngay cua ma phai sinh.
oi_val AS (
    SELECT ticker_symbol AS symbol, rpt_dt, open_interest_quantity
    FROM {{ ref('atm_end_of_day_open_interest') }}
    WHERE rpt_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- [SUA 2026-09-22, CHOT phuong an cuoi] Bo issuer_nm (MDDS) - tung dung join trai phieu voi
-- Nganh (2026-09-21) nhung phu thuoc du lieu nguon MDDS khong sach (BIDV/BVBV/HDA thay vi
-- BID/BVB/HDB). Doi sang lay 3 ky tu dau cua chinh symbol trai phieu (SUBSTR(symbol,1,3))
-- lam ma cong ty phat hanh - dung quy uoc dat ma trai phieu doanh nghiep VN (3 ky tu dau =
-- ticker cong ty me). Xem JOIN pu_co o SELECT cuoi.
-- [SUA 2026-09-28] ODS/atomic khong con dedup theo equity_ticker (xem ods_ids_company_
-- profiles.sql) - nguon co truong hop >1 pc_id cung gan 1 equity_ticker (vd BID: id=266 va
-- id=10174 cung active). Dedup ngay tai day: 1 dong/equity_ticker, uu tien id nguon nho
-- nhat, de tranh nhan doi dong khi LEFT JOIN pu_co ben duoi (JOIN theo equity_ticker_
-- symbol). CHU Y: order theo pc_code (CAST(co_pr.id AS string) - gia tri id nguon that,
-- xem atm_public_company.sql), KHONG order theo pc_id (surrogate key hash generate_
-- surrogate_key_bigint(...), khong con thu tu tuong ung voi id nguon).
pu_co_all AS (
    SELECT
        equity_ticker_symbol,
        pc_code,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint) ASC) as rn
    FROM {{ ref('atm_public_company') }}_hstr
    where equity_ticker_symbol is not null and pc_code is not null
    and ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    and ds_rcrd_st = 'ACTIVE'
),

pu_co AS (
    SELECT equity_ticker_symbol, pc_code
    FROM pu_co_all
    WHERE rn = 1
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

pu_co_di AS (
    SELECT
        public_company_dim_id,
        public_company_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- [MOI 2026-09-29, LLD a27bc1b - fallback Nganh CTCK] CTCK dai chung khong nam trong
-- IDS.COMPANY_PROFILES nen public_company_dim_id luon NULL cho cac ma nay -> K_GSTT_2
-- (Nganh) bi rong. Bo sung FK securities_company_dim_id (reuse QLKD, nguon SCMS.SC_FIRM_
-- INFO) lam fallback: chi nhan khi mã CK khop securities_code CUA 1 CTCK dai chung
-- (pc_indicator=1) va khong o trang thai tam/du thao (provisional_status_code='0' hoac
-- NULL). Tinh lai DUNG cong thuc surrogate key da dung o dtm_securities_company_dim.sql
-- (KHONG doc lai qua dim vi dim chua expose securities_code/pc_indicator/provisional -
-- tranh phai sua them 1 model QLKD rieng).
-- GIA DINH CAN XAC NHAN: gia tri that cua provisional_status_code (dang CAST tu cot
-- "provisional" nguon sang string, chua ro '0'/'1' hay dang khac) - LLD chi ghi "= 0 hoac
-- NULL", CAN Data Modeler xac nhan lai gia tri thuc te truoc khi tin tuong ket qua.
sec_co_ctck_all AS (
    SELECT
        sc.securities_code AS symbol,
        CAST({{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "CONCAT(sc.sc_id, '|', sc.sc_code)") }} AS string) AS securities_company_dim_id,
        sc.sc_id AS sc_id,
        row_number() over (partition by sc.securities_code order by sc.sc_code) as rn
    FROM {{ ref('atm_securities_company') }}_hstr sc
    WHERE sc.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND sc.ds_rcrd_st = 'ACTIVE'
        AND sc.src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND sc.pc_ind = 1
        AND (sc.provisional_ind = 0 OR sc.provisional_ind IS NULL)
        AND sc.securities_code IS NOT NULL
),

sec_co_ctck AS (
    SELECT symbol, securities_company_dim_id, sc_id
    FROM sec_co_ctck_all
    WHERE rn = 1
),

-- [MOI 2026-10-16, LLD v4.50 commit 1d908c6d] VCSH + LNST 4 quy TRUOT cua CTCK tu SCMS (IDS khong co BCTC cua CTCK) -
-- phuc vu P/E (K_GSTT_58), P/B (K_GSTT_59) cua co phieu CTCK va mau so P/E, P/B ro chi so (K_GSTT_149/150).
-- Chain: securities_company -> sc_periodic_report (QUY, da nop '1','2', end_dt <= ngay GD) -> report_input_submission
-- (ref_tp_code = 'BAO_CAO_DINH_KY') -> report_input_value (cell_id). Cung cach tiep can voi dtm_fct_market_risk_snpst (PTTT).
-- GIA DINH CAN DATA MODELER XAC NHAN: atm_sc_report_input_submission.sc_rpt_code la RAW form_report_id, KHONG co ma
-- 'BCTCHN'/'BCTCRL' nen khong loc duoc theo ma bao cao nhu LLD; thay bang: moi ky lay gia tri hop nhat (LNST TS121,
-- VCSH TS359) neu co, khong thi rieng le (LNST TS119, VCSH TS223 -> TS221). Moi (bao cao, ky) chi lay ban nop moi nhat.
scms_ctck_sub AS (
    SELECT
        spr.sc_id,
        spr.rpt_year,
        spr.period,
        spr.end_dt,
        rpt_sub.sc_rpt_input_submission_id,
        sc_rpt.rpt_code,
        rpt_sub.sc_rpt_code,
        -- [2026-10-23 theo BA] ky da co BCTCHN (bat ke co chi tieu hay khong) thi loai BCTCRL cua ky do
        MAX(CASE WHEN sc_rpt.rpt_code = 'BCTCHN' THEN 1 ELSE 0 END) over (
            partition by spr.sc_id, spr.rpt_year, spr.period
        ) AS has_hn,
        -- [2026-10-24 theo BA] Ban nop moi nhat theo (ky bao cao, LOAI bao cao BCTCHN/BCTCRL) - xep hang xuyen cac form_report_id cung ma bao cao
        -- (truoc day partition theo form_report_id nen ky nop lai bang form version khac se giu ca 2 ban roi lay MAX).
        row_number() over (
            partition by spr.sc_periodic_rpt_code, sc_rpt.rpt_code
            order by rpt_sub.sc_rpt_input_submission_id desc
        ) AS rn_sub
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN (
        -- [2026-10-24] bang submission append: nop lai = them 1 ban ghi CUNG id (data_dt = last_modified_at) -> chi lay ban ghi moi nhat (data_dt lon nhat) moi submission
        SELECT * FROM (
            SELECT s_v.*, ROW_NUMBER() OVER (PARTITION BY s_v.sc_rpt_input_submission_id ORDER BY s_v.data_dt DESC, s_v.ds_etl_pcs_tms DESC) AS rn_ver
            FROM {{ ref('atm_sc_report_input_submission') }} s_v
        ) s_r WHERE s_r.rn_ver = 1
    ) rpt_sub
        ON  rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.ref_tp_code = 'BAO_CAO_DINH_KY'
        -- [2026-10-24] bang atomic sc_report_input_submission tren UAT KHONG con scd2 (khong co ds_rcrd_st) -> bo loc ACTIVE
    INNER JOIN {{ ref('atm_sc_report') }} sc_rpt   -- [2026-10-23 theo BA] loc dung form BCTCHN/BCTCRL qua rpt_code
        ON  sc_rpt.sc_rpt_code = rpt_sub.sc_rpt_code
        AND sc_rpt.rpt_code IN ('BCTCHN','BCTCRL')
        AND sc_rpt.ds_rcrd_st = 'ACTIVE'   -- [2026-10-24] atm_sc_report la scd2: tranh nhan ban dong theo phien ban cu
    WHERE spr.ds_rcrd_st = 'ACTIVE'   -- [2026-10-19] scd2: chi lay phien ban hien hanh
        AND spr.rpt_period = 'QUY'
        AND spr.rpt_submission_status_code IN ('1','2')
        AND spr.sc_id IN (SELECT sc_id FROM sec_co_ctck)
),

-- [2026-10-23 theo cau Oracle nguon] sheet_id cua tung sheetCode (FORM_REPORT_DEEP_CONFIG.SHEETS_JSON): 06620 (TTTC hop nhat, TS359),
-- 06608 (TTTC rieng, TS223/TS221), 06622 (KQHD hop nhat, TS121), 06610 (KQHD rieng, TS119). Loc civ.SHEET_ID IN (...) nhu Oracle.
scms_ctck_sheet AS (
    -- [2026-10-24] Bang khoa nho (sc_rpt_code, sheet_id, cell_id) - chi dung cac o can lay (5 cell x sheetCode tuong ung).
    -- Join v theo 2 khoa bang thuan (sheet_id, cell_id), khong con CASE trong dieu kien join.
    SELECT DISTINCT
        dc.sc_rpt_code,
        dc.sheet_id,
        m.cell_id
    FROM {{ ref('atm_sc_report_deep_config') }} dc
    INNER JOIN (
        VALUES ('06620','TS359'), ('06622','TS121'), ('06610','TS119'), ('06608','TS223'), ('06608','TS221')
    ) AS m(sheet_code, cell_id)
        ON  m.sheet_code = dc.sheet_code
    WHERE dc.ds_rcrd_st = 'ACTIVE'
),

-- [2026-10-24] Loc bang gia tri lon ngay tu dau: chi giu cac o dung sheet + dung cell (vai chuc nghin dong), TRUOC khi join voi ban nop.
scms_ctck_cell AS (
    SELECT
        v.sc_rpt_input_submission_id,
        v.cell_id,
        v.cell_val,
        sh.sc_rpt_code
    FROM {{ ref('atm_sc_report_input_value') }} v
    INNER JOIN scms_ctck_sheet sh
        ON  sh.sheet_id = v.sheet_id
        AND sh.cell_id = v.cell_id
),

-- [2026-10-24 theo BA] Gop o muc (CTCK, nam, ky) bang SUM xuyen cac ban nop moi nhat cua ky (BA: SUM ... GROUP BY SC_FIRM_INFO_ID, REPORT_YEAR, PERIOD);
-- truoc day gop theo tung ban nop roi MAX. Nhom rieng le: COALESCE(NULLIF(SUM(TS223),0), SUM(TS221)) tinh tren tong ca ky nhu BA.
scms_ctck_val AS (
    SELECT
        s.sc_id,
        s.rpt_year,
        s.period,
        MAX(s.end_dt) AS end_dt,
        MAX(s.has_hn) AS has_hn,
        SUM(CASE WHEN s.rpt_code = 'BCTCHN' AND v.cell_id = 'TS121' THEN TRY_CAST(v.cell_val AS DECIMAL(23,2)) END) AS lnst_hn,
        SUM(CASE WHEN s.rpt_code = 'BCTCRL' AND v.cell_id = 'TS119' THEN TRY_CAST(v.cell_val AS DECIMAL(23,2)) END) AS lnst_rl,
        SUM(CASE WHEN s.rpt_code = 'BCTCHN' AND v.cell_id = 'TS359' THEN TRY_CAST(v.cell_val AS DECIMAL(23,2)) END) AS vcsh_hn,
        COALESCE(
            NULLIF(SUM(CASE WHEN s.rpt_code = 'BCTCRL' AND v.cell_id = 'TS223' THEN TRY_CAST(v.cell_val AS DECIMAL(23,2)) END), 0),
            SUM(CASE WHEN s.rpt_code = 'BCTCRL' AND v.cell_id = 'TS221' THEN TRY_CAST(v.cell_val AS DECIMAL(23,2)) END)
        ) AS vcsh_rl
    FROM scms_ctck_sub s
    INNER JOIN scms_ctck_cell v
        ON  v.sc_rpt_input_submission_id = s.sc_rpt_input_submission_id
        AND v.sc_rpt_code = s.sc_rpt_code
    WHERE s.rn_sub = 1
    GROUP BY s.sc_id, s.rpt_year, s.period
),

-- 1 dong / (CTCK, nam, ky): ky co BCTCHN -> chi lay hop nhat (NULL van la NULL, khong roi xuong rieng le); khong co BCTCHN -> rieng le [2026-10-23 theo BA]
scms_ctck_period AS (
    SELECT
        sc_id,
        rpt_year,
        period,
        MAX(end_dt) AS end_dt,
        CASE WHEN MAX(has_hn) = 1 THEN MAX(lnst_hn) ELSE MAX(lnst_rl) END AS lnst,
        CASE WHEN MAX(has_hn) = 1 THEN MAX(vcsh_hn) ELSE MAX(vcsh_rl) END AS vcsh
    FROM scms_ctck_val
    GROUP BY sc_id, rpt_year, period
),

scms_ctck_ranked AS (
    SELECT
        t.symbol,
        t.trading_dt,
        p.lnst,
        p.vcsh,
        row_number() over (partition by t.symbol, t.trading_dt order by p.rpt_year desc, p.period desc) AS rn
    FROM se_tr_sn t
    INNER JOIN sec_co_ctck c
        ON  c.symbol = t.symbol
    INNER JOIN scms_ctck_period p
        ON  p.sc_id = c.sc_id
        AND p.end_dt <= t.trading_dt   -- [2026-10-23 theo BA] bo dieu kien lnst/vcsh IS NOT NULL: ky hop le = co bao cao nop
),

scms_ctck_fin AS (
    SELECT
        symbol,
        trading_dt,
        MAX(CASE WHEN rn = 1 THEN COALESCE(vcsh, 0) END) AS securities_company_owner_equity,   -- [2026-10-19] ky gan nhat thieu VCSH -> 0, khong lui ky (giong IDS owner_equity_val)
        CASE WHEN COUNT(*) = 4 THEN SUM(COALESCE(lnst, 0)) END AS securities_company_net_profit_after_tax_ttm   -- [2026-10-19] du 4 KY NOP (khong phai 4 ky co LNST), ky thieu LNST = 0 (giong IDS npat_ttm_val)
    FROM scms_ctck_ranked
    WHERE rn <= 4
    GROUP BY symbol, trading_dt
),

-- [SUA 2026-09-25, LLD Data Modeler don gian hoa theo BA STT 28 dong 402, THAY THE ban
-- 2026-09-19 phan nhanh src_stm_code duoi day] Ca nhan trong nuoc = client_house_cl_code=
-- '10' AND foreign_investor_tp_code='00' AND investor_tp_code='8000'; To chuc trong nuoc =
-- giong het nhung investor_tp_code<>'8000' - dong nhat HOSE/HNX, khong con bang ma dai re
-- nhanh theo san, khong con loai tru cheo <>'30'/NOT IN('10','20'). Xem chi tiet tai CTE
-- se_tr_mt.
se_tr_mt AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol)                                                                                                                       AS total_vol,
        SUM(execution_val)                                                                                                                       AS total_val,
        SUM(CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END)                                                 AS foreign_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END)                                                 AS foreign_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_val ELSE 0 END)                                                 AS foreign_buy_val,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_val ELSE 0 END)                                                 AS foreign_sell_val,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E') THEN execution_vol ELSE 0 END)      AS proprietary_buy_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E') THEN execution_vol ELSE 0 END)      AS proprietary_sell_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('P','E') THEN execution_val ELSE 0 END)      AS proprietary_buy_val,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('P','E') THEN execution_val ELSE 0 END)      AS proprietary_sell_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- [MOI 2026-09-14, theo LLD] Tong KLGD/GTGD khop lenh THUAN (loai tru thoa thuan) -
-- khac total_vol/total_val (van giu nguyen, bao gom ca thoa thuan) - phuc vu nhom Top.
se_tr_mt_matched AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS total_matched_vol,
        SUM(execution_val) AS total_matched_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')
        AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- Giao dịch phái sinh
se_tr_dv AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS total_derivative_vol,
        SUM(execution_val) AS total_derivative_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code = 'DVX'
        AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- Giao dịch thỏa thuận
-- [SUA FILTER 2026-09-11, xac nhan qua issue Thuy - dong O_GSTT_20] Bo sung market_id_code
-- IN ('UPX','STX','STK') (thieu tu truoc, rui ro lan board code trung voi Bond Trading Vol/
-- Val khac market) va bo sung 'R1' (Negotiation Repo) vao board_tp_code cho khop dac ta BA.
se_tr_ng AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS total_negotiated_vol,
        SUM(execution_val) AS total_negotiated_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')
        AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- [MOI 2026-09-09, SUA FILTER 2026-09-11] Khoi luong mua rong NDTNN, giao dich thoa thuan
-- (khac foreign_net_vol - von tinh khop lenh). Bo sung market_id_code IN ('UPX','STX','STK')
-- (thieu tu ban goc, dong bo cung K_GSTT_17/18 khi dong O_GSTT_20).
-- [2026-10-13] GIU LAI cot nay (dev chot) du LLD/HLD da danh dau Deleted - cho xac nhan BI khong dung.
se_tr_ng_frn AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END)
            - SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END) AS foreign_net_negotiated_vol
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')
        AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- [MOI 2026-09-22, LLD bo sung KPI thieu qua doi chieu BA<->KPI] KL mua rong NDTNN tren
-- thi truong phai sinh (Market ID=DVX, khop lenh - phai sinh khong co board type thoa
-- thuan rieng). Cung pattern voi se_tr_ng_frn nhung khac market_id_code.
-- [SUA 2026-10-15, LLD v4.49] Them board_tp_code NOT IN (T1-T4,T6,R1) (DVX co bang thoa thuan) va 2 cot
-- foreign_buy_derivative_vol / foreign_sell_derivative_vol (K_GSTT_374/375, NDTNN xac dinh qua SUBSTR(account_nbr,4,1) IN F,E).
se_tr_dv_frn AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(CASE WHEN buy_foreign_investor_tp_code  IN ('10','20') THEN execution_vol ELSE 0 END)
            - SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END) AS foreign_net_derivative_vol,
        SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('F','E') THEN execution_vol ELSE 0 END)  AS foreign_buy_derivative_vol,
        SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('F','E') THEN execution_vol ELSE 0 END) AS foreign_sell_derivative_vol
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code = 'DVX'
        AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- Giao dịch trái phiếu (loại trừ lô lẻ)
se_tr_bd AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS bond_trading_vol,
        SUM(execution_val) AS bond_trading_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('BDO','HCX')
        AND board_tp_code NOT IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- [MOI 2026-09-30, LLD 2026-09-30] Thoa thuan phai sinh (DVX) va thoa thuan trai phieu
-- (BDO/HCX) - board_tp_code IN (T1,T2,T3,T4,T6,R1).
se_tr_dv_ng AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS total_derivative_negotiated_vol,
        SUM(execution_val) AS total_derivative_negotiated_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code = 'DVX'
        AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

se_tr_bd_ng AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(execution_vol) AS bond_negotiated_vol,
        SUM(execution_val) AS bond_negotiated_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('BDO','HCX')
        AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc a] Lo chan / lo le x khop lenh / thoa thuan x co phieu, phai sinh, trai phieu.
-- 1 lan quet atm_securities_trade; SUM(CASE WHEN ... THEN x END) khong ELSE 0 de nhom khong co giao dich ra NULL.
-- Board: lo chan khop G1,G2,G3,G6,G7,G8; lo chan thoa thuan T1,T2,T3,T6,R1; lo le khop G4; lo le thoa thuan T4.
se_tr_lot AS (
    SELECT
        security_symbol_code,
        trade_dt,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS round_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS round_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_vol END) AS odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('G4') THEN execution_val END) AS odd_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_vol END) AS odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('UPX','STX','STK','STO') AND board_tp_code IN ('T4') THEN execution_val END) AS odd_lot_negotiated_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS derivative_round_lot_matched_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS derivative_round_lot_matched_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS derivative_round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS derivative_round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G4') THEN execution_vol END) AS derivative_odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('G4') THEN execution_val END) AS derivative_odd_lot_matched_val,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T4') THEN execution_vol END) AS derivative_odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code = 'DVX' AND board_tp_code IN ('T4') THEN execution_val END) AS derivative_odd_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_vol END) AS bond_round_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G1','G2','G3','G6','G7','G8') THEN execution_val END) AS bond_round_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_vol END) AS bond_round_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T1','T2','T3','T6','R1') THEN execution_val END) AS bond_round_lot_negotiated_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G4') THEN execution_vol END) AS bond_odd_lot_matched_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('G4') THEN execution_val END) AS bond_odd_lot_matched_val,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T4') THEN execution_vol END) AS bond_odd_lot_negotiated_vol,
        SUM(CASE WHEN market_id_code IN ('BDO','HCX') AND board_tp_code IN ('T4') THEN execution_val END) AS bond_odd_lot_negotiated_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO','DVX','BDO','HCX')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),

-- Public Company (goc, dung cho join tai chinh — khac pu_co dung cho FK dim ben tren)
-- [SUA 2026-09-17] Dedupe 1 dong / equity_ticker_symbol - IDS co the co >1 ho so cung ma
-- CK (du lieu migrate/trung), neu khong dedupe se nhan dong o pc_financials.
pc_fin_all AS (
    SELECT
        pc_id,
        pc_code,
        equity_ticker_symbol,
        row_number() over (partition by equity_ticker_symbol order by CAST(pc_code AS bigint)) as rn
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
        AND equity_ticker_symbol IS NOT NULL
),

pc_fin AS (
    SELECT pc_id, equity_ticker_symbol
    FROM pc_fin_all
    WHERE rn = 1
),

-- Outstanding Share Quantity: [SUA 2026-09-16 theo LLD] doi nguon tu pc_share_statistics_hstr
-- (IDS, khong co du lieu hang ngay tren HNX/UPCOM -> ra rong) sang listed_share_information (VSDC
-- outstanding_shares, src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo dung nguon/pattern
-- voi free_float_share_quantity ben duoi (lookback theo symbol, ROW_NUMBER dedupe, khong
-- con join qua pc_id/pc_fin nua).
oss_val_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.outstanding_share_quantity,
        row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    FROM {{ ref('atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

oss_val AS (
    SELECT symbol, outstanding_share_quantity
    FROM oss_val_all
    WHERE rn = 1
),

/*
!!! CANH BAO - MODEL PHU THUOC ATOMIC CHUA TON TAI (2026-09-09) !!!
free_float_val duoi day doc atm_listed_share_information - DA GREP XAC NHAN
model nay CHUA TON TAI o bat ky tang nao (source/staging/ods/atomic) trong repo tai
thoi diem code (2026-09-09). Model dtm_fct_stock_portfolio_snpst se KHONG COMPILE
duoc (ref() loi "model not found") cho toi khi atm_listed_share_information
duoc build xong (nguon VSDC listed_security_info_snapshot, src_stm_code =
'VSDC_LISTED_SECURITY_INFO_SNAPSHOT', snapshot theo thang). Neu can model chay ngay,
comment tam CTE nay + doi free_float_share_quantity o SELECT cuoi thanh
CAST(NULL AS int).
*/
-- [MOI 2026-09-07] Free Float Share Quantity - lookback ban ghi gan nhat <= trading_dt,
-- cung pattern voi outstanding_share_quantity o tren.
-- [SUA 2026-09-14] Doi tu MAX(...) correlated subquery sang ROW_NUMBER dedupe - MAX
-- khong chong duoc truong hop atm_listed_share_information co nhieu dong trung
-- (ticker_symbol, ds_snpst_dt) do incremental_strategy=append o tang atomic/ods khi DAG
-- chay lai nhieu lan cung ky snapshot (dieu kien "= MAX(...)" cu khop het cac dong trung
-- nay, gay fan-out o SELECT cuoi). ROW_NUMBER luon ra dung 1 dong bat ke nguon co dup hay
-- khong - cung pattern voi oss_val_all o tren.
free_float_val_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.free_float_share_quantity,
        row_number() over (partition by lsis.ticker_symbol order by lsis.transaction_dt desc) as rn
    FROM {{ ref('atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

free_float_val AS (
    SELECT symbol, free_float_share_quantity
    FROM free_float_val_all
    WHERE rn = 1
),

-- [MOI 2026-11-09, LLD O_GSTT_80] So CP VSDC dung TINH VON HOA: khop DUNG ngay giao dich T (transaction_dt = T), khong lookback; ngay T khong co ban ghi -> NULL (von hoa NULL).
-- outstanding_share_quantity / free_float_share_quantity (cot rieng) van dung oss_val / free_float_val (lookback).
cap_shares AS (
    SELECT symbol, outstanding_share_quantity, free_float_share_quantity
    FROM (
        SELECT
            lsis.ticker_symbol AS symbol,
            lsis.outstanding_share_quantity,
            lsis.free_float_share_quantity,
            row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) AS rn
        FROM {{ ref('atm_listed_share_information') }} lsis
        WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
            AND lsis.transaction_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ) x
    WHERE rn = 1
),

-- ============================================================================
-- [SUA 2026-09-17] Viet lai toan bo khoi tai chinh cho khop 100% logic cau test
-- nghiep vu (BA), sau khi trace ra net_profit_after_tax/owner_equity NULL toan bo.
-- Nhung khac biet da sua (CAN RAISE DESIGN cap nhat LLD):
--   (1) Moi atomic scd4a doc qua _hstr + loc ds_snpst_dt/ds_rcrd_st (truoc day doc
--       thang bang current-state: khong point-in-time, va rong neu scd4a fail giua
--       chung do da DELETE truoc khi INSERT).
--   (2) BO dieu kien EXISTS violation_report - thuc do tren SHB: 402 submission hop le
--       chi con 13 sau dieu kien nay; cau test nghiep vu khong he co dieu kien nay.
--   (3) BO ep cung "ky lien truoc" (CEIL(month/3)-1) cho Revenue/NPAT: SHB khong nop
--       ky Q2/2026 -> ra NULL. Doi sang lay KY GAN NHAT co du lieu, giong cau test.
--   (4) Dedupe 1 ban ghi / (pc_id, rpt_year, rpt_quarter) TRUOC (uu tien HN>TH>ME>RI,
--       submission_dt moi nhat) roi moi xep hang ky - truoc day rank thang tren toan bo
--       dong nen TTM co the gom 4 dong CUNG 1 KY thay vi 4 ky khac nhau.
--   (5) Chi lay rpt_quarter IN (1,2,3,4) va ky ket thuc <= ngay giao dich - nguon IDS
--       con co ky 5/6 (ban nien/ca nam) lam lech xep hang ky.
-- ============================================================================
pc_rpt_sub_valid AS (
    SELECT
        prs.pc_id,
        prs.rpt_year,
        prs.rpt_quarter,
        prs.fr_code,
        prs.submission_dt,
        CASE prs.rpt_quarter
            WHEN 1 THEN to_date(concat(prs.rpt_year, '-03-31'))
            WHEN 2 THEN to_date(concat(prs.rpt_year, '-06-30'))
            WHEN 3 THEN to_date(concat(prs.rpt_year, '-09-30'))
            WHEN 4 THEN to_date(concat(prs.rpt_year, '-12-31'))
            WHEN 5 THEN to_date(concat(prs.rpt_year, '-12-31'))
        END AS period_end_dt
    FROM {{ ref('atm_pc_report_submission') }} prs
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        AND prs.ds_rcrd_st = 'ACTIVE'
        AND prs.approval_status_code = 'APPROVED'
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        AND prs.rpt_quarter IN (1,2,3,4,5)   -- [2026-11-02 LLD v4.58 muc b] them ky NAM (rpt_quarter = 5) de chon ky LNST TTM
),

-- 1 ban ghi / (cong ty, nam, quy) - uu tien HN>TH>ME>RI roi submission_dt moi nhat
-- (tuong duong CTE Company_data_chuan cua cau test), chi giu ky da ket thuc <= ngay giao dich
pc_rpt_sub_dedup_ranked AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.pc_id, s.rpt_year, s.rpt_quarter
            ORDER BY
                CASE SUBSTR(s.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                s.submission_dt DESC
        ) AS rn
    FROM pc_rpt_sub_valid s
    WHERE s.period_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

pc_rpt_sub_dedup AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code, period_end_dt
    FROM pc_rpt_sub_dedup_ranked
    WHERE rn = 1
),

-- Gia tri tung chi tieu THEO TUNG KY (tuong duong CTE Chitiet_DN cua cau test)
revenue_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS revenue
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

npat_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS net_profit_after_tax
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

owner_equity_by_period AS (
    SELECT
        s.pc_id,
        s.rpt_year,
        s.rpt_quarter,
        s.period_end_dt,
        SUM(fv.cell_val) AS owner_equity
    FROM pc_rpt_sub_dedup s
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = s.pc_id
        AND fv.rpt_year = s.rpt_year
        AND fv.rpt_quarter = s.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = fv.fr_catalog_id
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(s.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCDKT%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = fv.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '400')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '500')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = fv.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    GROUP BY s.pc_id, s.rpt_year, s.rpt_quarter, s.period_end_dt
),

-- [SUA 2026-09-23, FIX theo doi chieu HKT] Ky "hop le" = ky co IT NHAT 1 trong 3 chi
-- tieu (Doanh thu/LNST/VCSH) duoc join dung form (financial_statement_tp_code =
-- SUBSTR(fr_template_code,1,2)) - dung y het khai niem Chitiet_DN cua cau test (1 dong
-- chi ton tai khi >=1 chi tieu match). KHONG dung toan bo pc_rpt_sub_dedup (moi ky nop
-- bao cao bat ke form dung/sai) nhu ban truoc - vi ky FORM SAI HOAN TOAN (vd HKT 2025-Q4:
-- nop dang RI nhung TOAN BO du lieu nam duoi catalog ME, khong chi tieu nao khop) van bi
-- tinh vao lam anchor, cho VCSH=0 SAI trong khi test/BA muon LUI VE ky hop le gan nhat
-- (2025-Q3, co VCSH that). Phan biet 2 loai thieu du lieu:
--   - Ky hop le nhung THIEU 1 CHI TIEU rieng (vd AMV 2026-Q1: co VCSH, khong co LNST)
--     -> VAN la anchor, chi tieu thieu = 0 (KHONG lui ky) - giu nguyen theo BA da xac
--     nhan truoc do.
--   - Ky KHONG CO chi tieu nao hop le (form sai hoan toan, vd HKT 2025-Q4)
--     -> KHONG duoc tinh la 1 ky - lui ve ky hop le gan nhat truoc do.
pc_rpt_valid_periods AS (
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM revenue_by_period
    UNION
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM npat_by_period
    UNION
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt FROM owner_equity_by_period
),

pc_rpt_sub_recent4 AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY p.pc_id
            ORDER BY p.rpt_year DESC, p.rpt_quarter DESC
        ) AS rn
    FROM pc_rpt_valid_periods p
    WHERE p.rpt_quarter <> 5   -- [2026-11-02] chi cac ky QUY; ky NAM chi dung cho LNST TTM (pc_rpt_ttm_sel)
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc b] Chon ky LNST TTM: ky gan nhat da cong bo la NAM (rpt_quarter = 5) -> lay LNST ky nam;
-- la QUY -> cong don 4 quy gan nhat, phai du 4 quy (so quy >= 4). Chi ap dung cho net_profit_after_tax_ttm va WAOS TTM.
pc_rpt_ttm_rank AS (
    SELECT
        p.*,
        FIRST_VALUE(p.rpt_quarter) OVER (PARTITION BY p.pc_id ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS q_latest,
        ROW_NUMBER() OVER (PARTITION BY p.pc_id ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS rn_all,
        ROW_NUMBER() OVER (PARTITION BY p.pc_id, CASE WHEN p.rpt_quarter = 5 THEN 1 ELSE 0 END ORDER BY p.rpt_year DESC, p.rpt_quarter DESC) AS rn_q,
        COUNT(CASE WHEN p.rpt_quarter <> 5 THEN 1 END) OVER (PARTITION BY p.pc_id) AS so_quy
    FROM pc_rpt_valid_periods p
),

pc_rpt_ttm_sel AS (
    SELECT pc_id, rpt_year, rpt_quarter, period_end_dt, q_latest
    FROM pc_rpt_ttm_rank
    WHERE (q_latest = 5 AND rn_all = 1)
        OR (q_latest <> 5 AND rpt_quarter <> 5 AND rn_q <= 4 AND so_quy >= 4)
),

-- ============================================================================
-- [SUA 2026-10-06, LLD v4.32 - rule GSDC] Revenue / Net Profit After Tax (point-in-time)
-- Doi sang dung rule bao cao tai chinh cua GSDC (dtm_fct_public_company_financial_smy_snpst):
--   - Ky: BCTC DINH KY QUY (financial_report.news_tp_code='DINH_KY', src IDS_FORMS), fr_code
--     LIKE '%QUAR', form HN>TH>ME>RI, quy 1-4, APPROVED, submission_dt <= etl_date; chot 1
--     bao cao/ky (rn0) roi lay ky GAN NHAT da cong bo (rn1) - KHONG lui ky khi ky do thieu
--     chi tieu (gia tri NULL, khong fallback, khong COALESCE 0).
--   - fr_value: data_val IS NOT NULL, dedupe 1 o / (pc,nam,quy,catalog,row,column) theo
--     ds_rcrd_udt_dt/ds_rcrd_isrt_dt/fr_val_code DESC (nhu GSDC); fr_catalog.fr_year =
--     rpt_year, src IDS_REPORT_CATALOG/IDS_RROW/IDS_RCOL.
-- CHI ap cho Revenue va Net Profit After Tax (point-in-time). Net Profit After Tax TTM,
-- Owner Equity, Fr Period End Date, WAOS GIU NGUYEN (khong doi trong LLD lan nay).
-- ============================================================================
gsdc_fr_periodic AS (
    SELECT fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

gsdc_sub_ranked AS (
    SELECT
        prs.pc_id,
        prs.rpt_year,
        prs.rpt_quarter,
        prs.fr_code,
        ROW_NUMBER() OVER (
            PARTITION BY prs.pc_id, prs.rpt_year, prs.rpt_quarter
            ORDER BY
                CASE SUBSTR(prs.fr_code,1,2) WHEN 'HN' THEN 1 WHEN 'TH' THEN 2 WHEN 'ME' THEN 3 WHEN 'RI' THEN 4 END,
                prs.submission_dt DESC
        ) AS rn0
    FROM {{ ref('atm_pc_report_submission') }} prs
    WHERE prs.src_stm_code = 'IDS_COMPANY_DATA'
        AND prs.ds_rcrd_st = 'ACTIVE'
        AND prs.approval_status_code = 'APPROVED'
        AND prs.fr_code IN (SELECT fr_code FROM gsdc_fr_periodic)
        AND prs.fr_code LIKE '%QUAR'
        AND SUBSTR(prs.fr_code,1,2) IN ('HN','TH','ME','RI')
        AND prs.rpt_quarter IN (1,2,3,4)
        AND prs.submission_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

gsdc_sub_anchor AS (
    SELECT pc_id, rpt_year, rpt_quarter, fr_code
    FROM (
        SELECT
            r.*,
            ROW_NUMBER() OVER (PARTITION BY r.pc_id ORDER BY r.rpt_year DESC, r.rpt_quarter DESC) AS rn1
        FROM gsdc_sub_ranked r
        WHERE r.rn0 = 1
    ) t
    WHERE rn1 = 1
),

gsdc_fr_value AS (
    SELECT
        a.pc_id,
        a.rpt_year,
        a.rpt_quarter,
        a.fr_code,
        fv.fr_catalog_id,
        fv.row_code,
        fv.column_code,
        fv.cell_val AS data_val,
        ROW_NUMBER() OVER (
            PARTITION BY fv.pc_id, fv.rpt_year, fv.rpt_quarter, fv.fr_catalog_id, fv.row_code, fv.column_code
            ORDER BY fv.ds_rcrd_udt_dt DESC, fv.ds_rcrd_isrt_dt DESC, fv.fr_val_code DESC
        ) AS rn
    FROM gsdc_sub_anchor a
    INNER JOIN {{ ref('atm_fr_value') }} fv
        ON  fv.pc_id = a.pc_id
        AND fv.rpt_year = a.rpt_year
        AND fv.rpt_quarter = a.rpt_quarter
        AND fv.src_stm_code = 'IDS_DATA'
        AND fv.ds_rcrd_st = 'ACTIVE'
        AND fv.cell_val IS NOT NULL
),

revenue_val AS (
    SELECT
        v.pc_id,
        SUM(v.data_val) AS revenue
    FROM gsdc_fr_value v
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = v.fr_catalog_id
        AND fc.fr_year = CAST(v.rpt_year AS string)
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = v.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '10')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '03')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = v.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    WHERE v.rn = 1
    GROUP BY v.pc_id
),

npat_val AS (
    SELECT
        v.pc_id,
        SUM(v.data_val) AS net_profit_after_tax
    FROM gsdc_fr_value v
    INNER JOIN {{ ref('atm_fr_catalog') }} fc
        ON  fc.fr_catalog_id = v.fr_catalog_id
        AND fc.fr_year = CAST(v.rpt_year AS string)
        AND fc.src_stm_code = 'IDS_REPORT_CATALOG'
        AND fc.ds_rcrd_st = 'ACTIVE'
        AND fc.financial_statement_tp_code = SUBSTR(v.fr_code,1,2)
        AND fc.rpt_code LIKE 'BCKQKD%'
    INNER JOIN {{ ref('atm_fr_row') }} frt
        ON  frt.row_code = v.row_code
        AND frt.fr_catalog_id = fc.fr_catalog_id
        AND frt.src_stm_code = 'IDS_RROW'
        AND frt.ds_rcrd_st = 'ACTIVE'
        AND (
            (fc.enterprise_tp_code IN ('DN','BH') AND frt.row_description_reference = '60')
            OR (fc.enterprise_tp_code = 'TD' AND frt.row_description_reference = '21')
        )
    INNER JOIN {{ ref('atm_fr_column') }} fclt
        ON  fclt.column_code = v.column_code
        AND fclt.fr_catalog_id = fc.fr_catalog_id
        AND fclt.src_stm_code = 'IDS_RCOL'
        AND fclt.ds_rcrd_st = 'ACTIVE'
        AND fclt.column_description_reference = '1'
    WHERE v.rn = 1
    GROUP BY v.pc_id
),

owner_equity_val AS (
    SELECT
        r4.pc_id,
        COALESCE(oebp.owner_equity, 0) AS owner_equity
    FROM pc_rpt_sub_recent4 r4
    LEFT JOIN owner_equity_by_period oebp
        ON  oebp.pc_id = r4.pc_id
        AND oebp.rpt_year = r4.rpt_year
        AND oebp.rpt_quarter = r4.rpt_quarter
    WHERE r4.rn = 1
),

-- Financial Report Period End Date: ky ket thuc cua ky nop bao cao gan nhat (khong con
-- doc rieng tu npat_by_period - dung chung anchor voi npat_val/owner_equity_val).
fr_period_end_dt AS (
    SELECT pc_id, period_end_dt AS fr_period_end_dt
    FROM pc_rpt_sub_recent4
    WHERE rn = 1
),

-- Net Profit After Tax TTM: SUM toi da 4 KY NOP BAO CAO GAN NHAT (khong phai 4 ky co
-- LNST), ky nao thieu LNST tinh la 0 (COALESCE), khong con dieu kien COUNT(*)=4.
-- [SUA 2026-09-23, BA lam ro them] Neu cong ty KHONG CO DU 4 KY NOP BAO CAO (khong phai
-- thieu LNST, ma thieu ca ky nop) thi TTM phai la NULL - CASE COUNT(*)=4 dem so dong r4
-- (so ky nop thuc te, toi da 4 do da loc rn<=4), KHONG PHAI dem so dong LNST non-null
-- (LNST thieu trong 1 ky van tinh 0 va van tinh binh thuong neu du 4 ky nop).
-- [SUA 2026-11-02, LLD v4.58 muc b] Chon ky qua pc_rpt_ttm_sel: ky gan nhat la NAM -> 1 ky (LNST nam), la QUY -> 4 quy; du so ky moi tinh, thieu -> NULL.
npat_ttm_val AS (
    SELECT
        r4.pc_id,
        CASE WHEN COUNT(*) = CASE WHEN MAX(r4.q_latest) = 5 THEN 1 ELSE 4 END THEN SUM(COALESCE(nbp.net_profit_after_tax, 0)) END AS net_profit_after_tax_ttm
    FROM pc_rpt_ttm_sel r4
    LEFT JOIN npat_by_period nbp
        ON  nbp.pc_id = r4.pc_id
        AND nbp.rpt_year = r4.rpt_year
        AND nbp.rpt_quarter = r4.rpt_quarter
    GROUP BY r4.pc_id
),

-- ============================================================================
-- [MOI 2026-09-29, LLD "38edf44" - redesign Nhom 34] 5 measure vat ly moi:
-- weighted_average_outstanding_share_quantity(_ttm), owner_equity_weighted_
-- average_outstanding_share_quantity(_ttm), owner_equity_average_4_quarter.
-- Thay AVG(outstanding_share_quantity) theo quy LICH (sai, da deprecate - xem
-- check-loi-so-lieu case ACB da xac minh: KLLH binh quan phai tinh theo dung
-- khung ngay ky BCTC gan nhat, khong phai quy duong lich).
-- CHU Y - GIA DINH CAN XAC NHAN LAI VOI DATA MODELER: LLD mo ta cot "Owner
-- Equity Weighted..." dung 1 chuoi xep hang RIENG cho VCSH (khong gioi han
-- rpt_quarter, chap nhan ky ban nien/ca nam) - DOC LAP voi ky LNST. Code hien
-- tai (owner_equity_val/owner_equity_by_period) dang TAI SU DUNG CHUNG
-- pc_rpt_sub_recent4 voi LNST (gioi han rpt_quarter IN (1,2,3,4), KHONG doc
-- lap). De nhat quan voi phan owner_equity da co san (khong tao thay doi kien
-- truc lon chua duoc xac nhan), 4 cot WAOS o day TAM THOI dung chung 1 khung
-- ngay (waos_frame_quy/waos_frame_ttm, tu pc_rpt_sub_recent4) cho ca nhanh
-- LNST va nhanh VCSH - nghia la owner_equity_weighted_average_outstanding_
-- share_quantity(_ttm) se BANG CHINH XAC weighted_average_outstanding_share_
-- quantity(_ttm) trong code nay. Neu Data Modeler xac nhan can 1 chuoi xep
-- hang VCSH DOC LAP that (cho phep ky ban nien/ca nam), can tach rieng thanh
-- 1 CTE moi (khac owner_equity_by_period hien tai) truoc khi build lai.
-- ============================================================================
waos_frame_quy AS (
    SELECT
        pc_id,
        CASE rpt_quarter
            WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))
            WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))
            WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))
            WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))
        END AS khung_dau,
        period_end_dt AS khung_cuoi
    FROM pc_rpt_sub_recent4
    WHERE rn = 1
),

waos_frame_ttm AS (
    SELECT
        pc_id,
        MIN(CASE rpt_quarter
            WHEN 1 THEN to_date(concat(rpt_year, '-01-01'))
            WHEN 2 THEN to_date(concat(rpt_year, '-04-01'))
            WHEN 3 THEN to_date(concat(rpt_year, '-07-01'))
            WHEN 4 THEN to_date(concat(rpt_year, '-10-01'))
            WHEN 5 THEN to_date(concat(rpt_year, '-01-01'))
        END) AS khung_dau,
        MAX(period_end_dt) AS khung_cuoi
    FROM pc_rpt_ttm_sel   -- [SUA 2026-11-02, LLD v4.58 muc b] cung ky voi LNST TTM (nam: 1 ky, quy: 4 quy)
    GROUP BY pc_id
    HAVING COUNT(*) = CASE WHEN MAX(q_latest) = 5 THEN 1 ELSE 4 END
),

-- VCSH binh quan CONG (AVG, khong phai SUM) cua 4 ky - dao nguoc quyet dinh cu
-- (2026-09-04) da xac nhan sai qua SQL tham khao BA. Tai su dung owner_equity_by_period
-- + pc_rpt_sub_recent4 da co san.
owner_equity_avg4_val AS (
    SELECT
        r4.pc_id,
        CASE WHEN COUNT(*) = 4 THEN AVG(oebp.owner_equity) END AS owner_equity_average_4_quarter
    FROM pc_rpt_sub_recent4 r4
    INNER JOIN owner_equity_by_period oebp
        ON  oebp.pc_id = r4.pc_id
        AND oebp.rpt_year = r4.rpt_year
        AND oebp.rpt_quarter = r4.rpt_quarter
    WHERE r4.rn <= 4
    GROUP BY r4.pc_id
),

-- Nguon VSDC listed_share_information cho WAOS - cung pattern LEAD/DATEDIFF nhu cau test BA
-- (WAOS_base/KLLH_binh_quan_all), khac oss_val_all (chi lay 1 ban ghi moi nhat, dung cho
-- outstanding_share_quantity hien tai) - o day can TOAN BO lich su trong khung ngay.
waos_lsis_all AS (
    SELECT
        lsis.ticker_symbol AS symbol,
        lsis.ds_snpst_dt,
        lsis.outstanding_share_quantity,
        LEAD(lsis.ds_snpst_dt) OVER (PARTITION BY lsis.ticker_symbol ORDER BY lsis.ds_snpst_dt) AS next_ds_snpst_dt
    FROM {{ ref('atm_listed_share_information') }} lsis
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

waos_quy_val AS (
    SELECT
        pcf.equity_ticker_symbol AS symbol,
        SUM(w.outstanding_share_quantity * DATEDIFF(
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            GREATEST(w.ds_snpst_dt, f.khung_dau)
        )) / NULLIF(SUM(DATEDIFF(
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            GREATEST(w.ds_snpst_dt, f.khung_dau)
        )), 0) AS weighted_average_outstanding_share_quantity
    FROM waos_frame_quy f
    INNER JOIN pc_fin pcf
        ON  pcf.pc_id = f.pc_id
    INNER JOIN waos_lsis_all w
        ON  w.symbol = pcf.equity_ticker_symbol
        AND w.ds_snpst_dt <= f.khung_cuoi
        AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau
    GROUP BY pcf.equity_ticker_symbol
),

waos_ttm_val AS (
    SELECT
        pcf.equity_ticker_symbol AS symbol,
        SUM(w.outstanding_share_quantity * DATEDIFF(
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            GREATEST(w.ds_snpst_dt, f.khung_dau)
        )) / NULLIF(SUM(DATEDIFF(
            LEAST(COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)), DATE_ADD(f.khung_cuoi, 1)),
            GREATEST(w.ds_snpst_dt, f.khung_dau)
        )), 0) AS weighted_average_outstanding_share_quantity_ttm
    FROM waos_frame_ttm f
    INNER JOIN pc_fin pcf
        ON  pcf.pc_id = f.pc_id
    INNER JOIN waos_lsis_all w
        ON  w.symbol = pcf.equity_ticker_symbol
        AND w.ds_snpst_dt <= f.khung_cuoi
        AND COALESCE(w.next_ds_snpst_dt, DATE_ADD(f.khung_cuoi, 1)) > f.khung_dau
    GROUP BY pcf.equity_ticker_symbol
),

-- Tong hop cac chi tieu tai chinh theo symbol
-- [SUA 2026-09-17 - FIX NHAN DONG] Truoc day CTE nay lay FROM se_tr_sn va xuat
-- company_join_symbol AS symbol: company_join_symbol KHONG duy nhat (moi chung quyen
-- tren SHB deu co company_join_symbol='SHB') -> CTE co 14 dong symbol='SHB' -> JOIN o
-- SELECT cuoi nhan 14 lan. Tra ve grain 1 dong / 1 cong ty (FROM pc_fin, da dedupe theo
-- equity_ticker_symbol). outstanding_share_quantity tach ra join thang o SELECT cuoi theo
-- se_tr_sn.symbol (giong free_float_share_quantity) de ma khong co ho so IDS (vd VIX) van
-- lay duoc KLLH tu VSDC.
pc_financials AS (
    SELECT
        pcf.equity_ticker_symbol AS symbol,
        rev.revenue,
        npat.net_profit_after_tax,
        npat_ttm.net_profit_after_tax_ttm,
        oe.owner_equity,
        fped.fr_period_end_dt,
        wq.weighted_average_outstanding_share_quantity,
        wt.weighted_average_outstanding_share_quantity_ttm,
        -- [xem canh bao dau khoi WAOS] tam thoi dung chung frame voi nhanh LNST
        wq.weighted_average_outstanding_share_quantity AS owner_equity_weighted_average_outstanding_share_quantity,
        wt.weighted_average_outstanding_share_quantity_ttm AS owner_equity_weighted_average_outstanding_share_quantity_ttm,
        oe4.owner_equity_average_4_quarter
    FROM pc_fin pcf
    LEFT JOIN revenue_val rev
        ON  rev.pc_id = pcf.pc_id
    LEFT JOIN npat_val npat
        ON  npat.pc_id = pcf.pc_id
    LEFT JOIN npat_ttm_val npat_ttm
        ON  npat_ttm.pc_id = pcf.pc_id
    LEFT JOIN owner_equity_val oe
        ON  oe.pc_id = pcf.pc_id
    LEFT JOIN fr_period_end_dt fped
        ON  fped.pc_id = pcf.pc_id
    LEFT JOIN waos_quy_val wq
        ON  wq.symbol = pcf.equity_ticker_symbol
    LEFT JOIN waos_ttm_val wt
        ON  wt.symbol = pcf.equity_ticker_symbol
    LEFT JOIN owner_equity_avg4_val oe4
        ON  oe4.pc_id = pcf.pc_id
),

-- [MOI 2026-09-19, LLD review Nhom 24/O_GSTT_25] Prior Market Cap / Prior Free Float
-- Market Cap - von hoa cua ma TAI PHIEN GIAO DICH LIEN TRUOC (T-1 thuc su, khong phai
-- ngay lich T-1), dung cho K_GSTT_74/76 (trong so w_i/w_ff_i phai dung von hoa T-1, cung
-- ky voi Return_i/prior_index - truoc day dung nham von hoa NGAY T gay lech 1 phien).
-- Thay vi recompute tu atomic (them 1 lookback chain rieng, de lech logic voi cach fact
-- nay da tu tinh close_price/outstanding_share_quantity/free_float_share_quantity cua no),
-- SELF-REFERENCE lai chinh bang dich {{ this }} de doc dung gia tri DA LUU tren dong T-1 -
-- dung dung tinh than LLD "gia tri T-1 luu san tren dong T", cung pattern
-- fct_market_index_snpst.prior_index. Ngay dau tien build (chua co lich su) se ra NULL,
-- chap nhan duoc (giong LAG() tra NULL cho dong dau tien).
prior_val_all AS (
    SELECT
        se_tr_sn_di.symbol,
        t.market_cap            AS prior_market_cap,            -- [SUA 2026-11-02, LLD v4.58 muc a] = LAG(market_cap) theo quy tac gia tinh von hoa moi
        t.free_float_market_cap AS prior_free_float_market_cap, -- [SUA 2026-11-02, LLD v4.58 muc a] = LAG(free_float_market_cap)
        row_number() over (partition by se_tr_sn_di.symbol order by t.snpst_dt_dim_id desc) as rn
    FROM {{ this }} t
    INNER JOIN se_tr_sn_di
        ON  se_tr_sn_di.security_trading_snpst_dim_id = t.security_trading_snpst_dim_id
    WHERE t.snpst_dt_dim_id < date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

prior_val AS (
    SELECT symbol, prior_market_cap, prior_free_float_market_cap
    FROM prior_val_all
    WHERE rn = 1
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string) AS security_trading_snpst_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)            AS public_company_dim_id,
    CAST(sec_co_ctck.securities_company_dim_id AS string)     AS securities_company_dim_id,
    CAST(date_format(se_tr_sn.trading_dt, 'yyyyMMdd') AS string)                     AS snpst_dt_dim_id,
    CAST(se_tr_mt.total_vol AS bigint)                            AS total_vol,
    CAST(se_tr_mt.total_val AS decimal(23,2))                  AS total_val,
    CAST(se_tr_mt_matched.total_matched_vol AS bigint)            AS total_matched_vol,
    CAST(se_tr_mt_matched.total_matched_val AS decimal(23,2))  AS total_matched_val,
    CAST(se_tr_dv.total_derivative_vol AS bigint)                 AS total_derivative_vol,
    CAST(se_tr_dv.total_derivative_val AS decimal(23,2))       AS total_derivative_val,
    CAST(se_tr_dv_ng.total_derivative_negotiated_vol AS bigint)   AS total_derivative_negotiated_vol,
    CAST(se_tr_dv_ng.total_derivative_negotiated_val AS decimal(23,2)) AS total_derivative_negotiated_val,
    CAST(se_tr_ng.total_negotiated_vol AS bigint)                 AS total_negotiated_vol,
    CAST(se_tr_ng.total_negotiated_val AS decimal(23,2))       AS total_negotiated_val,
    CAST(se_tr_mt.foreign_buy_vol - se_tr_mt.foreign_sell_vol AS bigint)              AS foreign_net_vol,
    CAST(oss_val.outstanding_share_quantity AS bigint)            AS outstanding_share_quantity,
    CAST(pc_financials.revenue AS decimal(23,2))               AS revenue,
    CAST(pc_financials.net_profit_after_tax AS decimal(23,2))  AS net_profit_after_tax,
    CAST(pc_financials.net_profit_after_tax_ttm AS decimal(23,2)) AS net_profit_after_tax_ttm,
    CAST(pc_financials.owner_equity AS decimal(23,2))          AS owner_equity,
    CAST(pc_financials.weighted_average_outstanding_share_quantity AS decimal(23,4)) AS weighted_average_outstanding_share_quantity,
    CAST(pc_financials.weighted_average_outstanding_share_quantity_ttm AS decimal(23,4)) AS weighted_average_outstanding_share_quantity_ttm,
    CAST(pc_financials.owner_equity_weighted_average_outstanding_share_quantity AS decimal(23,4)) AS owner_equity_weighted_average_outstanding_share_quantity,
    CAST(pc_financials.owner_equity_weighted_average_outstanding_share_quantity_ttm AS decimal(23,4)) AS owner_equity_weighted_average_outstanding_share_quantity_ttm,
    CAST(pc_financials.owner_equity_average_4_quarter AS decimal(23,2)) AS owner_equity_average_4_quarter,
    CAST(se_tr_mt.foreign_buy_vol AS bigint)                      AS foreign_buy_vol,
    CAST(se_tr_mt.foreign_sell_vol AS bigint)                     AS foreign_sell_vol,
    CAST(se_tr_mt.foreign_buy_val AS decimal(23,2))            AS foreign_buy_val,
    CAST(se_tr_mt.foreign_sell_val AS decimal(23,2))           AS foreign_sell_val,
    CAST(se_tr_mt.proprietary_buy_val AS decimal(23,2))        AS proprietary_buy_val,
    CAST(se_tr_mt.proprietary_sell_val AS decimal(23,2))       AS proprietary_sell_val,
    CAST(se_tr_mt.proprietary_buy_vol AS bigint)                  AS proprietary_buy_vol,
    CAST(se_tr_mt.proprietary_sell_vol AS bigint)                 AS proprietary_sell_vol,
    CAST(se_tr_bd.bond_trading_vol AS bigint)                     AS bond_trading_vol,
    CAST(se_tr_bd.bond_trading_val AS decimal(23,2))           AS bond_trading_val,
    CAST(se_tr_bd_ng.bond_negotiated_vol AS bigint)               AS bond_negotiated_vol,
    CAST(se_tr_bd_ng.bond_negotiated_val AS decimal(23,2))     AS bond_negotiated_val,
    -- [SUA 2026-09-19] Thu tu 4 cot moi (high_price/low_price/prior_market_cap/
    -- prior_free_float_market_cap) PHAI khop CHINH XAC voi thu tu vat ly da ALTER TABLE
    -- tren Iceberg (AFTER close_price, AFTER reference_price) - macro incremental_rebase
    -- dung INSERT OVERWRITE ... SELECT (khong khai bao danh sach cot), Spark match cot
    -- THEO VI TRI (positional), khong theo ten. Neu de o cuoi SELECT nhu ban dau se lech
    -- vi tri voi bang vat ly -> loi CANNOT_SAFELY_CAST (da gap thuc te ngay 2026-09-19).
    CAST(se_tr_sn.close_price AS decimal(23,2))                 AS close_price,
    CAST(se_tr_sn.high_price AS decimal(23,2))                  AS high_price,
    CAST(se_tr_sn.low_price AS decimal(23,2))                   AS low_price,
    CAST(se_tr_sn.reference_price AS decimal(23,2))             AS reference_price,
    CAST(prior_val.prior_market_cap AS decimal(23,2))           AS prior_market_cap,
    CAST(prior_val.prior_free_float_market_cap AS decimal(23,2)) AS prior_free_float_market_cap,
    CAST(free_float_val.free_float_share_quantity AS bigint)      AS free_float_share_quantity,
    CAST(se_tr_ng_frn.foreign_net_negotiated_vol AS bigint)        AS foreign_net_negotiated_vol,
    CAST(se_tr_dv_frn.foreign_net_derivative_vol AS bigint)        AS foreign_net_derivative_vol,
    CAST(se_tr_dv_frn.foreign_buy_derivative_vol AS bigint)        AS foreign_buy_derivative_vol,
    CAST(se_tr_dv_frn.foreign_sell_derivative_vol AS bigint)       AS foreign_sell_derivative_vol,
    CAST(date_format(pc_financials.fr_period_end_dt, 'yyyyMMdd') AS string) AS fr_period_end_dt_dim_id,
    CAST(scms_ctck_fin.securities_company_net_profit_after_tax_ttm AS decimal(23,2)) AS securities_company_net_profit_after_tax_ttm,
    CAST(scms_ctck_fin.securities_company_owner_equity AS decimal(23,2)) AS securities_company_owner_equity,
    -- [MOI 2026-11-02, LLD v4.58] 30 cot moi o CUOI, dung thu tu LLD (insert theo vi tri, ALTER ADD COLUMN AFTER securities_company_owner_equity)
    CAST(se_tr_lot.round_lot_matched_vol AS bigint)                        AS round_lot_matched_vol,
    CAST(se_tr_lot.round_lot_matched_val AS decimal(23,2))                 AS round_lot_matched_val,
    CAST(se_tr_lot.round_lot_negotiated_vol AS bigint)                        AS round_lot_negotiated_vol,
    CAST(se_tr_lot.round_lot_negotiated_val AS decimal(23,2))                 AS round_lot_negotiated_val,
    CAST(se_tr_lot.odd_lot_matched_vol AS bigint)                        AS odd_lot_matched_vol,
    CAST(se_tr_lot.odd_lot_matched_val AS decimal(23,2))                 AS odd_lot_matched_val,
    CAST(se_tr_lot.odd_lot_negotiated_vol AS bigint)                        AS odd_lot_negotiated_vol,
    CAST(se_tr_lot.odd_lot_negotiated_val AS decimal(23,2))                 AS odd_lot_negotiated_val,
    CAST(se_tr_lot.derivative_round_lot_matched_vol AS bigint)                        AS derivative_round_lot_matched_vol,
    CAST(se_tr_lot.derivative_round_lot_matched_val AS decimal(23,2))                 AS derivative_round_lot_matched_val,
    CAST(se_tr_lot.derivative_round_lot_negotiated_vol AS bigint)                        AS derivative_round_lot_negotiated_vol,
    CAST(se_tr_lot.derivative_round_lot_negotiated_val AS decimal(23,2))                 AS derivative_round_lot_negotiated_val,
    CAST(se_tr_lot.derivative_odd_lot_matched_vol AS bigint)                        AS derivative_odd_lot_matched_vol,
    CAST(se_tr_lot.derivative_odd_lot_matched_val AS decimal(23,2))                 AS derivative_odd_lot_matched_val,
    CAST(se_tr_lot.derivative_odd_lot_negotiated_vol AS bigint)                        AS derivative_odd_lot_negotiated_vol,
    CAST(se_tr_lot.derivative_odd_lot_negotiated_val AS decimal(23,2))                 AS derivative_odd_lot_negotiated_val,
    CAST(oi_val.open_interest_quantity AS bigint)                 AS open_interest_quantity,
    CAST(se_tr_lot.bond_round_lot_matched_vol AS bigint)                        AS bond_round_lot_matched_vol,
    CAST(se_tr_lot.bond_round_lot_matched_val AS decimal(23,2))                 AS bond_round_lot_matched_val,
    CAST(se_tr_lot.bond_round_lot_negotiated_vol AS bigint)                        AS bond_round_lot_negotiated_vol,
    CAST(se_tr_lot.bond_round_lot_negotiated_val AS decimal(23,2))                 AS bond_round_lot_negotiated_val,
    CAST(se_tr_lot.bond_odd_lot_matched_vol AS bigint)                        AS bond_odd_lot_matched_vol,
    CAST(se_tr_lot.bond_odd_lot_matched_val AS decimal(23,2))                 AS bond_odd_lot_matched_val,
    CAST(se_tr_lot.bond_odd_lot_negotiated_vol AS bigint)                        AS bond_odd_lot_negotiated_vol,
    CAST(se_tr_lot.bond_odd_lot_negotiated_val AS decimal(23,2))                 AS bond_odd_lot_negotiated_val,
    CAST(se_tr_sn.ceiling_price AS decimal(23,2))                 AS ceiling_price,
    CAST(se_tr_sn.floor_price AS decimal(23,2))                   AS floor_price,
    CAST(se_tr_sn.open_price AS decimal(23,2))                    AS open_price,
    CAST((CASE WHEN se_tr_sn.floor_code = '04' THEN CASE WHEN se_tr_nxt.vol_weighted_average_price IS NULL THEN NULL ELSE COALESCE(NULLIF(se_tr_nxt.vol_weighted_average_price, 0), se_tr_sn.reference_price) END ELSE se_tr_sn.close_price END) * cap_shares.free_float_share_quantity AS decimal(23,2)) AS free_float_market_cap,
    CAST((CASE WHEN se_tr_sn.floor_code = '04' THEN CASE WHEN se_tr_nxt.vol_weighted_average_price IS NULL THEN NULL ELSE COALESCE(NULLIF(se_tr_nxt.vol_weighted_average_price, 0), se_tr_sn.reference_price) END ELSE se_tr_sn.close_price END) * cap_shares.outstanding_share_quantity AS decimal(23,2)) AS market_cap
FROM se_tr_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = se_tr_sn.symbol
-- [SUA 2026-09-22, CHOT phuong an cuoi] Trai phieu (stock_tp_code='1') join Nganh qua 3 ky tu
-- dau cua chinh symbol trai phieu (SUBSTR(symbol,1,3) = ma ticker cong ty phat hanh, theo
-- quy uoc dat ma trai phieu doanh nghiep VN) - thay the issuer_nm (MDDS, dung tam 2026-09-21,
-- bi thu hoi vi phu thuoc du lieu nguon khong sach). Cac loai CK khac (co phieu/CCQ/CW) van
-- join qua equity_ticker_symbol nhu cu (company_join_symbol da xu ly san CASE
-- underlying_symbol cho CW).
LEFT JOIN pu_co
    ON  (se_tr_sn.stock_tp_code = '1'
         AND pu_co.equity_ticker_symbol = SUBSTR(se_tr_sn.symbol,1,3)
         -- [SUA 2026-09-29, LLD a27bc1b, O_GSTT_37] Loai tru truoc khi ap SUBSTR(symbol,1,3)
         -- cho trai phieu Chinh phu/Kho bac/chinh quyen dia phuong - tranh gan nham Nganh khi
         -- ma trai phieu trung ngau nhien voi ticker co phieu that (vd HCM trung CTCK HSC;
         -- [xx]GB trung HPG/HNG/KHG/TNG/THG/HTG). Danh sach tien to CHUA duoc Data Modeler
         -- xac nhan day du 100% - xem O_GSTT_37, can ra soat lai khi co du lieu thuc te day
         -- du hon.
         AND NOT (
             se_tr_sn.symbol RLIKE '^[A-Za-z]{2}GB'
             OR se_tr_sn.symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
             OR se_tr_sn.symbol RLIKE '^(HCM|HAN)'
         ))
    OR  (se_tr_sn.stock_tp_code <> '1' AND pu_co.equity_ticker_symbol = se_tr_sn.company_join_symbol)
LEFT JOIN pu_co_di
    ON  pu_co_di.public_company_code = pu_co.pc_code
LEFT JOIN sec_co_ctck
    ON  sec_co_ctck.symbol = se_tr_sn.symbol
LEFT JOIN scms_ctck_fin
    ON  scms_ctck_fin.symbol = se_tr_sn.symbol
    AND scms_ctck_fin.trading_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_mt
    ON  se_tr_mt.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_mt.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_mt_matched
    ON  se_tr_mt_matched.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_mt_matched.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_dv
    ON  se_tr_dv.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_dv.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_dv_ng
    ON  se_tr_dv_ng.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_dv_ng.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_ng
    ON  se_tr_ng.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_ng.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_bd
    ON  se_tr_bd.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_bd.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_bd_ng
    ON  se_tr_bd_ng.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_bd_ng.trade_dt = se_tr_sn.trading_dt
LEFT JOIN pc_financials
    ON  pc_financials.symbol = se_tr_sn.symbol
LEFT JOIN se_tr_ng_frn
    ON  se_tr_ng_frn.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_ng_frn.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_dv_frn
    ON  se_tr_dv_frn.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_dv_frn.trade_dt = se_tr_sn.trading_dt
LEFT JOIN free_float_val
    ON  free_float_val.symbol = se_tr_sn.symbol
-- [SUA 2026-09-17] outstanding_share_quantity join thang tai day theo symbol MDDS thuan
-- (giong free_float_share_quantity, dung LLD: KHONG ap CASE underlying_symbol cua CW),
-- khong con di qua pc_financials/pc_id nua.
LEFT JOIN oss_val
    ON  oss_val.symbol = se_tr_sn.symbol
LEFT JOIN prior_val
    ON  prior_val.symbol = se_tr_sn.symbol
LEFT JOIN se_tr_lot
    ON  se_tr_lot.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_lot.trade_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_nxt
    ON  se_tr_nxt.symbol = se_tr_sn.symbol
LEFT JOIN cap_shares   -- [MOI 2026-11-09, O_GSTT_80]
    ON  cap_shares.symbol = se_tr_sn.symbol
LEFT JOIN oi_val
    ON  oi_val.symbol = se_tr_sn.symbol
    AND oi_val.rpt_dt = se_tr_sn.trading_dt
    AND se_tr_sn.stock_tp_code = '4'
    AND se_tr_sn.floor_code IN ('02','03','04')
WHERE se_tr_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
