-- [FIRST-TIME] ft_dtm_fct_stock_portfolio_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_stock_portfolio_snpst (config ft_target='fct_stock_portfolio_snpst', macro macros/first_time).
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
*                                       implement bang SELF-REFERENCE {{ ft_this() }} (doc lai
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
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-16		tuan.nguyenvanb		[LLD v4.50, commit 1d908c6d] Them 2 cot securities_company_owner_equity (VCSH ky QUY gan nhat) va
*                                       securities_company_net_profit_after_tax_ttm (LNST 4 quy truot) cua CTCK tu SCMS
*                                       (TS359/TS223/TS221, TS121/TS119) - ghi o CUOI SELECT (sau fr_period_end_dt_dim_id) -> ALTER ... AFTER
*                                       fr_period_end_dt_dim_id. Gia dinh BCTCHN/BCTCRL qua cell_id nhu PTTT market_risk, can DM xac nhan.
* 2026-10-17		tuan.nguyenvanb		[DONG BO atm_securities_company moi] pc_indicator -> pc_ind; provisional_status_code (string '0') -> provisional_ind (int 0).
* 2026-10-19		tuan.nguyenvanb		[BA XAC NHAN] LNST TTM / VCSH cua CTCK (SCMS) dung CUNG rule voi IDS: ky hop le = co it nhat 1 chi tieu; TTM = SUM 4 ky nop gan nhat
*                                       (ky thieu LNST tinh 0, khong du 4 ky nop -> NULL); VCSH = ky gan nhat, thieu -> 0 (khong lui ky). Khong doi cot -> khong can ALTER.
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
* 2026-10-19		tuan.nguyenvanb		[UAT doi atm_sc_periodic_report / atm_sc_report_input_submission scd4a -> scd2] them spr.ds_rcrd_st/rpt_sub.ds_rcrd_st = 'ACTIVE' (scd2 giu ca ban ghi INACTIVE).
* 2026-10-23		tuan.nguyenvanb		[THEO BA] VCSH/LNST CTCK (SCMS): (1) bo dieu kien lnst/vcsh IS NOT NULL o scms_ctck_ranked (ky hop le = co bao cao nop);
*                                       (2) loc form qua atm_sc_report.rpt_code IN (BCTCHN,BCTCRL), TS121/TS359 chi lay tu BCTCHN, TS119/TS223/TS221 chi tu BCTCRL;
*                                       (3) ky da co BCTCHN thi chi lay hop nhat, khong roi xuong BCTCRL (has_hn). Khong doi cot -> khong can ALTER.
*                                       (4) loc SHEET_ID theo sheetCode nhu cau Oracle nguon (06620/TS359, 06622/TS121, 06608/TS223+TS221, 06610/TS119) qua
*                                       atomic moi atm_sc_report_deep_config (CTE scms_ctck_sheet) - CAN build atomic nay truoc khi chay.
* 2026-10-24		tuan.nguyenvanb		[TOI UU] Khoi SCMS: loc atm_sc_report_input_value xuong dung (sheet,cell) bang bang khoa nho scms_ctck_sheet (VALUES) o CTE scms_ctck_cell
*                                       truoc khi join ban nop (bo CASE trong dieu kien join); them ds_rcrd_st='ACTIVE' cho atm_sc_report. Khong doi ket qua/cot.
* 2026-10-24		tuan.nguyenvanb		[THEO BA] Khoi SCMS: gop ky o muc (CTCK, nam, ky) bang SUM xuyen cac ban nop moi nhat (truoc: MAX theo tung ban nop) - giong SUM ... GROUP BY cua BA; bo qua rn_sub theo form_report_id, xep hang theo (ky, loai bao cao). Khong doi cot.
* 2026-10-24		tuan.nguyenvanb		[TOI UU, chi ban first_time] (A) gop 9 CTE se_tr_* thanh 1 lan quet se_tr_agg; (B) se_tr_sn_all dung max_by thay row_number. Ket qua tuong duong, khong doi cot.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: snapshot.symbol->ticker_symbol, security_full_nm->full_nm, fr_value.data_val->cell_val. Khong doi cot/kieu.
*--------------------------------------------------------------------*
* 2026-10-22			tuan.nguyenvanb		Doi tham chieu atomic: listed_share_information.transaction_date->transaction_dt. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[SUA, dong bo daily, LLD v4.56-v4.57, O_GSTT_75] 4 cot proprietary_*: SUBSTR(account_nbr,4,1)='P' thay client_house_cl_code='30'. Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		[DOI THEO CAU TEST BA, thay quy tac loai tru 2026-10-22 truoc do] Phan loai NDT DOC LAP nhu BA: Tu doanh = ky tu thu 4 IN ('P','E'); Nuoc ngoai = IN ('F','E'); Ca nhan = loai NDT '3', To chuc = '5' (khong xet ky tu thu 4) - mot lenh co the tinh vao nhieu nhom (TK loai E vua Tu doanh vua Nuoc ngoai). Pham vi sua: proprietary_*. Khong doi cot. CAN DONG BO LLD O_GSTT_75 (LLD dang ghi loai tru nhau).
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78] Dong bo daily: THEM 30 cot cuoi bang (24 cot lo chan/lo le gop vao se_tr_agg, open_interest_quantity, ceiling_price, floor_price,
*                                       open_price, free_float_market_cap, market_cap); gia tinh von hoa san UPCOM = VWAP phien ke tiep (CTE se_tr_cap), HOSE/HNX = gia dong cua;
*                                       prior_market_cap/prior_free_float_market_cap = LAG von hoa moi; net_profit_after_tax_ttm va WAOS TTM chon ky nam (rpt_quarter 5) hoac 4 quy
*                                       (pc_rpt_ttm_sel theo tung ngay). Can atomic moi vol_weighted_average_price. Bang vat ly can ALTER ADD COLUMN theo vi tri.
* 2026-11-09		tuan.nguyenvanb		[TOI UU, chi ban first_time, khong doi logic/cot] (1) them hint BROADCAST(td) cho 4 khoi JOIN trade_dates (pc_rpt_sub_recent4, pc_rpt_ttm_rank,
*                                       gsdc_sub_ranked, pc_financials): voi autoBroadcastJoinThreshold=-1 cac JOIN bat dang thuc nay roi vao CartesianProduct; (2) JOIN pu_co dang OR
*                                       (nested loop) doi sang 1 khoa equi bang CASE, ket qua giu nguyen; (3) hint BROADCAST cho pu_co, pu_co_di, sec_co_ctck o SELECT cuoi.
*                                       (4) pc_rpt_ttm_rank: rn_q/so_quy cung partition+order voi rn_all (3 lan sort -> 1); (5) trade_dates lay tu ds_snpst_dt cua snapshot thay vi tu se_tr_sn.
* 2026-11-09		tuan.nguyenvanb		[TACH BANG TAM, chi ban first_time, khong doi logic/cot] Job khoi tao bi chet Spark vi ke hoach 1 cau qua lon. Tach 3 khoi CTE nguyen van ra 3 bang tam chay truoc:
*                                       ft_tmp_sp_se_tr_sn (se_tr_sn_all + se_tr_sn), ft_tmp_sp_pc_financials (pc_financials va 31 CTE phu thuoc), ft_tmp_sp_se_tr_agg (se_tr_agg).
*                                       Model nay doc lai bang ref() cung ten CTE (se_tr_sn, pc_financials, se_tr_agg); cac CTE con lai va SELECT cuoi GIU NGUYEN. CAN chay 3 model tam truoc.
* 2026-11-09		tuan.nguyenvanb		[LLD O_GSTT_80] Dong bo daily: von hoa (market_cap, free_float_market_cap, prior_*) theo SQL moi cua BA: (1) so CP VSDC khop DUNG ngay T (CTE cap_shares, transaction_dt = ngay giao dich; thieu -> NULL;
*                                       cot outstanding/free_float rieng van lookback); (2) T+1 (gia UPCOM) = ngay nho nhat > T va <= T+1 thang trong hop nhat ngay so lenh HNX va market_index_snapshot (CTE mkt_all_dt, mkt_nxt). Khong doi cot/kieu.
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

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT:   -- [BACKFILL-UAT-NEW]
-- moi chi tieu tra cuu THEO TUNG trading_dt (as-of), bo WHERE trading_dt = etl_date. Dong goc giu o dang comment   -- [BACKFILL-UAT-NEW]
-- BACKFILL-UAT-ORIG. Revert: chuyen che do daily bang dbt/first_time_mode.py.   -- [BACKFILL-UAT-NEW]
WITH se_tr_sn AS (
    SELECT * FROM {{ ref('ft_tmp_sp_se_tr_sn') }}   -- [TACH BANG TAM 2026-11-09] xem model ft_tmp_sp_se_tr_sn
),

