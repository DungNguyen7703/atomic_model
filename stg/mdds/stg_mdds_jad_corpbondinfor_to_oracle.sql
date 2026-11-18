{{
    config(
        materialized = 'view',
        schema = var('stg_mdds_schema'),
        alias = 'jad_corpbondinfor_to_oracle_v',
        post_hook = [
            "INSERT INTO {{ var('src_mdds_schema') }}.JAD_CORPBONDINFOR_UAT (symbol, fullname, tradingdate, floorcode, stocktype, ceiling, floor, reference, closeprice, closevol, change, totaltrading, totaltradingvalue, averageprice, open, high, low, foreignremain, pt_match_qtty, pt_match_price, pt_total_traded_qtty, pt_total_traded_value, tradingsessionid, issuername, maturitydate, totallistingqtty, bond_period, period_unit, period_remain, interest_type, interest_period, interest_period_unit, interest_coupon_type, interestrate_type, interest_payment_type, interest_rate, pt_bestbidqtty, pt_bestbidprice, pt_bestofferqtty, pt_bestofferprice, pt_totalbidqtty, pt_totalofferqtty, pt_maxqtty, pt_maxprice, pt_minqtty, pt_minprice, issuedate, characteristics, securitytradingstatus, tradsesstatus, parvalue, tradingtime) SELECT /*+ REPARTITION(256) */ * FROM {{ this }}"
        ],
        tags = ['layer_staging', 'domain_mdds', 'push_to_oracle']
    )
}}

/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_corpbondinfor_to_oracle
* Program name: Day MDDS.JAD_CORPBONDINFOR tu staging UAT (Iceberg) vao Oracle oracle_viettel_2.UBCK_PROD.JAD_CORPBONDINFOR_UAT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Chieu nguoc voi stg_mdds_jad_corpbondinfor: doc FULL staging.uat_MDDS_stg.jad_corpbondinfor (khong loc etl_date) -> INSERT vao Oracle UBCK_PROD.. tradingdate doi lai dd/MM/yyyy (varchar2). Hint REPARTITION(8) de ghi JDBC song song 8 ket noi. Khong gom ds_etl_pcs_tms. Bang Oracle UBCK_PROD phai TRUNCATE truoc khi chay lai (hook chi INSERT).
*--------------------------------------------------------------------*
*/

SELECT
    symbol
    , fullname
    , date_format(tradingdate, 'dd/MM/yyyy') AS tradingdate
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
FROM {{ source('source_mdds_uat_stg', 'raw_jad_corpbondinfor') }}
