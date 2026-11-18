/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_corpbondinfor
* Program name: ODS MDDS.JAD_CORPBONDINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    symbol
    , fullname
    , tradingdate
    , floorcode
    , stocktype
    , ceiling
    , floor
    , reference
    , closeprice
    , closevol
    , change
    , totaltrading
    , totaltradingvalue
    , averageprice
    , open
    , high
    , low
    , foreignremain
    , pt_match_qtty
    , pt_match_price
    , pt_total_traded_qtty
    , pt_total_traded_value
    , tradingsessionid
    , issuername
    , maturitydate
    , totallistingqtty
    , bond_period
    , period_unit
    , period_remain
    , interest_type
    , interest_period
    , interest_period_unit
    , interest_coupon_type
    , interestrate_type
    , interest_payment_type
    , interest_rate
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
    , issuedate
    , characteristics
    , securitytradingstatus
    , tradsesstatus
    , parvalue
    , tradingtime
FROM {{ ref('stg_mdds_jad_corpbondinfor') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')