-- 2026-10-08 tuan.nguyenvanb [BACKFILL-UAT-ONEPASS] Truc ngay giao dich cua lan chay mot luot.   -- [BACKFILL-UAT-NEW]
trade_dates AS (   -- [BACKFILL-UAT-NEW]
    -- [TOI UU 2026-11-09, chi ban first_time] Lay truc ngay thang tu cot ds_snpst_dt cua snapshot (cung tap ngay voi se_tr_sn vi se_tr_sn_all chi gom nhom theo ticker, ngay),
    -- khong tinh lai phep gom nhom ca nam chi de lay danh sach ngay (CTE nay duoc tham chieu o nhieu khoi).
    SELECT DISTINCT CAST(ds_snpst_dt AS date) AS trading_dt   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW]
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc a] Gia tinh von hoa theo tung (ma, ngay): san 04 UPCOM = VWAP ban tin cuoi ngay cua PHIEN KE TIEP
-- (ngay nho nhat lon hon T co tren atm_market_index_snapshot), NULL neu chua co VWAP, VWAP = 0 thi lay gia tham chieu T; HOSE/HNX = gia dong cua.
-- [SUA 2026-11-09, LLD O_GSTT_80] T+1 = ngay nho nhat > T va <= T + 1 thang trong HOP NHAT ngay giao dich so lenh HNX (atm_securities_trade) va market_index_snapshot.
mkt_all_dt AS (
    SELECT trade_dt AS dt
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
    UNION
    SELECT trading_dt AS dt
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
),

