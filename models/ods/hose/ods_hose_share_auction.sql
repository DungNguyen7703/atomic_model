/*
*--------------------------------------------------------------------*
* Program code: ods_hose_share_auction
* Program name: ODS HOSE.SHARE_AUCTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(issuer_name AS string)                        AS issuer_name
    , CAST(auction_type AS string)                      AS auction_type
    , CAST(registered_offering_shares AS bigint)        AS registered_offering_shares
    , CAST(total_registered_investors AS bigint)        AS total_registered_investors
    , CAST(starting_price AS decimal(18,2))             AS starting_price
    , CAST(average_winning_price AS decimal(18,2))      AS average_winning_price
    , CAST(domestic_institutional_winners AS bigint)    AS domestic_institutional_winners
    , CAST(foreign_institutional_winners AS bigint)     AS foreign_institutional_winners
    , CAST(domestic_individual_winners AS bigint)       AS domestic_individual_winners
    , CAST(foreign_individual_winners AS bigint)        AS foreign_individual_winners
    , CAST(domestic_registered_buy_volume AS bigint)    AS domestic_registered_buy_volume
    , CAST(foreign_registered_buy_volume AS bigint)     AS foreign_registered_buy_volume
    , CAST(domestic_winning_shares AS bigint)           AS domestic_winning_shares
    , CAST(foreign_winning_shares AS bigint)            AS foreign_winning_shares
    , CAST(domestic_winning_value AS decimal(18,2))     AS domestic_winning_value
    , CAST(foreign_winning_value AS decimal(18,2))      AS foreign_winning_value
    , CAST(domestic_actual_sold_shares AS bigint)       AS domestic_actual_sold_shares
    , CAST(foreign_actual_sold_shares AS bigint)        AS foreign_actual_sold_shares
    , CAST(domestic_actual_sold_value AS decimal(18,2)) AS domestic_actual_sold_value
    , CAST(foreign_actual_sold_value AS decimal(18,2))  AS foreign_actual_sold_value
    , CAST(report_month AS string)                      AS report_month
    , CAST(report_year AS string)                       AS report_year
    , CAST(ds_snpst_dt AS date)                         AS ds_snpst_dt
FROM {{ source('source_hose', 'raw_share_auction_hose') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
