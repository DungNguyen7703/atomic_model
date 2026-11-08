/*
*--------------------------------------------------------------------*
* Program code: atm_corporate_bond_trading_snapshot
* Program name: Atomic Corporate Bond Trading Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ja_co AS (
    SELECT
        symbol
        , tradingdate
        , fullname
        , tradingtime
        , floorcode
        , stocktype
        , tradingsessionid
        , securitytradingstatus
        , tradsesstatus
        , period_unit
        , interest_period_unit
        , interest_coupon_type
        , interestrate_type
        , interest_type
        , interest_payment_type
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
        , totaltrading
        , totaltradingvalue
        , totallistingqtty
        , foreignremain
        , pt_match_qtty
        , pt_match_price
        , pt_total_traded_qtty
        , pt_total_traded_value
        , pt_bestbidqtty
        , pt_bestbidprice
        , pt_bestofferqtty
        , pt_bestofferprice
        , pt_totalbidqtty
        , pt_totalofferqtty
        , pt_maxqtty
        , pt_maxprice
        , pt_minqtty
        , pt_minprice
        , issuername
        , issuedate
        , maturitydate
        , parvalue
        , bond_period
        , period_remain
        , interest_period
        , interest_rate
        , characteristics
    FROM {{ ref('ods_mdds_jad_corpbondinfor') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_CORPBONDINFOR', "ja_co.symbol") }} AS corporate_bond_trading_snpst_id
    , CAST(ja_co.symbol AS string)                                                AS corporate_bond_trading_snpst_code
    , CAST('MDDS_JAD_CORPBONDINFOR' AS string)                                 AS src_stm_code
    , CAST(ja_co.symbol AS string)                                             AS symbol
    , CAST(ja_co.tradingdate AS date)                                          AS trading_dt
    , CAST(ja_co.fullname AS string)                                           AS bond_full_nm
    , CAST(ja_co.tradingtime AS string)                                        AS trading_time
    , CAST(ja_co.floorcode AS string)                                          AS floor_code
    , CAST(ja_co.stocktype AS string)                                          AS stock_tp_code
    , CAST(ja_co.tradingsessionid AS string)                                   AS trading_session_status_code
    , CAST(ja_co.securitytradingstatus AS string)                              AS security_trading_status_code
    , CAST(ja_co.tradsesstatus AS string)                                      AS trading_session_status_2_code
    , CAST(ja_co.period_unit AS string)                                        AS period_unit_code
    , CAST(ja_co.interest_period_unit AS string)                               AS interest_period_unit_code
    , CAST(ja_co.interest_coupon_type AS string)                               AS coupon_tp_code
    , CAST(ja_co.interestrate_type AS string)                                  AS interest_rate_tp_code
    , CAST(ja_co.interest_type AS string)                                      AS interest_tp_code
    , CAST(ja_co.interest_payment_type AS string)                              AS interest_payment_tp_code
    , CAST(ja_co.ceiling AS decimal(23,2))                                     AS ceiling_price
    , CAST(ja_co.floor AS decimal(23,2))                                       AS floor_price
    , CAST(ja_co.reference AS decimal(23,2))                                   AS reference_price
    , CAST(ja_co.closeprice AS decimal(23,2))                                  AS close_price
    , CAST(ja_co.closevol AS int)                                              AS close_vol
    , CAST(ja_co.change AS decimal(23,2))                                      AS price_change
    , CAST(ja_co.open AS decimal(23,2))                                        AS open_price
    , CAST(ja_co.high AS decimal(23,2))                                        AS high_price
    , CAST(ja_co.low AS decimal(23,2))                                         AS low_price
    , CAST(ja_co.averageprice AS decimal(23,2))                                AS average_price
    , CAST(ja_co.totaltrading AS int)                                          AS total_trading_vol
    , CAST(ja_co.totaltradingvalue AS decimal(23,2))                           AS total_trading_val
    , CAST(ja_co.totallistingqtty AS int)                                      AS total_listing_vol
    , CAST(ja_co.foreignremain AS int)                                         AS foreign_remain_vol
    , CAST(ja_co.pt_match_qtty AS int)                                         AS pt_match_vol
    , CAST(ja_co.pt_match_price AS decimal(23,2))                              AS pt_match_price
    , CAST(ja_co.pt_total_traded_qtty AS int)                                  AS pt_total_traded_vol
    , CAST(ja_co.pt_total_traded_value AS decimal(23,2))                       AS pt_total_traded_val
    , CAST(ja_co.pt_bestbidqtty AS int)                                        AS pt_best_bid_vol
    , CAST(ja_co.pt_bestbidprice AS decimal(23,2))                             AS pt_best_bid_price
    , CAST(ja_co.pt_bestofferqtty AS int)                                      AS pt_best_offer_vol
    , CAST(ja_co.pt_bestofferprice AS decimal(23,2))                           AS pt_best_offer_price
    , CAST(ja_co.pt_totalbidqtty AS int)                                       AS pt_total_bid_vol
    , CAST(ja_co.pt_totalofferqtty AS int)                                     AS pt_total_offer_vol
    , CAST(ja_co.pt_maxqtty AS int)                                            AS pt_max_vol
    , CAST(ja_co.pt_maxprice AS decimal(23,2))                                 AS pt_max_price
    , CAST(ja_co.pt_minqtty AS int)                                            AS pt_min_vol
    , CAST(ja_co.pt_minprice AS decimal(23,2))                                 AS pt_min_price
    , CAST(ja_co.issuername AS string)                                         AS issuer_nm
    , CAST(ja_co.issuedate AS date)                                            AS issue_dt
    , CAST(ja_co.maturitydate AS date)                                         AS maturity_dt
    , CAST(ja_co.parvalue AS decimal(23,2))                                    AS par_val
    , CAST(ja_co.bond_period AS string)                                        AS bond_period
    , CAST(ja_co.period_remain AS int)                                         AS period_remain_days
    , CAST(ja_co.interest_period AS string)                                    AS interest_period
    , CAST(ja_co.interest_rate AS decimal(8,5))                                AS interest_rate
    , CAST(ja_co.characteristics AS string)                                    AS bond_characteristics
FROM ja_co