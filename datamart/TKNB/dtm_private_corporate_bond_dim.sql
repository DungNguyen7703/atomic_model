/*
*--------------------------------------------------------------------*
* Program code: dtm_private_corporate_bond_dim
* Program name: Private Corporate Bond Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		duxn			[REF] Chuan hoa phan tang CTE va doi ten CTE ngan gon, ro nghia (max 2 tu).
*--------------------------------------------------------------------*
*/

WITH bond_offering_raw AS (
    SELECT
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
        secured_bond_ind,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY bond_code
            ORDER BY rpt_year DESC, rpt_month DESC
        ) AS rn
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND bond_code IS NOT NULL
),

bond_offering (
    SELECT
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
        secured_bond_ind,
        src_stm_code
    FROM bond_offering_raw
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('HNX_PRIVATE_CORP_BOND_OFFERING', 'bond_code') }} AS string) AS private_corporate_bond_dim_id,
    CAST(bond_code AS string)                                       AS bond_code,
    CAST(issuer_nm AS string)                                       AS issuer_nm,
    CAST(enterprise_tp AS string)                                   AS enterprise_tp,
    CAST(business_sector AS string)                                 AS business_sector,
    CAST(bond_term_unit AS string)                                  AS bond_term_unit,
    CAST(bond_term AS int)                                          AS bond_term,
    CAST(interest_rate_tp AS string)                                AS interest_rate_tp,
    CAST(issue_interest_rate AS decimal(8,5))                       AS issue_interest_rate,
    CAST(issue_dt AS date)                                          AS issue_dt,
    CAST(maturity_dt AS date)                                       AS maturity_dt,
    CAST(interest_payment_method AS string)                         AS interest_payment_method,
    CAST(convertible_bond_ind AS string)                            AS convertible_bond_ind,
    CAST(warrant_linked_bond_ind AS string)                         AS warrant_linked_bond_ind,
    CAST(secured_bond_ind AS string)                                AS secured_bond_ind,
    CAST(src_stm_code AS string)                                    AS src_stm_code
FROM bond_offering

