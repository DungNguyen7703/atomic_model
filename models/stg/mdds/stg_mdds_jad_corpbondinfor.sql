/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_corpbondinfor
* Program name: Staging MDDS.JAD_CORPBONDINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(symbol AS string)                  AS symbol
    , CAST(fullname AS string)              AS fullname
    , to_date(tradingdate, 'dd/MM/yyyy')    AS tradingdate
    , CAST(floorcode AS string)             AS floorcode
    , CAST(stocktype AS string)             AS stocktype
    , CAST(ceiling AS float)                AS ceiling
    , CAST(floor AS float)                  AS floor
    , CAST(reference AS float)              AS reference
    , CAST(closeprice AS float)             AS closeprice
    , CAST(closevol AS float)               AS closevol
    , CAST(change AS float)                 AS change
    , CAST(totaltrading AS double)          AS totaltrading
    , CAST(totaltradingvalue AS double)     AS totaltradingvalue
    , CAST(averageprice AS float)           AS averageprice
    , CAST(open AS float)                   AS open
    , CAST(high AS float)                   AS high
    , CAST(low AS float)                    AS low
    , CAST(foreignremain AS float)          AS foreignremain
    , CAST(pt_match_qtty AS double)         AS pt_match_qtty
    , CAST(pt_match_price AS double)        AS pt_match_price
    , CAST(pt_total_traded_qtty AS double)  AS pt_total_traded_qtty
    , CAST(pt_total_traded_value AS double) AS pt_total_traded_value
    , CAST(tradingsessionid AS string)      AS tradingsessionid
    , CAST(issuername AS string)            AS issuername
    , CAST(maturitydate AS string)          AS maturitydate
    , CAST(totallistingqtty AS double)      AS totallistingqtty
    , CAST(bond_period AS string)           AS bond_period
    , CAST(period_unit AS string)           AS period_unit
    , CAST(period_remain AS string)         AS period_remain
    , CAST(interest_type AS string)         AS interest_type
    , CAST(interest_period AS string)       AS interest_period
    , CAST(interest_period_unit AS string)  AS interest_period_unit
    , CAST(interest_coupon_type AS string)  AS interest_coupon_type
    , CAST(interestrate_type AS string)     AS interestrate_type
    , CAST(interest_payment_type AS string) AS interest_payment_type
    , CAST(interest_rate AS string)         AS interest_rate
    , CAST(pt_bestbidqtty AS double)        AS pt_bestbidqtty
    , CAST(pt_bestbidprice AS double)       AS pt_bestbidprice
    , CAST(pt_bestofferqtty AS double)      AS pt_bestofferqtty
    , CAST(pt_bestofferprice AS double)     AS pt_bestofferprice
    , CAST(pt_totalbidqtty AS double)       AS pt_totalbidqtty
    , CAST(pt_totalofferqtty AS double)     AS pt_totalofferqtty
    , CAST(pt_maxqtty AS double)            AS pt_maxqtty
    , CAST(pt_maxprice AS double)           AS pt_maxprice
    , CAST(pt_minqtty AS double)            AS pt_minqtty
    , CAST(pt_minprice AS double)           AS pt_minprice
    , CAST(issuedate AS string)             AS issuedate
    , CAST(characteristics AS string)       AS characteristics
    , CAST(securitytradingstatus AS string) AS securitytradingstatus
    , CAST(tradsesstatus AS string)         AS tradsesstatus
    , CAST(parvalue AS string)              AS parvalue
    , CAST(tradingtime AS string)           AS tradingtime
FROM {{ source('source_mdds', 'raw_jad_corpbondinfor') }}
WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')