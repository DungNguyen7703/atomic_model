/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_flow_snpst
* Program name: Fact Investor Flow Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Grain: 1 dong / nhom NDT (investor_group_dim_id) / ngay, PIVOT tu
*   6 nhom co dinh trong {{ ref('dtm_investor_group_dim') }} (FOREIGN,
*   PROPRIETARY, DOMESTIC_INSTITUTION, DOMESTIC_INDIVIDUAL,
*   FOREIGN_INDIVIDUAL, FOREIGN_INSTITUTION) -- da doi chieu, 6 ma nay
*   khop CHINH XAC voi 6 investor_group_code co san trong seed dim (mac
*   du description cu trong schema_dtm_pttt.yml ghi "chi 4/6 nhom duoc
*   populate", LLD DTM_PTTT_fct_investor_flow_snpst.csv [ban cap nhat
*   2026-09-23, sua Nhom 15 BA dong 278-281] mo ta ro CA 6 nhanh voi
*   dieu kien cu the -> code du 6 nhanh theo dung LLD moi nhat, KHONG
*   theo ghi chu 4/6 cu).
* - Buy Value / Sell Value cua tung nhom: dung RIENG dieu kien ben MUA
*   (buy_*) cho buy_val va dieu kien ben BAN (sell_*) cho sell_val, dung
*   quy uoc da dung o dtm_fct_futures_investor_flow_snpst.sql (SUM(CASE
*   WHEN ...)) thay vi GROUP BY rieng le -- tuong duong ve mat toan hoc
*   voi mo ta trong LLD (etl_logic cot Buy Value / Sell Value).
* - Dieu kien phan nhom copy CHINH XAC tu etl_logic cot
*   investor_group_dim_id trong LLD (6 nhanh, phan biet theo
*   src_stm_code HOSE/HNX vi 2 nguon dung ma phan loai NDT khac nhau):
*   + FOREIGN: buy/sell_foreign_investor_tp_code IN ('10','20')
*   + PROPRIETARY: buy/sell_client_house_cl_code = '30'
*   + DOMESTIC_INDIVIDUAL: HOSE buy/sell_investor_tp_code='1100' HOAC
*     HNX buy/sell_investor_tp_code='8000' AND
*     buy/sell_foreign_investor_tp_code='00'
*   + FOREIGN_INDIVIDUAL: HOSE buy/sell_investor_tp_code='7200' HOAC
*     HNX buy/sell_investor_tp_code='8000' AND
*     buy/sell_foreign_investor_tp_code IN ('10','20')
*   + DOMESTIC_INSTITUTION: HOSE buy/sell_investor_tp_code NOT IN
*     ('1100','1200') AND buy/sell_foreign_investor_tp_code='00' HOAC
*     HNX buy/sell_investor_tp_code<>'8000' AND
*     buy/sell_foreign_investor_tp_code='00'
*   + FOREIGN_INSTITUTION: HOSE buy/sell_investor_tp_code='7100' HOAC
*     HNX buy/sell_investor_tp_code<>'8000' AND
*     buy/sell_foreign_investor_tp_code IN ('10','20')
* - atm_securities_trade (da XAC NHAN TON TAI): KHONG _hstr, KHONG
*   ds_rcrd_st -> loc truc tiep trade_dt = etl_date, market_id_code IN
*   ('STO','STX','UPX') dung theo LLD.
* - investor_group_dim_id lay tu {{ ref('dtm_investor_group_dim') }}
*   (da XAC NHAN TON TAI, seed tinh 6 dong) qua INNER JOIN theo
*   investor_group_code -- kieu du lieu la STRING (macro
*   generate_surrogate_key_bigint thuc chat tra ve sha256 dang string,
*   khong phai kieu bigint that, du ten macro).
* - trading_val_ratio = (buy_val + sell_val) cua nhom / SUM(buy_val + sell_val)
*   cua 4 nhom loai tru nhau (DOMESTIC_INDIVIDUAL, FOREIGN_INDIVIDUAL,
*   DOMESTIC_INSTITUTION, FOREIGN_INSTITUTION) trong cung ngay * 100
*   (4 nhom cong lai = 100). [2026-10-13] DOI theo LLD commit 7d9a950c
*   (O_PTTT_47): truoc day mau so la fct_market_risk_snpst.total_trading_val_matched
*   (1 chieu) nen ra >100 (vd 190.19) -> BO LEFT JOIN dtm_fct_market_risk_snpst,
*   mau so tinh bang window SUM tren chinh bang nay. Cac nhom FOREIGN va
*   PROPRIETARY van co ratio tinh theo cung mau so 4 nhom (co the chong lan).
* - snpst_dt_dim_id tinh truc tiep bang date_format(trade_dt,
*   'yyyyMMdd'), khong JOIN vat ly toi dtm_cdr_dt_dim, giong convention
*   chung PTTT.
*--------------------------------------------------------------------*
* 2026-10-07			tuan.nguyenvanb		market_id_code HOSE doi 'STO' -> 'STK': du lieu atm_securities_trade
*									(HOSE) chi co 'STK', 'STO' lam model BO SOT toan bo san HOSE (buy_val,
*									sell_val, net_flow_val). LLD van ghi 'STO' - can design sua lai LLD.
* 2026-10-13			tuan.nguyenvanb		Ap dung LLD commit 88a297c0 + 7d9a950c: (1) CTE tr them
*									board_tp_code IN ('G1','G2','G3','G4','G7','G8') (O_PTTT_46, loai board thoa
*									thuan T1/T3/T4/T6) -> anh huong buy_val/sell_val/net_flow_val; (2) trading_val_ratio
*									doi mau so thanh tong (buy+sell) 4 nhom loai tru nhau (O_PTTT_47), bo LEFT JOIN
*									dtm_fct_market_risk_snpst. Khong doi cot/kieu du lieu nen khong can ALTER.
* 2026-10-19			tuan.nguyenvanb		Ap dung LLD commit 05c7c2d3 (O_PTTT_51, BA STT 13-17): doi cach phan nhom NDT - FOREIGN theo ky tu thu 4
*									so tai khoan MUA/BAN IN ('E','F'), PROPRIETARY IN ('A','E','P'); 4 nhom ca nhan/to chuc x trong/ngoai nuoc
*									theo VSDC atm_investment_account.investment_account_tp_code = '3'/'4'/'5'/'6' (ban ghi moi nhat theo so TK,
*									LEFT JOIN rieng ben mua/ben ban) THAY cho buy/sell_investor_tp_code, buy/sell_foreign_investor_tp_code,
*									buy/sell_client_house_cl_code. BO loc board G1..G8 (dao O_PTTT_46 theo BA). Cac nhom khong loai tru nhau.
*									Khong doi ten/kieu/vi tri cot output nen khong can ALTER. market_id_code HOSE van 'STK' (LLD ghi 'STO').
* 2026-10-25		tuan.nguyenvanb		[DOI NGUON ATOMIC] Bo atm_investment_account (model tam), doc atm_open_investor_account (cung nguon VSDC open_investors).
*                                       Doi cot: investment_account_nbr -> investor_account_nbr, investment_account_tp_code (string) -> investor_tp_code (int, so sanh bang so),
*                                       event_dt -> open_dt. Cot output cua model khong doi -> khong ALTER mart/ClickHouse.
* 2026-11-03		tuan.nguyenvanb		[SUA] atm_open_investor_account tren Spark khong con cot ds_snpst_dt (chi con partition open_dt): bo ds_snpst_dt khoi ORDER BY cua CTE inv_acc, chi xep theo open_dt DESC. Khong doi cot/kieu.
*/

