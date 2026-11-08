/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_issuance_snpst
* Program name: Fact Private Corporate Bond Issuance Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		duxn			[REF] Chuan hoa phan tang CTE va doi ten CTE ngan gon, ro nghia (max 2 tu).
* 2026-11-07		claude			[UPD] Loc offering theo market_tp = 'Trong nước' (tuong duong market_type o staging)
*--------------------------------------------------------------------*
*/

WITH offering_raw AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_year,
        rpt_month,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY bond_code, rpt_year, rpt_month
            ORDER BY rpt_day DESC, posting_dt DESC)
        AS rn
    FROM {{ ref('atm_private_corp_bond_offering') }} 
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND lower(market_tp) = 'trong nước'
        AND bond_code IS NOT NULL
),

registration_raw AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_year,
        rpt_month,
        issued_bond_quantity,
        par_val,
        ROW_NUMBER() OVER (
            PARTITION BY bond_code, rpt_year, rpt_month
            ORDER BY rpt_day DESC)
        AS rn
    FROM {{ ref('atm_private_corp_bond_registration') }} 
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
),

bond_dim AS (
    SELECT
        private_corporate_bond_dim_id,
        bond_code
    FROM {{ ref('dtm_private_corporate_bond_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
),

bond_offering AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_year,
        rpt_month,
        src_stm_code
    FROM offering_raw
    WHERE rn = 1
),

bond_registration AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_year,
        rpt_month,
        issued_bond_quantity,
        par_val
    FROM registration_raw
    WHERE rn = 1
)

SELECT
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')      AS snpst_dt_dim_id,
    CAST(bond_dim.private_corporate_bond_dim_id AS string)                      AS private_corporate_bond_dim_id,
    CAST(bond_offering.rpt_year AS string)                                      AS rpt_year,
    CAST(bond_offering.rpt_month AS string)                                     AS rpt_month,
    CAST(bond_registration.issued_bond_quantity AS bigint)                      AS issued_bond_quantity,
    CAST(bond_registration.par_val AS decimal(23,2))                            AS par_value,
    CAST(CAST(bond_registration.issued_bond_quantity AS decimal(23,2)) * bond_registration.par_val AS decimal(23,2)) AS issued_bond_val_amt,
    CAST(bond_offering.src_stm_code AS string)                                  AS src_stm_code
FROM bond_offering
LEFT JOIN bond_registration
    ON bond_registration.bond_code = bond_offering.bond_code
    AND bond_registration.issue_dt = bond_offering.issue_dt
    AND bond_registration.maturity_dt = bond_offering.maturity_dt
    AND bond_registration.rpt_year = bond_offering.rpt_year
    AND bond_registration.rpt_month = bond_offering.rpt_month
INNER JOIN bond_dim
    ON bond_dim.bond_code = bond_offering.bond_code
