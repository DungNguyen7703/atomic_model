-- ────────────────────────────────────────────────────────────
-- Model : tknb_fct_private_corporate_bond_international_offering_snpst
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT 
        snpst_dt_dim_id,
        private_corporate_bond_dim_id,
        rpt_year,
        rpt_month,
        market_tp,
        currency_code,
        offering_bond_quantity,
        posting_dt, 
        src_stm_code
    FROM {{ ref('dtm_fct_private_corporate_bond_international_offering_snpst')}}
    WHERE to_date(snpst_dt_dim_id, 'yyyyMMdd') = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_private_corporate_bond AS (
    SELECT 
        private_corporate_bond_dim_id,
        bond_code,
        issuer_nm,
        enterprise_tp,
        business_sector,
        bond_term_unit,
        bond_term,
        interest_rate_tp,
        issue_interest_rate,
        issue_dt,
        maturity_dt,
        interest_payment_method,
        convertible_bond_ind,
        warrant_linked_bond_ind,
        secured_bond_ind
    FROM {{ ref('dtm_private_corporate_bond_dim')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
)

SELECT 
    f.snpst_dt_dim_id,
    f.private_corporate_bond_dim_id,
    f.rpt_year,
    f.rpt_month,
    f.market_tp,
    f.currency_code,
    f.offering_bond_quantity,
    f.posting_dt,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    dim.bond_code,
    dim.issuer_nm,
    dim.enterprise_tp,
    dim.business_sector,
    dim.bond_term_unit,
    dim.bond_term,
    dim.interest_rate_tp,
    dim.issue_interest_rate,
    dim.issue_dt,
    dim.maturity_dt,
    dim.interest_payment_method,
    dim.convertible_bond_ind,
    dim.warrant_linked_bond_ind,
    dim.secured_bond_ind
FROM fact f
JOIN dim_private_corporate_bond dim 
    ON f.private_corporate_bond_dim_id = dim.private_corporate_bond_dim_id




    