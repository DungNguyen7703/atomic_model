/*
*--------------------------------------------------------------------*
* Program code: atm_depository_account_movement
* Program name: Atomic Depository Account Movement
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ac_st AS (
    SELECT
        depository_member
        , begin_period_dom_indiv_accounts
        , begin_period_dom_inst_accounts
        , begin_period_for_indiv_accounts
        , begin_period_for_inst_accounts
        , begin_period_total_accounts
        , opened_dom_indiv_accounts
        , opened_dom_inst_accounts
        , opened_for_indiv_accounts
        , opened_for_inst_accounts
        , closed_dom_indiv_accounts
        , closed_dom_inst_accounts
        , closed_for_indiv_accounts
        , closed_for_inst_accounts
        , end_period_dom_indiv_accounts
        , end_period_dom_inst_accounts
        , end_period_for_indiv_accounts
        , end_period_for_inst_accounts
        , total_accounts
        , notes
        , ds_snpst_dt
    FROM {{ ref('ods_vsdc_account_opening_closing_status') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_ACCOUNT_OPENING_CLOSING_STATUS', "ac_st.depository_member") }} AS depository_account_movement_id
    , CAST(ac_st.depository_member AS string)                     AS depository_member_code
    , CAST('VSDC_ACCOUNT_OPENING_CLOSING_STATUS' AS string)       AS src_stm_code
    , CAST(ac_st.begin_period_dom_indiv_accounts AS bigint)       AS opening_domestic_individual_account_count
    , CAST(ac_st.begin_period_dom_inst_accounts AS bigint)        AS opening_domestic_institutional_account_count
    , CAST(ac_st.begin_period_for_indiv_accounts AS bigint)       AS opening_foreign_individual_account_count
    , CAST(ac_st.begin_period_for_inst_accounts AS bigint)        AS opening_foreign_institutional_account_count
    , CAST(ac_st.begin_period_total_accounts AS bigint)           AS opening_total_account_count
    , CAST(ac_st.opened_dom_indiv_accounts AS bigint)              AS opened_domestic_individual_account_count
    , CAST(ac_st.opened_dom_inst_accounts AS bigint)               AS opened_domestic_institutional_account_count
    , CAST(ac_st.opened_for_indiv_accounts AS bigint)              AS opened_foreign_individual_account_count
    , CAST(ac_st.opened_for_inst_accounts AS bigint)               AS opened_foreign_institutional_account_count
    , CAST(ac_st.closed_dom_indiv_accounts AS bigint)              AS closed_domestic_individual_account_count
    , CAST(ac_st.closed_dom_inst_accounts AS bigint)               AS closed_domestic_institutional_account_count
    , CAST(ac_st.closed_for_indiv_accounts AS bigint)              AS closed_foreign_individual_account_count
    , CAST(ac_st.closed_for_inst_accounts AS bigint)               AS closed_foreign_institutional_account_count
    , CAST(ac_st.end_period_dom_indiv_accounts AS bigint)          AS closing_domestic_individual_account_count
    , CAST(ac_st.end_period_dom_inst_accounts AS bigint)           AS closing_domestic_institutional_account_count
    , CAST(ac_st.end_period_for_indiv_accounts AS bigint)          AS closing_foreign_individual_account_count
    , CAST(ac_st.end_period_for_inst_accounts AS bigint)           AS closing_foreign_institutional_account_count
    , CAST(ac_st.total_accounts AS bigint)                         AS closing_total_account_count
    , CAST(ac_st.notes AS string)                                  AS notes
FROM ac_st
