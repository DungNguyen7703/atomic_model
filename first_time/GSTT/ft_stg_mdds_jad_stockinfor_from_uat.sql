-- [FIRST-TIME] ft_stg_mdds_jad_stockinfor_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_STOCKINFOR_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_stockinfor (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_stockinfor_from_uat
* Program name: Staging MDDS.JAD_STOCKINFOR (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_STOCKINFOR_UAT) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_stockinfor (83 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(historyid AS string)                    AS historyid
    , CAST(coveredwarranttype AS string)           AS coveredwarranttype
    , CAST(exerciseprice AS string)                AS exerciseprice
    , CAST(exerciseratio AS string)                AS exerciseratio
    , CAST(floorcode AS string)                    AS floorcode
    , CAST(fullname AS string)                     AS fullname
    , CAST(fundtype AS string)                     AS fundtype
    , CAST(issuername AS string)                   AS issuername
    , CAST(listedshare AS string)                  AS listedshare
    , CAST(maturitydate AS string)                 AS maturitydate
    , CAST(prior_price AS double)                  AS prior_price
    , CAST(pt_match_price AS decimal(19,0))        AS pt_match_price
    , CAST(pt_match_qtty AS decimal(19,0))         AS pt_match_qtty
    , CAST(pt_total_traded_qtty AS decimal(19,0))  AS pt_total_traded_qtty
    , CAST(pt_total_traded_value AS double)        AS pt_total_traded_value
    , CAST(status AS string)                       AS status
    , CAST(stockid AS string)                      AS stockid
    , CAST(stocktype AS string)                    AS stocktype
    , CAST(total_bid_qtty AS decimal(19,0))        AS total_bid_qtty
    , CAST(total_offer_qtty AS decimal(19,0))      AS total_offer_qtty
    , CAST(totallistingqtty AS string)             AS totallistingqtty
    , CAST(averageprice AS double)                 AS averageprice
    , CAST(bidprice1 AS double)                    AS bidprice1
    , CAST(bidprice2 AS double)                    AS bidprice2
    , CAST(bidprice3 AS double)                    AS bidprice3
    , CAST(bidvol1 AS decimal(19,0))               AS bidvol1
    , CAST(bidvol2 AS decimal(19,0))               AS bidvol2
    , CAST(bidvol3 AS decimal(19,0))               AS bidvol3
    , CAST(boardid AS string)                      AS boardid
    , CAST(ceiling AS double)                      AS ceiling
    , CAST(change AS double)                       AS change
    , CAST(closeprice AS double)                   AS closeprice
    , CAST(closevol AS decimal(19,0))              AS closevol
    , CAST(contractmultiplier AS string)           AS contractmultiplier
    , CAST(couponrate AS string)                   AS couponrate
    , CAST(exercisestyle AS string)                AS exercisestyle
    , CAST(firsttradingdate AS string)             AS firsttradingdate
    , CAST(floor AS double)                        AS floor
    , CAST(foreignbuy AS decimal(19,0))            AS foreignbuy
    , CAST(foreignbuyval AS double)                AS foreignbuyval
    , CAST(foreignremain AS decimal(19,0))         AS foreignremain
    , CAST(foreignroom AS decimal(19,0))           AS foreignroom
    , CAST(foreignsell AS decimal(19,0))           AS foreignsell
    , CAST(foreignsellval AS double)               AS foreignsellval
    , CAST(high AS double)                         AS high
    , CAST(issuedate AS string)                    AS issuedate
    , CAST(kid AS string)                          AS kid
    , CAST(lastcolor AS string)                    AS lastcolor
    , CAST(lasttradingdate AS string)              AS lasttradingdate
    , CAST(listingdate AS string)                  AS listingdate
    , CAST(low AS double)                          AS low
    , CAST(marketid AS string)                     AS marketid
    , CAST(maturitymonthyear AS string)            AS maturitymonthyear
    , CAST(offerprice1 AS double)                  AS offerprice1
    , CAST(offerprice2 AS double)                  AS offerprice2
    , CAST(offerprice3 AS double)                  AS offerprice3
    , CAST(offervol1 AS decimal(19,0))             AS offervol1
    , CAST(offervol2 AS decimal(19,0))             AS offervol2
    , CAST(offervol3 AS decimal(19,0))             AS offervol3
    , CAST(open AS double)                         AS open
    , CAST(openinterest AS string)                 AS openinterest
    , CAST(openinterestchange AS string)           AS openinterestchange
    , CAST(priceone AS string)                     AS priceone
    , CAST(pricetwo AS string)                     AS pricetwo
    , CAST(productgrpid AS string)                 AS productgrpid
    , CAST(productid AS string)                    AS productid
    , CAST(putorcall AS string)                    AS putorcall
    , CAST(reference AS double)                    AS reference
    , CAST(sequence AS bigint)                     AS sequence
    , CAST(settlementprice AS string)              AS settlementprice
    , CAST(symbol AS string)                       AS symbol
    , CAST(symbolisin AS string)                   AS symbolisin
    , CAST(symbolstatuscode AS string)             AS symbolstatuscode
    , CAST(totalbuyvol AS decimal(19,0))           AS totalbuyvol
    , CAST(totalsellvol AS decimal(19,0))          AS totalsellvol
    , CAST(totaltrading AS decimal(19,0))          AS totaltrading
    , CAST(totaltradingvalue AS double)            AS totaltradingvalue
    , CAST(tradingsessionid AS string)             AS tradingsessionid
    , CAST(tradingtime AS string)                  AS tradingtime
    , CAST(tradingdate AS string)                  AS tradingdate
    , CAST(underlyingsymbol AS string)             AS underlyingsymbol
    , CAST(yield AS string)                        AS yield
    , CAST(vwap AS double)                         AS vwap
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_stockinfor_uat') }}