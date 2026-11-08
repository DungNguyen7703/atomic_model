/*
*--------------------------------------------------------------------*
* Program code: atm_bond_trading_registration_status
* Program name: Atomic Bond Trading Registration Status
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH re_st AS (
    SELECT
        bond_code
        , trading_registration_status
        , issuer_name
        , par_value
        , currently_registered_trading_volume
        , first_trading_date
        , last_trading_date
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_registration_status_change') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_REGISTRATION_STATUS_CHANGE', "concat_ws('-', re_st.bond_code, re_st.trading_registration_status)") }} AS bond_trading_registration_status_id
    , CAST(re_st.bond_code AS string)                             AS bond_code
    , CAST('HNX_REGISTRATION_STATUS_CHANGE' AS string)            AS src_stm_code
    , CAST(re_st.trading_registration_status AS string)          AS trading_registration_status
    , CAST(re_st.issuer_name AS string)                           AS issuer_name
    , CAST(re_st.par_value AS bigint)                             AS par_value
    , CAST(re_st.currently_registered_trading_volume AS bigint)   AS registered_trading_bond_quantity
    , CAST(re_st.first_trading_date AS date)                      AS first_trading_date
    , CAST(re_st.last_trading_date AS date)                       AS last_trading_date
    , CAST(re_st.report_month AS string)                          AS report_month
FROM re_st