WITH
-- [SUA 2026-10-19, LLD 05c7c2d3 / O_PTTT_51] VSDC open_investors (atm_open_investor_account): lay ban ghi MOI NHAT theo
-- so tai khoan (event_dt = open_date DESC; bang nguon co the trung so TK) - cung cach lam dtm_fct_investor_category_trading_snpst.
inv_acc AS (

    SELECT investor_account_nbr, investor_tp_code
    FROM (
        SELECT
            investor_account_nbr
            , investor_tp_code
            , ROW_NUMBER() OVER (PARTITION BY investor_account_nbr ORDER BY open_dt DESC) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE investor_account_nbr IS NOT NULL
    ) x
    WHERE rn = 1

),

tr AS (

    SELECT
        t.trade_dt
        , t.execution_vol
        , t.execution_price
        , t.buy_account_nbr
        , t.sell_account_nbr
        , vsdc_buy.investor_tp_code  AS buy_vsdc_tp_code
        , vsdc_sell.investor_tp_code AS sell_vsdc_tp_code
    FROM {{ ref('atm_securities_trade') }} t
    LEFT JOIN inv_acc vsdc_buy
        ON vsdc_buy.investor_account_nbr = t.buy_account_nbr
    LEFT JOIN inv_acc vsdc_sell
        ON vsdc_sell.investor_account_nbr = t.sell_account_nbr
    WHERE t.trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND t.market_id_code IN ('STK','STX','UPX')
        -- [SUA 2026-10-19] BO loc board_tp_code IN ('G1',...,'G8') (SQL BA khong loc board - dao O_PTTT_46)

),

