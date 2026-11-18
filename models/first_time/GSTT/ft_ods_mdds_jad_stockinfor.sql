-- [FIRST-TIME] ft_ods_mdds_jad_stockinfor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mdds_jad_stockinfor (config ft_target='jad_stockinfor', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_stockinfor
* Program name: ODS MDDS.JAD_STOCKINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-08		tuan.nguyenvanb		Bo sung cot VWAP (JAD_STOCKINFOR; BA: bo cac cot duoi M1)
* 2026-10-12		tuan.nguyenvanb		Bo sung cot SEQUENCE (JAD_STOCKINFOR) cuoi SELECT, sau vwap - phan xu ban tin trung trading_tms.
* 2026-10-12		tuan.nguyenvanb		[LLD GSTT d1e944ee] Bo sung FOREIGNBUYVAL, FOREIGNSELLVAL (sau sequence) cho atomic foreign_buy_val/foreign_sell_val.
* 2026-10-16		tuan.nguyenvanb		Dong bo SELECT voi ods_mdds_jad_stockinfor (85 cot theo DDL bang that): them prior_price, openinterestchange,
*                                       priceone, pricetwo, totalbuyvol, totalsellvol va dung thu tu cot (macro ft ghi theo VI TRI).
*--------------------------------------------------------------------*
*/

SELECT
    historyid
    , kid
    , symbol
    , stockid
    , fullname
    , tradingdate
    , floorcode
    , stocktype
    , ceiling
    , floor
    , reference
    , bidprice3
    , bidvol3
    , bidprice2
    , bidvol2
    , bidprice1
    , bidvol1
    , closeprice
    , closevol
    , change
    , offerprice1
    , offervol1
    , offerprice2
    , offervol2
    , offerprice3
    , offervol3
    , totaltrading
    , totaltradingvalue
    , averageprice
    , open
    , high
    , low
    , foreignbuy
    , foreignsell
    , foreignremain
    , foreignroom
    , total_offer_qtty
    , total_bid_qtty
    , pt_match_qtty
    , pt_match_price
    , pt_total_traded_qtty
    , pt_total_traded_value
    , status
    , tradingsessionid
    , openinterest
    , firsttradingdate
    , lasttradingdate
    , underlyingsymbol
    , issuername
    , coveredwarranttype
    , maturitydate
    , exerciseprice
    , exerciseratio
    , listedshare
    , fundtype
    , totallistingqtty
    , symbolstatuscode
    , symbolisin
    , marketid
    , boardid
    , productgrpid
    , productid
    , lastcolor
    , tradingtime
    , CAST(concat(CAST(tradingdate AS string), ' ', tradingtime) AS timestamp) AS tradingtimestamp
    , couponrate
    , yield
    , issuedate
    , settlementprice
    , maturitymonthyear
    , listingdate
    , contractmultiplier
    , putorcall
    , exercisestyle
    , prior_price
    , foreignbuyval
    , foreignsellval
    , openinterestchange
    , priceone
    , pricetwo
    , sequence
    , totalbuyvol
    , totalsellvol
    , vwap
FROM {{ ft_ref('ft_stg_mdds_jad_stockinfor') }}
-- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]


