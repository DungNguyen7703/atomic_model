{{
    config(
        materialized = 'view',
        schema = var('stg_mdds_schema'),
        alias = 'jad_stockinfor_to_oracle_v',
        post_hook = [
            "INSERT INTO {{ var('src_mdds_schema') }}.JAD_STOCKINFOR_UAT (historyid, kid, symbol, stockid, fullname, tradingdate, floorcode, stocktype, ceiling, floor, reference, bidprice3, bidvol3, bidprice2, bidvol2, bidprice1, bidvol1, closeprice, closevol, change, offerprice1, offervol1, offerprice2, offervol2, offerprice3, offervol3, totaltrading, totaltradingvalue, averageprice, open, high, low, foreignbuy, foreignsell, foreignremain, foreignroom, total_offer_qtty, total_bid_qtty, pt_match_qtty, pt_match_price, pt_total_traded_qtty, pt_total_traded_value, status, tradingsessionid, openinterest, firsttradingdate, lasttradingdate, underlyingsymbol, issuername, coveredwarranttype, maturitydate, exerciseprice, exerciseratio, listedshare, fundtype, totallistingqtty, symbolstatuscode, symbolisin, marketid, boardid, productgrpid, productid, lastcolor, tradingtime, couponrate, yield, issuedate, settlementprice, maturitymonthyear, listingdate, contractmultiplier, putorcall, exercisestyle, prior_price, foreignbuyval, foreignsellval, openinterestchange, priceone, pricetwo, sequence, totalbuyvol, totalsellvol, vwap) SELECT /*+ REPARTITION(256) */ * FROM {{ this }}"
        ],
        tags = ['layer_staging', 'domain_mdds', 'push_to_oracle']
    )
}}

/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_stockinfor_to_oracle
* Program name: Day MDDS.JAD_STOCKINFOR tu staging UAT (Iceberg) vao Oracle oracle_viettel_2.UBCK_PROD.JAD_STOCKINFOR_UAT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Chieu nguoc voi stg_mdds_jad_stockinfor: doc FULL staging.uat_MDDS_stg.jad_stockinfor (khong loc etl_date) -> INSERT vao Oracle UBCK_PROD.. tradingdate doi lai dd/MM/yyyy (varchar2). Hint REPARTITION(8) de ghi JDBC song song 8 ket noi. Khong gom ds_etl_pcs_tms. Bang Oracle UBCK_PROD phai TRUNCATE truoc khi chay lai (hook chi INSERT).
*--------------------------------------------------------------------*
*/

SELECT
    historyid
    , kid
    , symbol
    , stockid
    , fullname
    , date_format(tradingdate, 'dd/MM/yyyy') AS tradingdate
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
FROM {{ source('source_mdds_uat_stg', 'raw_jad_stockinfor') }}