mkt_nxt AS (
    SELECT /*+ BROADCAST(u) */
        t.trading_dt,
        MIN(u.dt) AS nxt_dt
    FROM trade_dates t
    LEFT JOIN mkt_all_dt u
        ON  u.dt > t.trading_dt
        AND u.dt <= ADD_MONTHS(t.trading_dt, 1)
    GROUP BY t.trading_dt
),

se_tr_cap AS (
    SELECT
        s.symbol,
        s.trading_dt,
        (CASE WHEN s.floor_code = '04'
              THEN CASE WHEN nx.vol_weighted_average_price IS NULL THEN NULL
                        ELSE COALESCE(NULLIF(nx.vol_weighted_average_price, 0), s.reference_price) END
              ELSE s.close_price END) AS cap_price
    FROM se_tr_sn s
    LEFT JOIN mkt_nxt m
        ON  m.trading_dt = s.trading_dt
    LEFT JOIN se_tr_sn nx
        ON  nx.symbol = s.symbol
        AND nx.trading_dt = m.nxt_dt
),

-- [MOI 2026-11-02, LLD v4.58, O_GSTT_78 muc b] Khoi luong hop dong mo (OI) cuoi ngay cua ma phai sinh.
oi_val AS (
    SELECT ticker_symbol AS symbol, rpt_dt, open_interest_quantity
    FROM {{ ft_ref('ft_atm_end_of_day_open_interest') }}
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
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_public_company') }}_hstr
    FROM {{ ref('atm_public_company') }}   -- [BACKFILL-UAT-NEW]
    where equity_ticker_symbol is not null and pc_code is not null
    -- [BACKFILL-UAT-ORIG] and ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
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
        symbol,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
),

pu_co_di AS (
    SELECT
        public_company_dim_id,
        public_company_code
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('dtm_public_company_dim') }}_hstr
    FROM {{ ref('dtm_public_company_dim') }}   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND ds_rcrd_st = 'ACTIVE'
    WHERE ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
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
    -- [BACKFILL-UAT-ORIG] FROM {{ ref('atm_securities_company') }}_hstr sc
    FROM {{ ref('atm_securities_company') }} sc   -- [BACKFILL-UAT-NEW]
    -- [BACKFILL-UAT-ORIG] WHERE sc.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND sc.ds_rcrd_st = 'ACTIVE'
    WHERE sc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
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

se_tr_agg AS (
    SELECT * FROM {{ ref('ft_tmp_sp_se_tr_agg') }}   -- [TACH BANG TAM 2026-11-09] xem model ft_tmp_sp_se_tr_agg
),

{#- [BAN GOC TRUOC KHI GOP 2026-10-24 - giu de doi chieu]
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
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
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE market_id_code IN ('BDO','HCX')
        AND board_tp_code IN ('T1','T2','T3','T4','T6','R1')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
    GROUP BY security_symbol_code, trade_dt
),
-#}
-- Outstanding Share Quantity: [SUA 2026-09-16 theo LLD] doi nguon tu pc_share_statistics_hstr
-- (IDS, khong co du lieu hang ngay tren HNX/UPCOM -> ra rong) sang listed_share_information (VSDC
-- outstanding_shares, src_stm_code='VSDC_OUTSTANDING_SHARES') - dong bo dung nguon/pattern
-- voi free_float_share_quantity ben duoi (lookback theo symbol, ROW_NUMBER dedupe, khong
-- con join qua pc_id/pc_fin nua).
-- [BACKFILL-UAT-ORIG] oss_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] lsis.ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] lsis.outstanding_share_quantity,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by lsis.ticker_symbol order by lsis.ds_snpst_dt desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
    -- [BACKFILL-UAT-ORIG] WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        -- [BACKFILL-UAT-ORIG] AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] oss_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT symbol, outstanding_share_quantity
    -- [BACKFILL-UAT-ORIG] FROM oss_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Outstanding Share Quantity as-of theo tung trading_dt: lay ban ghi VSDC co   -- [BACKFILL-UAT-NEW]
-- ds_snpst_dt lon nhat <= trading_dt (giong daily: ds_snpst_dt <= etl_date, order by ds_snpst_dt desc).   -- [BACKFILL-UAT-NEW]
-- Dung khoang hieu luc [ds_snpst_dt, ds_snpst_dt ke tiep) thay cho row_number theo tung ngay.   -- [BACKFILL-UAT-NEW]
oss_val_dedup AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        lsis.ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        lsis.ds_snpst_dt,   -- [BACKFILL-UAT-NEW]
        MAX(lsis.outstanding_share_quantity) AS outstanding_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis   -- [BACKFILL-UAT-NEW]
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'   -- [BACKFILL-UAT-NEW]
    GROUP BY lsis.ticker_symbol, lsis.ds_snpst_dt   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
oss_val_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        symbol,   -- [BACKFILL-UAT-NEW]
        outstanding_share_quantity,   -- [BACKFILL-UAT-NEW]
        ds_snpst_dt AS from_dt,   -- [BACKFILL-UAT-NEW]
        LEAD(ds_snpst_dt) OVER (PARTITION BY symbol ORDER BY ds_snpst_dt) AS to_dt   -- [BACKFILL-UAT-NEW]
    FROM oss_val_dedup   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
