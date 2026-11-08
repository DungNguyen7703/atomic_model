/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_stockinfor
* Program name: Staging MDDS.JAD_STOCKINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-08		tuan.nguyenvanb		Bo sung cot VWAP tu nguon JAD_STOCKINFOR (BA: bo cac cot duoi M1: OPEN_M1/HIGH_M1/LOW_M1)
* 2026-10-12		duc.luxuan			Bo cast/bien doi theo nguyen tac staging: VARCHAR2 lay nguyen, NUMBER(19,0) -> bigint,
*									FLOAT -> decimal(38,8) (truoc la double, mat chinh xac sau 15-17 chu so).
*									Giu trinh tu cot theo bang Iceberg hien tai (macro INSERT theo vi tri).
*									Khong lay OPEN_M1/HIGH_M1/LOW_M1 (nguon Oracle se bo).
*									Ngoai le: TRADINGDATE (varchar2 dd/MM/yyyy) to_date sang date - partition key.
*--------------------------------------------------------------------*
*/
{% set etl_date = modules.datetime.datetime.strptime(var("etl_date"), "%Y-%m-%d").strftime("%d/%m/%Y") %}

SELECT
    historyid
    , kid
    , symbol
    , stockid
    , fullname
    , to_date(tradingdate, 'dd/MM/yyyy')    AS tradingdate
    , floorcode
    , stocktype
    , CAST(ceiling AS decimal(38,8))        AS ceiling
    , CAST(floor AS decimal(38,8))          AS floor
    , CAST(reference AS decimal(38,8))      AS reference
    , CAST(bidprice3 AS decimal(38,8))      AS bidprice3
    , CAST(bidvol3 AS bigint)               AS bidvol3
    , CAST(bidprice2 AS decimal(38,8))      AS bidprice2
    , CAST(bidvol2 AS bigint)               AS bidvol2
    , CAST(bidprice1 AS decimal(38,8))      AS bidprice1
    , CAST(bidvol1 AS bigint)               AS bidvol1
    , CAST(closeprice AS decimal(38,8))     AS closeprice
    , CAST(closevol AS bigint)              AS closevol
    , CAST(change AS decimal(38,8))         AS change
    , CAST(offerprice1 AS decimal(38,8))    AS offerprice1
    , CAST(offervol1 AS bigint)             AS offervol1
    , CAST(offerprice2 AS decimal(38,8))    AS offerprice2
    , CAST(offervol2 AS bigint)             AS offervol2
    , CAST(offerprice3 AS decimal(38,8))    AS offerprice3
    , CAST(offervol3 AS bigint)             AS offervol3
    , CAST(totaltrading AS bigint)          AS totaltrading
    , CAST(totaltradingvalue AS decimal(38,8)) AS totaltradingvalue
    , CAST(averageprice AS decimal(38,8))   AS averageprice
    , CAST(open AS decimal(38,8))           AS open
    , CAST(high AS decimal(38,8))           AS high
    , CAST(low AS decimal(38,8))            AS low
    , CAST(foreignbuy AS bigint)            AS foreignbuy
    , CAST(foreignsell AS bigint)           AS foreignsell
    , CAST(foreignremain AS bigint)         AS foreignremain
    , CAST(foreignroom AS bigint)           AS foreignroom
    , CAST(total_offer_qtty AS bigint)      AS total_offer_qtty
    , CAST(total_bid_qtty AS bigint)        AS total_bid_qtty
    , CAST(pt_match_qtty AS bigint)         AS pt_match_qtty
    , CAST(pt_match_price AS bigint)        AS pt_match_price
    , CAST(pt_total_traded_qtty AS bigint)  AS pt_total_traded_qtty
    , CAST(pt_total_traded_value AS decimal(38,8)) AS pt_total_traded_value
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
    , CAST(prior_price AS decimal(38,8))    AS prior_price
    , CAST(foreignbuyval AS decimal(38,8))  AS foreignbuyval
    , CAST(foreignsellval AS decimal(38,8)) AS foreignsellval
    , openinterestchange
    , priceone
    , pricetwo
    , CAST(sequence AS bigint)              AS sequence
    , CAST(totalbuyvol AS bigint)           AS totalbuyvol
    , CAST(totalsellvol AS bigint)          AS totalsellvol
    , CAST(vwap AS decimal(38,8))           AS vwap
FROM {{ source('source_mdds', 'raw_jad_stockinfor') }}
WHERE tradingdate = '{{ etl_date }}'