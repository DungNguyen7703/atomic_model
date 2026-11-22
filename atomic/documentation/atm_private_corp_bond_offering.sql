/*
*--------------------------------------------------------------------*
* Program code: atm_private_corp_bond_offering
* Program name: Atomic Private Corp Bond Offering
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic lld_HNX_PRIVATE_CORP_BOND_OFFERING.yaml] Doi ten cot theo LLD: market_type->market_tp, posting_date->
*									posting_dt, report_month->rpt_month, issuer_name->issuer_nm, enterprise_type->enterprise_tp, issue_date->issue_dt,
*									maturity_date->maturity_dt, par_value->par_val, interest_payment_type->interest_payment_tp,
*									interest_rate_type->interest_rate_tp; them rpt_day, rpt_year, business_nbr (cuoi bang). convertible/warrant_linked/secured_bond_ind
*									doi STRING ('Co'/'Khong') -> INT 1/0 theo LLD (gia tri khac -> NULL). Can doi kieu cot vat ly (xem script ALTER).
* 2026-11-18		tuan.nguyenvanb		[LLD atomic lld_HNX_PRIVATE_CORP_BOND_OFFERING_DOMESTIC.yaml + _INTERNATIONAL.yaml, design b7be8252] STG tach bang gop thanh 2 bang
*									-> UNION ALL 2 ODS (ods_hnx_private_corp_bond_offering_domestic / _international), bo ods_hnx_private_corp_bond_offering cu.
*									(1) src_stm_code theo bang nguon: HNX_PRIVATE_CORP_BOND_OFFERING_DOMESTIC / HNX_PRIVATE_CORP_BOND_OFFERING_INTERNATIONAL;
*									(2) market_tp hardcode theo bang nguon ('Trong nước' / 'Quốc tế'), Id hash literal theo bang nguon;
*									(3) bang trong nuoc khong co CURRENCY, ISSUE_MARKET -> NULL; (4) THEM 2 cot cuoi rpt_period, data_dt (sau rpt_day).
*									ODS append partition data_dt -> doc data_dt = etl_date (cung cach atm_private_corp_bond_registration).
*									Strategy snapshot INSERT theo VI TRI -> bang vat ly phai ALTER ADD COLUMN ... AFTER rpt_day (xem scratch/alter_atm_private_corp_bond_offering_20261118.sql).
*/

WITH pr_of_dom AS (
    SELECT
        bond_code
        , posting_date
        , issuer_name
        , business_no
        , enterprise_type
        , business_sector
        , CAST(NULL AS string) AS currency   -- bang trong nuoc khong co cot CURRENCY
        , term_unit
        , term
        , issue_date
        , maturity_date
        , remaining_term
        , offering_volume
        , par_value
        , interest_payment_type
        , interest_rate_type
        , interest_payment_method
        , repurchase_and_swap
        , CAST(NULL AS string) AS issue_market   -- bang trong nuoc khong co cot ISSUE_MARKET
        , issue_interest_rate
        , convertible_bond
        , warrant_linked_bond
        , secured_bond
        , report_year
        , report_month
        , report_day
        , report_period
        , data_dt
    FROM {{ ref('ods_hnx_private_corp_bond_offering_domestic') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- ODS append partition data_dt
),

pr_of_intl AS (
    SELECT
        bond_code
        , posting_date
        , issuer_name
        , business_no
        , enterprise_type
        , business_sector
        , currency
        , term_unit
        , term
        , issue_date
        , maturity_date
        , remaining_term
        , offering_volume
        , par_value
        , interest_payment_type
        , interest_rate_type
        , interest_payment_method
        , repurchase_and_swap
        , issue_market
        , issue_interest_rate
        , convertible_bond
        , warrant_linked_bond
        , secured_bond
        , report_year
        , report_month
        , report_day
        , report_period
        , data_dt
    FROM {{ ref('ods_hnx_private_corp_bond_offering_international') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- ODS append partition data_dt
),

pr_of AS (
    SELECT
        {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_OFFERING_DOMESTIC', "concat_ws('-', d.bond_code, 'Trong nước', d.posting_date)") }} AS private_corp_bond_offering_id
        , 'HNX_PRIVATE_CORP_BOND_OFFERING_DOMESTIC' AS src_stm_code
        , 'Trong nước' AS market_tp
        , d.*
    FROM pr_of_dom d
    UNION ALL
    SELECT
        {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_OFFERING_INTERNATIONAL', "concat_ws('-', i.bond_code, 'Quốc tế', i.posting_date)") }} AS private_corp_bond_offering_id
        , 'HNX_PRIVATE_CORP_BOND_OFFERING_INTERNATIONAL' AS src_stm_code
        , 'Quốc tế' AS market_tp
        , i.*
    FROM pr_of_intl i
)

SELECT
    CAST(pr_of.private_corp_bond_offering_id AS string) AS private_corp_bond_offering_id
    , CAST(pr_of.src_stm_code AS string) AS src_stm_code
    , CAST(pr_of.bond_code AS string) AS bond_code
    , CAST(pr_of.market_tp AS string) AS market_tp
    , CAST(pr_of.posting_date AS date) AS posting_dt
    , CAST(pr_of.issuer_name AS string) AS issuer_nm
    , CAST(pr_of.business_no AS string) AS business_nbr
    , CAST(pr_of.enterprise_type AS string) AS enterprise_tp
    , CAST(pr_of.business_sector AS string) AS business_sector
    , CAST(pr_of.currency AS string) AS currency_code
    , CAST(pr_of.term_unit AS string) AS bond_term_unit
    , CAST(pr_of.term AS int) AS bond_term
    , CAST(pr_of.issue_date AS date) AS issue_dt
    , CAST(pr_of.maturity_date AS date) AS maturity_dt
    , CAST(pr_of.remaining_term AS int) AS remaining_bond_term
    , CAST(pr_of.offering_volume AS bigint) AS offering_bond_quantity
    , CAST(pr_of.par_value AS bigint) AS par_val
    , CAST(pr_of.interest_payment_type AS string) AS interest_payment_tp
    , CAST(pr_of.interest_rate_type AS string) AS interest_rate_tp
    , CAST(pr_of.interest_payment_method AS string) AS interest_payment_method
    , CAST(pr_of.repurchase_and_swap AS string) AS repurchase_and_swap
    , CAST(pr_of.issue_market AS string) AS issue_market
    , CAST(pr_of.issue_interest_rate AS decimal(5,2)) AS issue_interest_rate
    , CAST(CASE WHEN lower(trim(pr_of.convertible_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.convertible_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS convertible_bond_ind
    , CAST(CASE WHEN lower(trim(pr_of.warrant_linked_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.warrant_linked_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS warrant_linked_bond_ind
    , CAST(CASE WHEN lower(trim(pr_of.secured_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.secured_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS secured_bond_ind
    , CAST(pr_of.report_year AS int) AS rpt_year
    , CAST(pr_of.report_month AS int) AS rpt_month
    , CAST(pr_of.report_day AS int) AS rpt_day
    , CAST(pr_of.report_period AS string) AS rpt_period   -- [MOI 2026-11-18] AFTER rpt_day
    , CAST(pr_of.data_dt AS date) AS data_dt               -- [MOI 2026-11-18] AFTER rpt_period
FROM pr_of