oss_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        s.symbol,   -- [BACKFILL-UAT-NEW]
        s.trading_dt,   -- [BACKFILL-UAT-NEW]
        o.outstanding_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM se_tr_sn s   -- [BACKFILL-UAT-NEW]
    INNER JOIN oss_val_all o   -- [BACKFILL-UAT-NEW]
        ON  o.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND CAST(s.trading_dt AS date) >= o.from_dt   -- [BACKFILL-UAT-NEW]
        AND (o.to_dt IS NULL OR CAST(s.trading_dt AS date) < o.to_dt)   -- [BACKFILL-UAT-NEW]
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
-- [BACKFILL-UAT-ORIG] free_float_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] lsis.ticker_symbol AS symbol,
        -- [BACKFILL-UAT-ORIG] lsis.free_float_share_quantity,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by lsis.ticker_symbol order by lsis.transaction_date desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
    -- [BACKFILL-UAT-ORIG] WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
        -- [BACKFILL-UAT-ORIG] AND lsis.ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] free_float_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT symbol, free_float_share_quantity
    -- [BACKFILL-UAT-ORIG] FROM free_float_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] ),
-- [BACKFILL-UAT-ONEPASS] Free Float as-of theo tung trading_dt: trong cac ban ghi ds_snpst_dt <= trading_dt,   -- [BACKFILL-UAT-NEW]
-- lay ban ghi co transaction_date lon nhat (giong daily: order by transaction_date desc, NULL xep cuoi).   -- [BACKFILL-UAT-NEW]
-- MAX(struct) chay dan theo ds_snpst_dt = "ban ghi tot nhat tinh den ngay do"; sau do gan khoang hieu luc.   -- [BACKFILL-UAT-NEW]
free_float_val_run AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        lsis.ticker_symbol AS symbol,   -- [BACKFILL-UAT-NEW]
        lsis.ds_snpst_dt,   -- [BACKFILL-UAT-NEW]
        MAX(named_struct('td', COALESCE(lsis.transaction_dt, DATE '1900-01-01'), 'q', lsis.free_float_share_quantity))   -- [BACKFILL-UAT-NEW]
            OVER (PARTITION BY lsis.ticker_symbol ORDER BY lsis.ds_snpst_dt   -- [BACKFILL-UAT-NEW]
                  RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS best   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis   -- [BACKFILL-UAT-NEW]
    WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
free_float_val_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        symbol,   -- [BACKFILL-UAT-NEW]
        best.q AS free_float_share_quantity,   -- [BACKFILL-UAT-NEW]
        ds_snpst_dt AS from_dt,   -- [BACKFILL-UAT-NEW]
        LEAD(ds_snpst_dt) OVER (PARTITION BY symbol ORDER BY ds_snpst_dt) AS to_dt   -- [BACKFILL-UAT-NEW]
    FROM (SELECT DISTINCT symbol, ds_snpst_dt, best FROM free_float_val_run) x   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
free_float_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        s.symbol,   -- [BACKFILL-UAT-NEW]
        s.trading_dt,   -- [BACKFILL-UAT-NEW]
        f.free_float_share_quantity   -- [BACKFILL-UAT-NEW]
    FROM se_tr_sn s   -- [BACKFILL-UAT-NEW]
    INNER JOIN free_float_val_all f   -- [BACKFILL-UAT-NEW]
        ON  f.symbol = s.symbol   -- [BACKFILL-UAT-NEW]
        AND CAST(s.trading_dt AS date) >= f.from_dt   -- [BACKFILL-UAT-NEW]
        AND (f.to_dt IS NULL OR CAST(s.trading_dt AS date) < f.to_dt)   -- [BACKFILL-UAT-NEW]
),

-- [MOI 2026-11-09, LLD O_GSTT_80] So CP VSDC dung TINH VON HOA: khop DUNG ngay giao dich T (transaction_dt = T), khong lookback; ngay T khong co ban ghi -> NULL (von hoa NULL).
-- outstanding_share_quantity / free_float_share_quantity (cot rieng) van dung oss_val / free_float_val (lookback).
cap_shares AS (
    SELECT symbol, trading_dt, outstanding_share_quantity, free_float_share_quantity
    FROM (
        SELECT
            lsis.ticker_symbol AS symbol,
            lsis.transaction_dt AS trading_dt,
            lsis.outstanding_share_quantity,
            lsis.free_float_share_quantity,
            row_number() OVER (PARTITION BY lsis.ticker_symbol, lsis.transaction_dt ORDER BY lsis.ds_snpst_dt DESC) AS rn
        FROM {{ ft_ref('ft_atm_listed_share_information') }} lsis
        WHERE lsis.src_stm_code = 'VSDC_OUTSTANDING_SHARES'
    ) x
    WHERE rn = 1
),

pc_financials AS (
    SELECT * FROM {{ ref('ft_tmp_sp_pc_financials') }}   -- [TACH BANG TAM 2026-11-09] xem model ft_tmp_sp_pc_financials
),

