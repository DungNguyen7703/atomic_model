/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_international_offering_snpst
* Program name: Fact Private Corporate Bond International Offering Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		duxn			snpst_dt_dim_id = ngay cuoi thang theo rpt_year, rpt_month.
* 2026-11-07		claude			[UPD] Loc offering theo market_tp = 'Quoc te' (tuong duong market_type o staging)
*--------------------------------------------------------------------*
*/

WITH bond_offering AS (
    SELECT
        bond_code,
        market_tp,
        rpt_year,
        rpt_month,
        currency_code,
        offering_bond_quantity,
        posting_dt,
        src_stm_code
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND lower(market_tp) = 'quốc tế'
),

bond_dim AS (
    SELECT
        private_corporate_bond_dim_id,
        bond_code
    FROM {{ ref('dtm_private_corporate_bond_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
)

SELECT
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')     AS snpst_dt_dim_id,
    CAST(bond_dim.private_corporate_bond_dim_id AS string)                      AS private_corporate_bond_dim_id,
    CAST(bond_offering.rpt_year AS string)                                      AS rpt_year,
    CAST(bond_offering.rpt_month AS string)                                     AS rpt_month,
    CAST(bond_offering.market_tp AS string)                                     AS market_tp,
    CAST(bond_offering.currency_code AS string)                                 AS currency_code,
    CAST(bond_offering.offering_bond_quantity AS bigint)                        AS offering_bond_quantity,
    CAST(bond_offering.posting_dt AS date)                                      AS posting_dt,
    CAST(bond_offering.src_stm_code AS string)                                  AS src_stm_code
FROM bond_offering
INNER JOIN bond_dim
    ON bond_dim.bond_code = bond_offering.bond_code
