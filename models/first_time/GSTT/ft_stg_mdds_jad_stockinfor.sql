-- [FIRST-TIME] ft_stg_mdds_jad_stockinfor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_stockinfor (config ft_target='jad_stockinfor', macro macros/first_time).
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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(historyid AS string)               AS historyid
    , CAST(kid AS string)                   AS kid
    , CAST(symbol AS string)                AS symbol
    , CAST(stockid AS string)               AS stockid
    , CAST(fullname AS string)              AS fullname
    , to_date(tradingdate, 'dd/MM/yyyy')    AS tradingdate
    , CAST(floorcode AS string)             AS floorcode
    , CAST(stocktype AS string)             AS stocktype
    , CAST(ceiling AS double)               AS ceiling
    , CAST(floor AS double)                 AS floor
    , CAST(reference AS double)             AS reference
    , CAST(bidprice3 AS double)             AS bidprice3
    , CAST(bidvol3 AS bigint)               AS bidvol3
    , CAST(bidprice2 AS double)             AS bidprice2
    , CAST(bidvol2 AS bigint)               AS bidvol2
    , CAST(bidprice1 AS double)             AS bidprice1
    , CAST(bidvol1 AS bigint)               AS bidvol1
    , CAST(closeprice AS double)            AS closeprice
    , CAST(closevol AS bigint)              AS closevol
    , CAST(change AS double)                AS change
    , CAST(offerprice1 AS double)           AS offerprice1
    , CAST(offervol1 AS bigint)             AS offervol1
    , CAST(offerprice2 AS double)           AS offerprice2
    , CAST(offervol2 AS bigint)             AS offervol2
    , CAST(offerprice3 AS double)           AS offerprice3
    , CAST(offervol3 AS bigint)             AS offervol3
    , CAST(totaltrading AS bigint)          AS totaltrading
    , CAST(totaltradingvalue AS double)     AS totaltradingvalue
    , CAST(averageprice AS double)          AS averageprice
    , CAST(open AS double)                  AS open
    , CAST(high AS double)                  AS high
    , CAST(low AS double)                   AS low
    , CAST(foreignbuy AS bigint)            AS foreignbuy
    , CAST(foreignsell AS bigint)           AS foreignsell
    , CAST(foreignremain AS bigint)         AS foreignremain
    , CAST(foreignroom AS bigint)           AS foreignroom
    , CAST(total_offer_qtty AS bigint)      AS total_offer_qtty
    , CAST(total_bid_qtty AS bigint)        AS total_bid_qtty
    , CAST(pt_match_qtty AS bigint)         AS pt_match_qtty
    , CAST(pt_match_price AS bigint)        AS pt_match_price
    , CAST(pt_total_traded_qtty AS bigint)  AS pt_total_traded_qtty
    , CAST(pt_total_traded_value AS double) AS pt_total_traded_value
    , CAST(status AS string)                AS status
    , CAST(tradingsessionid AS string)      AS tradingsessionid
    , CAST(openinterest AS string)          AS openinterest
    , CAST(firsttradingdate AS string)      AS firsttradingdate
    , CAST(lasttradingdate AS string)       AS lasttradingdate
    , CAST(underlyingsymbol AS string)      AS underlyingsymbol
    , CAST(issuername AS string)            AS issuername
    , CAST(coveredwarranttype AS string)    AS coveredwarranttype
    , CAST(maturitydate AS string)          AS maturitydate
    , CAST(exerciseprice AS string)         AS exerciseprice
    , CAST(exerciseratio AS string)         AS exerciseratio
    , CAST(listedshare AS string)           AS listedshare
    , CAST(fundtype AS string)              AS fundtype
    , CAST(totallistingqtty AS string)      AS totallistingqtty
    , CAST(symbolstatuscode AS string)      AS symbolstatuscode
    , CAST(symbolisin AS string)            AS symbolisin
    , CAST(marketid AS string)              AS marketid
    , CAST(boardid AS string)               AS boardid
    , CAST(productgrpid AS string)          AS productgrpid
    , CAST(productid AS string)             AS productid
    , CAST(lastcolor AS string)             AS lastcolor
    , CAST(tradingtime AS string)           AS tradingtime
    , CAST(couponrate AS string)            AS couponrate
    , CAST(yield AS string)                 AS yield
    , CAST(issuedate AS string)             AS issuedate
    , CAST(settlementprice AS string)       AS settlementprice
    , CAST(maturitymonthyear AS string)     AS maturitymonthyear
    , CAST(listingdate AS string)           AS listingdate
    , CAST(contractmultiplier AS string)    AS contractmultiplier
    , CAST(putorcall AS string)             AS putorcall
    , CAST(exercisestyle AS string)         AS exercisestyle
    , CAST(prior_price AS double)           AS prior_price
    , CAST(foreignbuyval AS double)         AS foreignbuyval
    , CAST(foreignsellval AS double)        AS foreignsellval
    , CAST(openinterestchange AS string)    AS openinterestchange
    , CAST(priceone AS string)              AS priceone
    , CAST(pricetwo AS string)              AS pricetwo
    , CAST(sequence AS bigint)              AS sequence
    , CAST(totalbuyvol AS bigint)           AS totalbuyvol
    , CAST(totalsellvol AS bigint)          AS totalsellvol
    , CAST(vwap AS double)                  AS vwap
FROM {{ source('source_mdds', 'raw_jad_stockinfor') }}
-- [BACKFILL-UAT-ORIG] WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]