-- [MOI 2026-09-19, LLD review Nhom 24/O_GSTT_25] Prior Market Cap / Prior Free Float
-- Market Cap - von hoa cua ma TAI PHIEN GIAO DICH LIEN TRUOC (T-1 thuc su, khong phai
-- ngay lich T-1), dung cho K_GSTT_74/76 (trong so w_i/w_ff_i phai dung von hoa T-1, cung
-- ky voi Return_i/prior_index - truoc day dung nham von hoa NGAY T gay lech 1 phien).
-- Thay vi recompute tu atomic (them 1 lookback chain rieng, de lech logic voi cach fact
-- nay da tu tinh close_price/outstanding_share_quantity/free_float_share_quantity cua no),
-- SELF-REFERENCE lai chinh bang dich {{ ft_this() }} de doc dung gia tri DA LUU tren dong T-1 -
-- dung dung tinh than LLD "gia tri T-1 luu san tren dong T", cung pattern
-- fct_market_index_snpst.prior_index. Ngay dau tien build (chua co lich su) se ra NULL,
-- chap nhan duoc (giong LAG() tra NULL cho dong dau tien).
-- [BACKFILL-UAT-ORIG] prior_val_all AS (
    -- [BACKFILL-UAT-ORIG] SELECT
        -- [BACKFILL-UAT-ORIG] se_tr_sn_di.symbol,
        -- [BACKFILL-UAT-ORIG] t.close_price * t.outstanding_share_quantity AS prior_market_cap,
        -- [BACKFILL-UAT-ORIG] t.close_price * t.free_float_share_quantity  AS prior_free_float_market_cap,
        -- [BACKFILL-UAT-ORIG] row_number() over (partition by se_tr_sn_di.symbol order by t.snpst_dt_dim_id desc) as rn
    -- [BACKFILL-UAT-ORIG] FROM {{ ft_this() }} t
    -- [BACKFILL-UAT-ORIG] INNER JOIN se_tr_sn_di
        -- [BACKFILL-UAT-ORIG] ON  se_tr_sn_di.security_trading_snpst_dim_id = t.security_trading_snpst_dim_id
    -- [BACKFILL-UAT-ORIG] WHERE t.snpst_dt_dim_id < date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- [BACKFILL-UAT-ORIG] ),

-- [BACKFILL-UAT-ORIG] prior_val AS (
    -- [BACKFILL-UAT-ORIG] SELECT symbol, prior_market_cap, prior_free_float_market_cap
    -- [BACKFILL-UAT-ORIG] FROM prior_val_all
    -- [BACKFILL-UAT-ORIG] WHERE rn = 1
-- [BACKFILL-UAT-ORIG] )
-- [BACKFILL-UAT-ONEPASS] T-1 = gia tri cua phien lien truoc CUA CHINH MA DO trong cung lan chay (LAG theo trading_dt).   -- [BACKFILL-UAT-NEW]
-- Gia tri tinh tren cot da CAST giong het cac cot luu o {{ ft_this() }}. Dong dau tien cua moi ma trong lan chay   -- [BACKFILL-UAT-NEW]
-- lay tu {{ ft_this() }} (dong luu gan nhat co snpst_dt_dim_id < ngay dau lan chay) - giong daily.   -- [BACKFILL-UAT-NEW]
prior_base AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        s.symbol,   -- [BACKFILL-UAT-NEW]
        s.trading_dt,   -- [BACKFILL-UAT-NEW]
        CAST(cp.cap_price AS decimal(23,2)) * CAST(cap_shares.outstanding_share_quantity AS bigint) AS market_cap,   -- [SUA 2026-11-02, LLD v4.58 muc a] gia tinh von hoa moi
        CAST(cp.cap_price AS decimal(23,2)) * CAST(cap_shares.free_float_share_quantity AS bigint) AS free_float_market_cap   -- [SUA 2026-11-02]
    FROM se_tr_sn s   -- [BACKFILL-UAT-NEW]
    LEFT JOIN se_tr_cap cp   -- [SUA 2026-11-02]
        ON  cp.symbol = s.symbol   -- [SUA 2026-11-02]
        AND cp.trading_dt = s.trading_dt   -- [SUA 2026-11-02]
    LEFT JOIN cap_shares   -- [SUA 2026-11-09, O_GSTT_80]
        ON  cap_shares.symbol = s.symbol
        AND cap_shares.trading_dt = s.trading_dt
),

-- [BACKFILL-UAT-NEW]
prior_this_all AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        se_tr_sn_di.symbol,   -- [BACKFILL-UAT-NEW]
        t.market_cap            AS prior_market_cap,   -- [SUA 2026-11-02, LLD v4.58 muc a] doc market_cap da luu o dong T-1
        t.free_float_market_cap AS prior_free_float_market_cap,   -- [SUA 2026-11-02]
        row_number() over (partition by se_tr_sn_di.symbol order by t.snpst_dt_dim_id desc) as rn   -- [BACKFILL-UAT-NEW]
    FROM {{ ft_this() }} t   -- [BACKFILL-UAT-NEW]
    INNER JOIN se_tr_sn_di   -- [BACKFILL-UAT-NEW]
        ON  se_tr_sn_di.security_trading_snpst_dim_id = t.security_trading_snpst_dim_id   -- [BACKFILL-UAT-NEW]
        AND se_tr_sn_di.ds_snpst_dt = to_date(t.snpst_dt_dim_id, 'yyyyMMdd')   -- [FIRST-TIME 2026-10-18] dim theo ngay cua dong da luu
    WHERE t.snpst_dt_dim_id < (SELECT date_format(MIN(trading_dt), 'yyyyMMdd') FROM trade_dates)   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
