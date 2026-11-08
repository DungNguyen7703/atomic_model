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
*/

WITH pr_of AS (
    SELECT
        bond_code
        , market_type
        , posting_date
        , report_month
        , issuer_name
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
        , business_no
        , report_day
        , report_year
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_private_corp_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_OFFERING', "concat_ws('-', pr_of.bond_code, pr_of.market_type, pr_of.posting_date)") }} AS private_corp_bond_offering_id
    , CAST(pr_of.bond_code AS string)                    AS bond_code
    , CAST(pr_of.market_type AS string)                  AS market_tp
    , CAST(pr_of.posting_date AS date)                   AS posting_dt
    , CAST('HNX_PRIVATE_CORP_BOND_OFFERING' AS string)   AS src_stm_code
    , CAST(pr_of.report_month AS string)                 AS rpt_month
    , CAST(pr_of.issuer_name AS string)                  AS issuer_nm
    , CAST(pr_of.enterprise_type AS string)              AS enterprise_tp
    , CAST(pr_of.business_sector AS string)              AS business_sector
    , CAST(pr_of.currency AS string)                     AS currency_code
    , CAST(pr_of.term_unit AS string)                    AS bond_term_unit
    , CAST(pr_of.term AS int)                            AS bond_term
    , CAST(pr_of.issue_date AS date)                     AS issue_dt
    , CAST(pr_of.maturity_date AS date)                  AS maturity_dt
    , CAST(pr_of.remaining_term AS int)                  AS remaining_bond_term
    , CAST(pr_of.offering_volume AS bigint)               AS offering_bond_quantity
    , CAST(pr_of.par_value AS bigint)                    AS par_val
    , CAST(pr_of.interest_payment_type AS string)        AS interest_payment_tp
    , CAST(pr_of.interest_rate_type AS string)           AS interest_rate_tp
    , CAST(pr_of.interest_payment_method AS string)      AS interest_payment_method
    , CAST(pr_of.repurchase_and_swap AS string)          AS repurchase_and_swap
    , CAST(pr_of.issue_market AS string)                 AS issue_market
    , CAST(pr_of.issue_interest_rate AS decimal(5,2))    AS issue_interest_rate
    , CAST(CASE WHEN lower(trim(pr_of.convertible_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.convertible_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS convertible_bond_ind
    , CAST(CASE WHEN lower(trim(pr_of.warrant_linked_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.warrant_linked_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS warrant_linked_bond_ind
    , CAST(CASE WHEN lower(trim(pr_of.secured_bond)) IN ('có','co','yes','y','1','true') THEN 1
                 WHEN lower(trim(pr_of.secured_bond)) IN ('không','khong','no','n','0','false') THEN 0 END AS int) AS secured_bond_ind
    , CAST(pr_of.report_day AS string)                   AS rpt_day
    , CAST(pr_of.report_year AS string)                  AS rpt_year
    , CAST(pr_of.business_no AS string)                  AS business_nbr
FROM pr_of
