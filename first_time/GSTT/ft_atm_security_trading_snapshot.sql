-- [FIRST-TIME] ft_atm_security_trading_snapshot: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_security_trading_snapshot (config ft_target='security_trading_snapshot', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_security_trading_snapshot
* Program name: Atomic Security Trading Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01	tuan.nguyenvanb	[FIX] listed_share_count/total_listing_vol CAST int -> bigint: ACB co
*									5.804.421.957 > 2^31-1 nen CAST(chuoi AS int) ra NULL (K_GSTT_108). ALTER bang
*									vat ly (scratch/alter_total_listing_vol_int_to_bigint_20261001.sql) phai chay TRUOC khi backdate.
* 2026-10-01	tuan.nguyenvanb	[FIX] first_trading_dt/listing_dt/last_trading_dt/issue_dt truoc day
*									CAST(chuoi AS date) -> NULL 100% (154.089/154.089 dong, 2026-08-28) vi nguon
*									khong phai yyyy-MM-dd: firsttradingdate dd/MM/yyyy (vd 22/05/2026),
*									listingdate yyyyMMdd (vd 20260522). Doi sang to_date(chuoi, pattern);
*									last_trading_dt/issue_dt chua co mau du lieu -> thu ca 2 pattern.
*
* 2026-10-09		tuan.nguyenvanb		[FIX K_GSTT_8] maturity_dt NULL cho phai sinh (san 03) va trai phieu HNX (san 02): nguon
*									maturitydate dang yyyyMMdd (vd 20260317) nhung truoc day chi thu pattern dd/MM/yyyy ->
*									NULL. Doi sang COALESCE(dd/MM/yyyy, yyyyMMdd) giong last_trading_dt/issue_dt.
* 2026-10-09		tuan.nguyenvanb		[BACKFILL-UAT-NEW] BAN FIRST-TIME theo atomic moi (bo trading_dt): strategy append (khong gan de
*									ds_snpst_dt = etl_date), tu gan ds_snpst_dt = CAST(tradingdate AS date) cho tung dong -> ds_snpst_dt = ngay
*									giao dich nhu khi chay daily. Cot ds_snpst_dt dat CUOI SELECT (truoc ds_etl_pcs_tms do macro them). [BACKFILL-UAT-NEW]
* 2026-10-10		tuan.nguyenvanb		[BA CHOT] coupon_rate: mo rong kieu decimal(8,5) -> decimal(18,5) de nhan ca gia tri nguon sai
*									(vd 7375.0 cua HDB125011) thay vi bi tran thanh NULL. yield: chi khi nguon = -9999 hoac -9999.9999
*									(gia tri danh dau khong co du lieu) thi doi thanh NULL, cac gia tri khac giu nguyen.
* 2026-10-12		tuan.nguyenvanb		Bo sung cot sequence (bigint, JAD_STOCKINFOR.SEQUENCE) sau issue_dt, truoc ds_snpst_dt.
* 2026-10-12		tuan.nguyenvanb		Bo sung foreign_buy_val, foreign_sell_val decimal(23,2) (dung LLD atomic, sau sequence) - nguon
*                                       moi cua fct_foreign_trading_min_snpst (LLD GSTT d1e944ee, O_GSTT_41 muc 4).
* 2026-10-16		tuan.nguyenvanb		Dong bo SELECT voi atm_security_trading_snapshot (daily, duc.luxuan 12-13/10): them trading_dt (sau symbol), bo trading_tms,
*                                       16 cot *_vol bigint, coupon_rate decimal(8,5), dung thu tu cot bang vat ly. Giu ds_snpst_dt (= tradingdate) cuoi SELECT
*                                       va logic yield -9999 -> NULL cua first-time.
* 2026-10-22		tuan.nguyenvanb		Doi ten cot theo design: symbol->ticker_symbol, security_full_nm->full_nm (vi tri khong doi).
* 2026-11-02		tuan.nguyenvanb		[LLD v4.58, O_GSTT_78 muc a] Them cot vol_weighted_average_price (bigint, JAD_STOCKINFOR.VWAP) sau foreign_sell_val - dung tinh von hoa UPCOM theo VWAP phien ke tiep.
*								Bang vat ly can ALTER ADD COLUMN vol_weighted_average_price bigint AFTER foreign_sell_val (insert theo vi tri).
* 2026-11-06		tuan.nguyenvanb		[DONG BO BANG VAT LY] Them 7 cot dat TRUOC vol_weighted_average_price (theo thu tu bang vat ly): prior_price decimal(23,2), open_interest_change bigint,
*                                       price_one, price_two decimal(23,2), total_buy_vol, total_sell_vol bigint, trading_tms timestamp (JAD_STOCKINFOR: PRIOR_PRICE, OPENINTERESTCHANGE,
*                                       PRICEONE, PRICETWO, TOTALBUYVOL, TOTALSELLVOL, tradingdate+tradingtime, cung cong thuc ODS vi bang vat ly ODS khong co cot tradingtimestamp). Bang vat ly da co san cac cot nay (insert theo vi tri).
*--------------------------------------------------------------------*
* 2026-11-09		tuan.nguyenvanb		[DEV KHAC GUI, DONG BO] 23 cot so luong/gia doi kieu bigint -> decimal(23,2): close_vol, bid_vol_1..3, offer_vol_1..3, total_trading_vol, total_offer_vol, total_bid_vol,
*                                       foreign_buy/sell/remain/room_vol, pt_match_vol, pt_total_traded_vol, listed_share_count, total_listing_vol, open_interest, open_interest_change,
*                                       total_buy_vol, total_sell_vol, vol_weighted_average_price (nguon FLOAT/decimal, tranh cat phan thap phan). Iceberg KHONG doi bigint -> decimal tai cho: phai tao lai bang (xem DDL).
*                                       LUU Y design (dm_atm_security_trading_snapshot-MDDS.JAD_STOCKINFOR.yaml) dang ghi bigint - can raise design.
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH ja_st AS (
    SELECT
        historyid
        , symbol
        , tradingdate
        , fullname
        , stockid
        , kid
        , stocktype
        , floorcode
        , tradingsessionid
        , lastcolor
        , symbolstatuscode
        , ceiling
        , floor
        , reference
        , closeprice
        , closevol
        , change
        , open
        , high
        , low
        , averageprice
        , bidprice1
        , bidvol1
        , bidprice2
        , bidvol2
        , bidprice3
        , bidvol3
        , offerprice1
        , offervol1
        , offerprice2
        , offervol2
        , offerprice3
        , offervol3
        , totaltrading
        , totaltradingvalue
        , total_offer_qtty
        , total_bid_qtty
        , foreignbuy
        , foreignsell
        , foreignremain
        , foreignroom
        , pt_match_qtty
        , pt_match_price
        , pt_total_traded_qtty
        , pt_total_traded_value
        , status
        , symbolisin
        , listedshare
        , totallistingqtty
        , marketid
        , boardid
        , productgrpid
        , productid
        , tradingtime
        , fundtype
        , openinterest
        , firsttradingdate
        , lasttradingdate
        , underlyingsymbol
        , issuername
        , coveredwarranttype
        , maturitydate
        , exerciseprice
        , exerciseratio
        , settlementprice
        , maturitymonthyear
        , listingdate
        , contractmultiplier
        , putorcall
        , exercisestyle
        , couponrate
        , yield
        , issuedate
        , sequence
        , foreignbuyval
        , foreignsellval
        , prior_price
        , openinterestchange
        , priceone
        , pricetwo
        , totalbuyvol
        , totalsellvol
        , vwap
    FROM {{ ft_ref('ft_ods_mdds_jad_stockinfor') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    -- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
)


SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_STOCKINFOR', "historyid") }} AS security_trading_snpst_id,
    CAST(historyid AS string)                                               AS security_trading_snpst_code,
    CAST('MDDS_JAD_STOCKINFOR' AS string)                                   AS src_stm_code,
    CAST(symbol AS string)                                                  AS ticker_symbol,
    CAST(tradingdate AS date)                                               AS trading_dt,
    CAST(fullname AS string)                                                AS full_nm,
    CAST(stockid AS string)                                                 AS security_id,
    CAST(kid AS string)                                                     AS jadapter_id,
    CAST(stocktype AS string)                                               AS stock_tp_code,
    CAST(floorcode AS string)                                               AS floor_code,
    CAST(tradingsessionid AS string)                                        AS trading_session_status_code,
    CAST(lastcolor AS string)                                               AS trade_direction_code,
    CAST(symbolstatuscode AS string)                                        AS symbol_status_code,
    CAST(ceiling AS decimal(23,2))                                          AS ceiling_price,
    CAST(floor AS decimal(23,2))                                            AS floor_price,
    CAST(reference AS decimal(23,2))                                        AS reference_price,
    CAST(closeprice AS decimal(23,2))                                       AS close_price,
    CAST(closevol AS decimal(23,2))                                                AS close_vol,
    CAST(change AS decimal(23,2))                                           AS price_change,
    CAST(open AS decimal(23,2))                                             AS open_price,
    CAST(high AS decimal(23,2))                                             AS high_price,
    CAST(low AS decimal(23,2))                                              AS low_price,
    CAST(averageprice AS decimal(23,2))                                     AS average_price,
    CAST(bidprice1 AS decimal(23,2))                                        AS bid_price_1,
    CAST(bidvol1 AS decimal(23,2))                                                 AS bid_vol_1,
    CAST(bidprice2 AS decimal(23,2))                                        AS bid_price_2,
    CAST(bidvol2 AS decimal(23,2))                                                 AS bid_vol_2,
    CAST(bidprice3 AS decimal(23,2))                                        AS bid_price_3,
    CAST(bidvol3 AS decimal(23,2))                                                 AS bid_vol_3,
    CAST(offerprice1 AS decimal(23,2))                                      AS offer_price_1,
    CAST(offervol1 AS decimal(23,2))                                               AS offer_vol_1,
    CAST(offerprice2 AS decimal(23,2))                                      AS offer_price_2,
    CAST(offervol2 AS decimal(23,2))                                               AS offer_vol_2,
    CAST(offerprice3 AS decimal(23,2))                                      AS offer_price_3,
    CAST(offervol3 AS decimal(23,2))                                               AS offer_vol_3,
    CAST(totaltrading AS decimal(23,2))                                            AS total_trading_vol,
    CAST(totaltradingvalue AS decimal(23,2))                                AS total_trading_val,
    CAST(total_offer_qtty AS decimal(23,2))                                        AS total_offer_vol,
    CAST(total_bid_qtty AS decimal(23,2))                                          AS total_bid_vol,
    CAST(foreignbuy AS decimal(23,2))                                              AS foreign_buy_vol,
    CAST(foreignsell AS decimal(23,2))                                             AS foreign_sell_vol,
    CAST(foreignremain AS decimal(23,2))                                           AS foreign_remain_vol,
    CAST(foreignroom AS decimal(23,2))                                             AS foreign_room_vol,
    CAST(pt_match_qtty AS decimal(23,2))                                           AS pt_match_vol,
    CAST(pt_match_price AS decimal(23,2))                                   AS pt_match_price,
    CAST(pt_total_traded_qtty AS decimal(23,2))                                    AS pt_total_traded_vol,
    CAST(pt_total_traded_value AS decimal(23,2))                            AS pt_total_traded_val,
    CAST(status AS string)                                                  AS security_event_status_code,
    CAST(symbolisin AS string)                                              AS isin_code,
    CAST(listedshare AS decimal(23,2))                                             AS listed_share_count,
    CAST(totallistingqtty AS decimal(23,2))                                        AS total_listing_vol,
    CAST(marketid AS string)                                                AS market_id,
    CAST(boardid AS string)                                                 AS board_id,
    CAST(productgrpid AS string)                                            AS product_group_id,
    CAST(productid AS string)                                               AS product_id,
    CAST(tradingtime AS string)                                             AS trading_time,
    CAST(fundtype AS string)                                                AS fund_tp_code,
    CAST(openinterest AS decimal(23,2))                                            AS open_interest,
    CAST(to_date(firsttradingdate, 'dd/MM/yyyy') AS date)                   AS first_trading_dt,
    CAST(COALESCE(to_date(lasttradingdate, 'dd/MM/yyyy'), to_date(lasttradingdate, 'yyyyMMdd')) AS date) AS last_trading_dt,
    CAST(underlyingsymbol AS string)                                        AS underlying_symbol,
    CAST(issuername AS string)                                              AS issuer_nm,
    CAST(coveredwarranttype AS string)                                      AS covered_warrant_tp_code,
    CAST(COALESCE(to_date(maturitydate, 'dd/MM/yyyy'), to_date(maturitydate, 'yyyyMMdd')) AS date) AS maturity_dt,
    CAST(exerciseprice AS decimal(23,2))                                    AS exercise_price,
    CAST(exerciseratio AS string)                                           AS exercise_ratio,
    CAST(settlementprice AS decimal(23,2))                                  AS settlement_price,
    CAST(maturitymonthyear AS string)                                       AS maturity_month_year,
    CAST(to_date(listingdate, 'yyyyMMdd') AS date)                            AS listing_dt,
    CAST(contractmultiplier AS string)                                      AS contract_multiplier,
    CAST(putorcall AS string)                                               AS put_or_call_code,
    CAST(exercisestyle AS string)                                           AS exercise_style_code,
    CAST(couponrate AS decimal(8,5))                                        AS coupon_rate,
    CASE WHEN CAST(yield AS decimal(18,5)) IN (-9999, -9999.9999) THEN NULL
         ELSE CAST(yield AS decimal(8,5)) END                               AS yield,
    CAST(COALESCE(to_date(issuedate, 'dd/MM/yyyy'), to_date(issuedate, 'yyyyMMdd')) AS date) AS issue_dt,
    CAST(sequence AS bigint)                                                AS sequence,
    CAST(foreignbuyval AS decimal(23,2))                                    AS foreign_buy_val,
    CAST(foreignsellval AS decimal(23,2))                                   AS foreign_sell_val,
    CAST(prior_price AS decimal(23,2))                                      AS prior_price,
    CAST(openinterestchange AS decimal(23,2))                                      AS open_interest_change,
    CAST(priceone AS decimal(23,2))                                         AS price_one,
    CAST(pricetwo AS decimal(23,2))                                         AS price_two,
    CAST(totalbuyvol AS decimal(23,2))                                             AS total_buy_vol,
    CAST(totalsellvol AS decimal(23,2))                                            AS total_sell_vol,
    CAST(concat(CAST(tradingdate AS string), ' ', tradingtime) AS timestamp) AS trading_tms,
    CAST(vwap AS decimal(23,2))                                                    AS vol_weighted_average_price,
    CAST(tradingdate AS date)                                               AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] ngay giao dich cua dong (ft tu gan, macro ft khong them)
FROM ja_st