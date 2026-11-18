/*
*--------------------------------------------------------------------*
* Program code: atm_listing_status_change_hnx_listing_status_change
* Program name: Atomic Listing Status Change – HNX.LISTING_STATUS_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH li_st AS (
    SELECT
        decision_no
        , decision_date
        , new_listed_shares
        , additional_listed_shares
        , delisted_shares
        , exchange_transfer
        , listed_value
        , additional_listed_value
        , delisted_value
        , ticker_symbol
        , issuer_name
        , effective_date
        , first_trading_date
        , last_trading_date
        , delist_transfer_reason
        , report_month
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_listing_status_change') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_LISTING_STATUS_CHANGE', "concat_ws('-', li_st.decision_no, li_st.decision_date, li_st.ticker_symbol)") }} AS listing_status_change_id
    , CAST(li_st.decision_no AS string)                    AS decision_no
    , CAST(li_st.decision_date AS date)                    AS decision_date
    , CAST(li_st.ticker_symbol AS string)                  AS ticker_symbol
    , CAST('HNX_LISTING_STATUS_CHANGE' AS string)          AS src_stm_code
    , CAST(li_st.new_listed_shares AS bigint)              AS new_listed_share_quantity
    , CAST(li_st.additional_listed_shares AS bigint)       AS additional_listed_share_quantity
    , CAST(li_st.delisted_shares AS bigint)                AS delisted_share_quantity
    , CAST(li_st.exchange_transfer AS string)              AS exchange_transfer
    , CAST(li_st.listed_value AS decimal(23,2))            AS listed_share_value
    , CAST(li_st.additional_listed_value AS decimal(23,2)) AS additional_listed_share_value
    , CAST(li_st.delisted_value AS decimal(23,2))          AS delisted_share_value
    , CAST(li_st.issuer_name AS string)                    AS issuer_name
    , CAST(li_st.effective_date AS date)                   AS effective_date
    , CAST(li_st.first_trading_date AS date)               AS first_trading_date
    , CAST(li_st.last_trading_date AS date)                AS last_trading_date
    , CAST(li_st.delist_transfer_reason AS string)         AS delist_transfer_reason
    , CAST(li_st.report_month AS string)                   AS report_month
FROM li_st
