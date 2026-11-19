/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_investor_securities_holding
* Program name: Atomic Foreign Investor Securities Holding
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo LLD FIMS_CATEGORIESSTOCK (Relative, SCD2). Crosswalk INVESID -> FIMS.INVESTOR.ID de lay TRANSACTIONCODE; holding_rate CAST decimal(5,2) theo DM (nguon decimal(18,6))
*--------------------------------------------------------------------*
*/

WITH ca_st AS (
    SELECT
        id
        , invesid
        , secid
        , quantity
        , rate
        , datecreated
    FROM {{ ref('ods_fims_categoriesstock') }}
),

inve AS (
    SELECT
        id
        , transactioncode
    FROM {{ ref('ods_fims_investor') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_CATEGORIESSTOCK', "ca_st.id") }}          AS foreign_investor_securities_holding_id
    , CAST(ca_st.id AS string)                                                       AS foreign_investor_securities_holding_code
    , CAST('FIMS_CATEGORIESSTOCK' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "inve.transactioncode") }}   AS foreign_investor_id
    , CAST(inve.transactioncode AS string)                                           AS foreign_investor_code
    , {{ generate_surrogate_key_bigint('FIMS_SECURITIESCOMPANY', "ca_st.secid") }}   AS sc_id
    , CAST(ca_st.secid AS string)                                                    AS sc_code
    , CAST(ca_st.quantity AS bigint)                                                 AS holding_quantity
    , CAST(ca_st.rate AS decimal(5,2))                                               AS holding_rate
    , CAST(ca_st.datecreated AS date)                                                AS data_dt
FROM ca_st
LEFT JOIN inve ON ca_st.invesid = inve.id