prior_this AS (   -- [BACKFILL-UAT-NEW]
    SELECT symbol, prior_market_cap, prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
    FROM prior_this_all   -- [BACKFILL-UAT-NEW]
    WHERE rn = 1   -- [BACKFILL-UAT-NEW]
),

-- [BACKFILL-UAT-NEW]
prior_val AS (   -- [BACKFILL-UAT-NEW]
    SELECT   -- [BACKFILL-UAT-NEW]
        b.symbol,   -- [BACKFILL-UAT-NEW]
        b.trading_dt,   -- [BACKFILL-UAT-NEW]
        CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.symbol ORDER BY b.trading_dt) = 1   -- [BACKFILL-UAT-NEW]
             THEN pt.prior_market_cap   -- [BACKFILL-UAT-NEW]
             ELSE LAG(b.market_cap) OVER (PARTITION BY b.symbol ORDER BY b.trading_dt)   -- [BACKFILL-UAT-NEW]
        END AS prior_market_cap,   -- [BACKFILL-UAT-NEW]
        CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.symbol ORDER BY b.trading_dt) = 1   -- [BACKFILL-UAT-NEW]
             THEN pt.prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
             ELSE LAG(b.free_float_market_cap) OVER (PARTITION BY b.symbol ORDER BY b.trading_dt)   -- [BACKFILL-UAT-NEW]
        END AS prior_free_float_market_cap   -- [BACKFILL-UAT-NEW]
    FROM prior_base b   -- [BACKFILL-UAT-NEW]
    LEFT JOIN prior_this pt   -- [BACKFILL-UAT-NEW]
        ON  pt.symbol = b.symbol   -- [BACKFILL-UAT-NEW]
)
   -- [BACKFILL-UAT-NEW]

