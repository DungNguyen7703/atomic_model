/*
*--------------------------------------------------------------------*
* Program code: atm_pc_bond_evaluation
* Program name: Atomic Public Company Bond Evaluation
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_cb AS (
    SELECT
        id
        , company_id
        , business_reg_no
        , equity_ticker
        , name
        , ranking
        , year
        , month
        , per_tp_db
        , price_tp_lh
    FROM {{ ref('ods_ids_evaluation_cbonds') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATION_CBONDS', "ev_cb.id") }}          AS pc_bond_evaluation_id
    , CAST(ev_cb.id AS string)                                                        AS pc_bond_evaluation_code
    , CAST('IDS_EVALUATION_CBONDS' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "ev_cb.company_id") }} AS pc_id
    , CAST(ev_cb.company_id AS string)                                                AS pc_code
    , CAST(ev_cb.business_reg_no AS string)                                           AS business_registration_nbr_snpst
    , CAST(ev_cb.equity_ticker AS string)                                             AS equity_ticker_symbol_snpst
    , CAST(ev_cb.name AS string)                                                      AS pc_nm_snpst
    , CAST(ev_cb.ranking AS string)                                                   AS ranking_code
    , CAST(ev_cb.year AS int)                                                         AS evaluation_year
    , CAST(ev_cb.month AS int)                                                        AS evaluation_month
    , CAST(ev_cb.per_tp_db AS decimal(5,2))                                           AS bond_collateral_ratio_percentage
    , CAST(ev_cb.price_tp_lh AS decimal(5,2))                                         AS bond_outstanding_to_equity_ratio_percentage
FROM ev_cb