grouped AS (

    SELECT
        trade_dt

        -- NDT nuoc ngoai: ky tu thu 4 cua so tai khoan IN ('E','F'); Tu doanh: IN ('A','E','P').
        -- Cac nhom KHONG loai tru nhau (E vua la ngoai vua la tu doanh) - moi nhom tinh doc lap tren cung giao dich.
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F')
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_buy_val
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F')
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_sell_val

        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('A','E','P')
            THEN execution_vol * execution_price ELSE 0 END)          AS proprietary_buy_val
        , SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('A','E','P')
            THEN execution_vol * execution_price ELSE 0 END)          AS proprietary_sell_val

        -- 4 nhom ca nhan/to chuc theo VSDC investor_type (atm_open_investor_account.investor_tp_code):
        -- '3' ca nhan trong nuoc, '4' ca nhan nuoc ngoai, '5' to chuc trong nuoc, '6' to chuc nuoc ngoai (theo LLD 05c7c2d3).
        , SUM(CASE WHEN buy_vsdc_tp_code = 3
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_individual_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 3
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_individual_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 4
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_individual_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 4
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_individual_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 5
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_institution_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 5
            THEN execution_vol * execution_price ELSE 0 END)          AS domestic_institution_sell_val

        , SUM(CASE WHEN buy_vsdc_tp_code = 6
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_institution_buy_val
        , SUM(CASE WHEN sell_vsdc_tp_code = 6
            THEN execution_vol * execution_price ELSE 0 END)          AS foreign_institution_sell_val

    FROM tr
    GROUP BY trade_dt

),

pivoted AS (

    SELECT trade_dt, CAST('FOREIGN' AS string) AS investor_group_code, foreign_buy_val AS buy_val, foreign_sell_val AS sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('PROPRIETARY' AS string), proprietary_buy_val, proprietary_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('DOMESTIC_INDIVIDUAL' AS string), domestic_individual_buy_val, domestic_individual_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('FOREIGN_INDIVIDUAL' AS string), foreign_individual_buy_val, foreign_individual_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('DOMESTIC_INSTITUTION' AS string), domestic_institution_buy_val, domestic_institution_sell_val FROM grouped
    UNION ALL
    SELECT trade_dt, CAST('FOREIGN_INSTITUTION' AS string), foreign_institution_buy_val, foreign_institution_sell_val FROM grouped

),

joined AS (

    SELECT
        pivoted.trade_dt
        , CAST(date_format(pivoted.trade_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id
        , investor_group_dim.investor_group_dim_id
        , pivoted.investor_group_code
        , pivoted.buy_val
        , pivoted.sell_val
    FROM pivoted
    INNER JOIN {{ ref('dtm_investor_group_dim') }} investor_group_dim
        ON investor_group_dim.investor_group_code = pivoted.investor_group_code

),

-- [MOI 2026-10-13] Mau so trading_val_ratio: tong (buy_val + sell_val) cua 4 nhom
-- loai tru nhau trong ngay (O_PTTT_47) - xem ghi chu dau file.
ratio_base AS (

    SELECT
        joined.*
        , SUM(CASE WHEN joined.investor_group_code IN
                ('DOMESTIC_INDIVIDUAL','FOREIGN_INDIVIDUAL','DOMESTIC_INSTITUTION','FOREIGN_INSTITUTION')
            THEN joined.buy_val + joined.sell_val END)
            OVER (PARTITION BY joined.snpst_dt_dim_id)                AS total_val_4_groups
    FROM joined

)

SELECT
    CAST(ratio_base.snpst_dt_dim_id AS string)                  AS snpst_dt_dim_id,
    CAST(ratio_base.investor_group_dim_id AS string)           AS investor_group_dim_id,
    CAST(ratio_base.buy_val AS decimal(23,2))                   AS buy_val,
    CAST(ratio_base.sell_val AS decimal(23,2))                  AS sell_val,
    CAST(ratio_base.buy_val - ratio_base.sell_val AS decimal(23,2)) AS net_flow_val,
    CAST(
        (ratio_base.buy_val + ratio_base.sell_val)
        / NULLIF(ratio_base.total_val_4_groups, 0) * 100
    AS decimal(5,2))                                            AS trading_val_ratio
FROM ratio_base