SELECT /*+ BROADCAST(pu_co), BROADCAST(pu_co_di), BROADCAST(sec_co_ctck) */
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string) AS security_trading_snpst_dim_id,
    CAST(pu_co_di.public_company_dim_id AS string)            AS public_company_dim_id,
    CAST(sec_co_ctck.securities_company_dim_id AS string)     AS securities_company_dim_id,
    CAST(date_format(se_tr_sn.trading_dt, 'yyyyMMdd') AS string)                     AS snpst_dt_dim_id,
    CAST(se_tr_agg.total_vol AS bigint)                            AS total_vol,
    CAST(se_tr_agg.total_val AS decimal(23,2))                  AS total_val,
    CAST(se_tr_agg.total_matched_vol AS bigint)            AS total_matched_vol,
    CAST(se_tr_agg.total_matched_val AS decimal(23,2))  AS total_matched_val,
    CAST(se_tr_agg.total_derivative_vol AS bigint)                 AS total_derivative_vol,
    CAST(se_tr_agg.total_derivative_val AS decimal(23,2))       AS total_derivative_val,
    CAST(se_tr_agg.total_derivative_negotiated_vol AS bigint)   AS total_derivative_negotiated_vol,
    CAST(se_tr_agg.total_derivative_negotiated_val AS decimal(23,2)) AS total_derivative_negotiated_val,
    CAST(se_tr_agg.total_negotiated_vol AS bigint)                 AS total_negotiated_vol,
    CAST(se_tr_agg.total_negotiated_val AS decimal(23,2))       AS total_negotiated_val,
    CAST(se_tr_agg.foreign_buy_vol - se_tr_agg.foreign_sell_vol AS bigint)              AS foreign_net_vol,
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
    CAST(se_tr_agg.foreign_buy_vol AS bigint)                      AS foreign_buy_vol,
    CAST(se_tr_agg.foreign_sell_vol AS bigint)                     AS foreign_sell_vol,
    CAST(se_tr_agg.foreign_buy_val AS decimal(23,2))            AS foreign_buy_val,
    CAST(se_tr_agg.foreign_sell_val AS decimal(23,2))           AS foreign_sell_val,
    CAST(se_tr_agg.proprietary_buy_val AS decimal(23,2))        AS proprietary_buy_val,
    CAST(se_tr_agg.proprietary_sell_val AS decimal(23,2))       AS proprietary_sell_val,
    CAST(se_tr_agg.proprietary_buy_vol AS bigint)                  AS proprietary_buy_vol,
    CAST(se_tr_agg.proprietary_sell_vol AS bigint)                 AS proprietary_sell_vol,
    CAST(se_tr_agg.bond_trading_vol AS bigint)                     AS bond_trading_vol,
    CAST(se_tr_agg.bond_trading_val AS decimal(23,2))           AS bond_trading_val,
    CAST(se_tr_agg.bond_negotiated_vol AS bigint)               AS bond_negotiated_vol,
    CAST(se_tr_agg.bond_negotiated_val AS decimal(23,2))     AS bond_negotiated_val,
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
    CAST(se_tr_agg.foreign_net_negotiated_vol AS bigint)        AS foreign_net_negotiated_vol,
    CAST(se_tr_agg.foreign_net_derivative_vol AS bigint)        AS foreign_net_derivative_vol,
    CAST(se_tr_agg.foreign_buy_derivative_vol AS bigint)        AS foreign_buy_derivative_vol,
    CAST(se_tr_agg.foreign_sell_derivative_vol AS bigint)       AS foreign_sell_derivative_vol,
    CAST(date_format(pc_financials.fr_period_end_dt, 'yyyyMMdd') AS string) AS fr_period_end_dt_dim_id,
    CAST(scms_ctck_fin.securities_company_net_profit_after_tax_ttm AS decimal(23,2)) AS securities_company_net_profit_after_tax_ttm,
    CAST(scms_ctck_fin.securities_company_owner_equity AS decimal(23,2)) AS securities_company_owner_equity,
    -- [MOI 2026-11-02, LLD v4.58] 30 cot moi o CUOI, dung thu tu LLD (insert theo vi tri, ALTER ADD COLUMN AFTER securities_company_owner_equity)
    CAST(se_tr_agg.round_lot_matched_vol AS bigint)                        AS round_lot_matched_vol,
    CAST(se_tr_agg.round_lot_matched_val AS decimal(23,2))                 AS round_lot_matched_val,
    CAST(se_tr_agg.round_lot_negotiated_vol AS bigint)                        AS round_lot_negotiated_vol,
    CAST(se_tr_agg.round_lot_negotiated_val AS decimal(23,2))                 AS round_lot_negotiated_val,
    CAST(se_tr_agg.odd_lot_matched_vol AS bigint)                        AS odd_lot_matched_vol,
    CAST(se_tr_agg.odd_lot_matched_val AS decimal(23,2))                 AS odd_lot_matched_val,
    CAST(se_tr_agg.odd_lot_negotiated_vol AS bigint)                        AS odd_lot_negotiated_vol,
    CAST(se_tr_agg.odd_lot_negotiated_val AS decimal(23,2))                 AS odd_lot_negotiated_val,
    CAST(se_tr_agg.derivative_round_lot_matched_vol AS bigint)                        AS derivative_round_lot_matched_vol,
    CAST(se_tr_agg.derivative_round_lot_matched_val AS decimal(23,2))                 AS derivative_round_lot_matched_val,
    CAST(se_tr_agg.derivative_round_lot_negotiated_vol AS bigint)                        AS derivative_round_lot_negotiated_vol,
    CAST(se_tr_agg.derivative_round_lot_negotiated_val AS decimal(23,2))                 AS derivative_round_lot_negotiated_val,
    CAST(se_tr_agg.derivative_odd_lot_matched_vol AS bigint)                        AS derivative_odd_lot_matched_vol,
    CAST(se_tr_agg.derivative_odd_lot_matched_val AS decimal(23,2))                 AS derivative_odd_lot_matched_val,
    CAST(se_tr_agg.derivative_odd_lot_negotiated_vol AS bigint)                        AS derivative_odd_lot_negotiated_vol,
    CAST(se_tr_agg.derivative_odd_lot_negotiated_val AS decimal(23,2))                 AS derivative_odd_lot_negotiated_val,
    CAST(oi_val.open_interest_quantity AS bigint)                 AS open_interest_quantity,
    CAST(se_tr_agg.bond_round_lot_matched_vol AS bigint)                        AS bond_round_lot_matched_vol,
    CAST(se_tr_agg.bond_round_lot_matched_val AS decimal(23,2))                 AS bond_round_lot_matched_val,
    CAST(se_tr_agg.bond_round_lot_negotiated_vol AS bigint)                        AS bond_round_lot_negotiated_vol,
    CAST(se_tr_agg.bond_round_lot_negotiated_val AS decimal(23,2))                 AS bond_round_lot_negotiated_val,
    CAST(se_tr_agg.bond_odd_lot_matched_vol AS bigint)                        AS bond_odd_lot_matched_vol,
    CAST(se_tr_agg.bond_odd_lot_matched_val AS decimal(23,2))                 AS bond_odd_lot_matched_val,
    CAST(se_tr_agg.bond_odd_lot_negotiated_vol AS bigint)                        AS bond_odd_lot_negotiated_vol,
    CAST(se_tr_agg.bond_odd_lot_negotiated_val AS decimal(23,2))                 AS bond_odd_lot_negotiated_val,
    CAST(se_tr_sn.ceiling_price AS decimal(23,2))                 AS ceiling_price,
    CAST(se_tr_sn.floor_price AS decimal(23,2))                   AS floor_price,
    CAST(se_tr_sn.open_price AS decimal(23,2))                    AS open_price,
    CAST(se_tr_cap.cap_price * cap_shares.free_float_share_quantity AS decimal(23,2)) AS free_float_market_cap,
    CAST(se_tr_cap.cap_price * cap_shares.outstanding_share_quantity AS decimal(23,2)) AS market_cap
FROM se_tr_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = se_tr_sn.symbol
    AND se_tr_sn_di.ds_snpst_dt = CAST(se_tr_sn.trading_dt AS date)   -- [FIRST-TIME 2026-10-18]
