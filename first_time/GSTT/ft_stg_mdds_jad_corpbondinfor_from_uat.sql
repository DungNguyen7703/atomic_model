-- [FIRST-TIME] ft_stg_mdds_jad_corpbondinfor_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_CORPBONDINFOR_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_corpbondinfor (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_corpbondinfor_from_uat
* Program name: Staging MDDS.JAD_CORPBONDINFOR (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_CORPBONDINFOR_UAT) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_corpbondinfor (52 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(symbol AS string)                       AS symbol
    , CAST(bond_period AS string)                  AS bond_period
    , CAST(floorcode AS string)                    AS floorcode
    , CAST(fullname AS string)                     AS fullname
    , CAST(interestrate_type AS string)            AS interestrate_type
    , CAST(interest_coupon_type AS string)         AS interest_coupon_type
    , CAST(interest_payment_type AS string)        AS interest_payment_type
    , CAST(interest_period AS string)              AS interest_period
    , CAST(interest_period_unit AS string)         AS interest_period_unit
    , CAST(interest_rate AS string)                AS interest_rate
    , CAST(interest_type AS string)                AS interest_type
    , CAST(issuedate AS string)                    AS issuedate
    , CAST(issuername AS string)                   AS issuername
    , CAST(maturitydate AS string)                 AS maturitydate
    , CAST(period_remain AS string)                AS period_remain
    , CAST(period_unit AS string)                  AS period_unit
    , CAST(pt_bestbidprice AS double)              AS pt_bestbidprice
    , CAST(pt_bestbidqtty AS double)               AS pt_bestbidqtty
    , CAST(pt_bestofferprice AS double)            AS pt_bestofferprice
    , CAST(pt_bestofferqtty AS double)             AS pt_bestofferqtty
    , CAST(pt_match_price AS double)               AS pt_match_price
    , CAST(pt_match_qtty AS double)                AS pt_match_qtty
    , CAST(pt_maxprice AS double)                  AS pt_maxprice
    , CAST(pt_maxqtty AS double)                   AS pt_maxqtty
    , CAST(pt_minprice AS double)                  AS pt_minprice
    , CAST(pt_minqtty AS double)                   AS pt_minqtty
    , CAST(pt_total_traded_qtty AS double)         AS pt_total_traded_qtty
    , CAST(pt_total_traded_value AS double)        AS pt_total_traded_value
    , CAST(pt_totalbidqtty AS double)              AS pt_totalbidqtty
    , CAST(pt_totalofferqtty AS double)            AS pt_totalofferqtty
    , CAST(stocktype AS string)                    AS stocktype
    , CAST(totallistingqtty AS double)             AS totallistingqtty
    , CAST(averageprice AS float)                  AS averageprice
    , CAST(ceiling AS float)                       AS ceiling
    , CAST(change AS float)                        AS change
    , CAST(characteristics AS string)              AS characteristics
    , CAST(closeprice AS float)                    AS closeprice
    , CAST(closevol AS float)                      AS closevol
    , CAST(floor AS float)                         AS floor
    , CAST(foreignremain AS float)                 AS foreignremain
    , CAST(high AS float)                          AS high
    , CAST(low AS float)                           AS low
    , CAST(open AS float)                          AS open
    , CAST(parvalue AS string)                     AS parvalue
    , CAST(reference AS float)                     AS reference
    , CAST(securitytradingstatus AS string)        AS securitytradingstatus
    , CAST(totaltrading AS double)                 AS totaltrading
    , CAST(totaltradingvalue AS double)            AS totaltradingvalue
    , CAST(tradsesstatus AS string)                AS tradsesstatus
    , CAST(tradingsessionid AS string)             AS tradingsessionid
    , CAST(tradingtime AS string)                  AS tradingtime
    , CAST(tradingdate AS string)                  AS tradingdate
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_corpbondinfor_uat') }}