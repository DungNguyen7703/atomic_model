/*
*--------------------------------------------------------------------*
* Program code: atm_share_auction_result_hnx_share_auction
* Program name: Atomic Share Auction Result – HNX.SHARE_AUCTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sh_au AS (
    SELECT
        issuer_name
        , auction_type
        , registered_offering_shares
        , total_registered_investors
        , starting_price
        , average_winning_price
        , domestic_institutional_winners
        , foreign_institutional_winners
        , domestic_individual_winners
        , foreign_individual_winners
        , domestic_registered_buy_volume
        , foreign_registered_buy_volume
        , domestic_winning_shares
        , foreign_winning_shares
        , domestic_winning_value
        , foreign_winning_value
        , domestic_actual_sold_shares
        , foreign_actual_sold_shares
        , domestic_actual_sold_value
        , foreign_actual_sold_value
        , report_month
        , report_year
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_share_auction') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_SHARE_AUCTION', "concat_ws('-', sh_au.issuer_name, sh_au.auction_type)") }} AS share_auction_result_id
    , CAST(sh_au.issuer_name AS string)                       AS issuer_name
    , CAST(sh_au.auction_type AS string)                      AS auction_tp
    , CAST('HNX_SHARE_AUCTION' AS string)                     AS src_stm_code
    , CAST(sh_au.registered_offering_shares AS bigint)        AS registered_offering_share_quantity
    , CAST(sh_au.total_registered_investors AS bigint)        AS registered_investor_count
    , CAST(sh_au.starting_price AS decimal(23,2))             AS starting_price
    , CAST(sh_au.average_winning_price AS decimal(23,2))      AS average_winning_price
    , CAST(sh_au.domestic_institutional_winners AS bigint)    AS domestic_institutional_winner_count
    , CAST(sh_au.foreign_institutional_winners AS bigint)     AS foreign_institutional_winner_count
    , CAST(sh_au.domestic_individual_winners AS bigint)       AS domestic_individual_winner_count
    , CAST(sh_au.foreign_individual_winners AS bigint)        AS foreign_individual_winner_count
    , CAST(sh_au.domestic_registered_buy_volume AS bigint)    AS domestic_registered_buy_quantity
    , CAST(sh_au.foreign_registered_buy_volume AS bigint)     AS foreign_registered_buy_quantity
    , CAST(sh_au.domestic_winning_shares AS bigint)           AS domestic_winning_share_quantity
    , CAST(sh_au.foreign_winning_shares AS bigint)            AS foreign_winning_share_quantity
    , CAST(sh_au.domestic_winning_value AS decimal(23,2))     AS domestic_winning_value
    , CAST(sh_au.foreign_winning_value AS decimal(23,2))      AS foreign_winning_value
    , CAST(sh_au.domestic_actual_sold_shares AS bigint)       AS domestic_actual_sold_share_quantity
    , CAST(sh_au.foreign_actual_sold_shares AS bigint)        AS foreign_actual_sold_share_quantity
    , CAST(sh_au.domestic_actual_sold_value AS decimal(23,2)) AS domestic_actual_sold_value
    , CAST(sh_au.foreign_actual_sold_value AS decimal(23,2))  AS foreign_actual_sold_value
    , CAST(sh_au.report_month AS string)                      AS report_month
    , CAST(sh_au.report_year AS string)                       AS report_year
FROM sh_au