-- [SUA 2026-09-22, CHOT phuong an cuoi] Trai phieu (stock_tp_code='1') join Nganh qua 3 ky tu
-- dau cua chinh symbol trai phieu (SUBSTR(symbol,1,3) = ma ticker cong ty phat hanh, theo
-- quy uoc dat ma trai phieu doanh nghiep VN) - thay the issuer_nm (MDDS, dung tam 2026-09-21,
-- bi thu hoi vi phu thuoc du lieu nguon khong sach). Cac loai CK khac (co phieu/CCQ/CW) van
-- join qua equity_ticker_symbol nhu cu (company_join_symbol da xu ly san CASE
-- underlying_symbol cho CW).
-- [TOI UU 2026-11-09, chi ban first_time] Dieu kien OR (2 nhanh) khong co khoa equi-join -> Spark chay BroadcastNestedLoopJoin/Cartesian. Doi sang 1 khoa equi:
-- CASE chon dung khoa cua tung nhanh (trai phieu: SUBSTR 3 ky tu tru nhom bi loai; loai khac: company_join_symbol), CASE ra NULL = khong khop nhu OR cu.
-- pu_co da dedup 1 dong/equity_ticker_symbol nen khong nhan dong. Ket qua giu nguyen.
LEFT JOIN pu_co
    ON  pu_co.equity_ticker_symbol = CASE
            WHEN se_tr_sn.stock_tp_code = '1' THEN
                CASE WHEN NOT (
                         se_tr_sn.symbol RLIKE '^[A-Za-z]{2}GB'
                         OR se_tr_sn.symbol RLIKE '^(TD|TP|CP|QH|KB|BL)'
                         OR se_tr_sn.symbol RLIKE '^(HCM|HAN)'
                     ) THEN SUBSTR(se_tr_sn.symbol,1,3) END
            WHEN se_tr_sn.stock_tp_code <> '1' THEN se_tr_sn.company_join_symbol
        END
LEFT JOIN pu_co_di
    ON  pu_co_di.public_company_code = pu_co.pc_code
LEFT JOIN sec_co_ctck
    ON  sec_co_ctck.symbol = se_tr_sn.symbol
LEFT JOIN scms_ctck_fin
    ON  scms_ctck_fin.symbol = se_tr_sn.symbol
    AND scms_ctck_fin.trading_dt = se_tr_sn.trading_dt
LEFT JOIN se_tr_agg
    ON  se_tr_agg.security_symbol_code = se_tr_sn.trade_join_symbol
    AND se_tr_agg.trade_dt = se_tr_sn.trading_dt
-- [BACKFILL-UAT-ORIG] LEFT JOIN pc_financials
    -- [BACKFILL-UAT-ORIG] ON  pc_financials.symbol = se_tr_sn.symbol
LEFT JOIN pc_financials   -- [BACKFILL-UAT-NEW]
    ON  pc_financials.symbol = se_tr_sn.symbol   -- [BACKFILL-UAT-NEW]
    AND pc_financials.trading_dt = CAST(se_tr_sn.trading_dt AS date)   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-ORIG] LEFT JOIN free_float_val
    -- [BACKFILL-UAT-ORIG] ON  free_float_val.symbol = se_tr_sn.symbol
LEFT JOIN free_float_val   -- [BACKFILL-UAT-NEW]
    ON  free_float_val.symbol = se_tr_sn.symbol   -- [BACKFILL-UAT-NEW]
    AND free_float_val.trading_dt = se_tr_sn.trading_dt   -- [BACKFILL-UAT-NEW]
-- [SUA 2026-09-17] outstanding_share_quantity join thang tai day theo symbol MDDS thuan
-- (giong free_float_share_quantity, dung LLD: KHONG ap CASE underlying_symbol cua CW),
-- khong con di qua pc_financials/pc_id nua.
-- [BACKFILL-UAT-ORIG] LEFT JOIN oss_val
    -- [BACKFILL-UAT-ORIG] ON  oss_val.symbol = se_tr_sn.symbol
LEFT JOIN oss_val   -- [BACKFILL-UAT-NEW]
    ON  oss_val.symbol = se_tr_sn.symbol   -- [BACKFILL-UAT-NEW]
    AND oss_val.trading_dt = se_tr_sn.trading_dt   -- [BACKFILL-UAT-NEW]
-- [BACKFILL-UAT-ORIG] LEFT JOIN prior_val
    -- [BACKFILL-UAT-ORIG] ON  prior_val.symbol = se_tr_sn.symbol
LEFT JOIN prior_val   -- [BACKFILL-UAT-NEW]
    ON  prior_val.symbol = se_tr_sn.symbol   -- [BACKFILL-UAT-NEW]
    AND prior_val.trading_dt = se_tr_sn.trading_dt   -- [BACKFILL-UAT-NEW]
LEFT JOIN se_tr_cap
    ON  se_tr_cap.symbol = se_tr_sn.symbol
    AND se_tr_cap.trading_dt = se_tr_sn.trading_dt
LEFT JOIN cap_shares   -- [MOI 2026-11-09, O_GSTT_80]
    ON  cap_shares.symbol = se_tr_sn.symbol
    AND cap_shares.trading_dt = se_tr_sn.trading_dt
LEFT JOIN oi_val
    ON  oi_val.symbol = se_tr_sn.symbol
    AND oi_val.rpt_dt = se_tr_sn.trading_dt
    AND se_tr_sn.stock_tp_code = '4'
    AND se_tr_sn.floor_code IN ('02','03','04')
-- [BACKFILL-UAT-ORIG] WHERE se_tr_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
-- (bo loc trading_dt = etl_date: chay mot luot nhieu ngay)   -- [BACKFILL-UAT-NEW]
