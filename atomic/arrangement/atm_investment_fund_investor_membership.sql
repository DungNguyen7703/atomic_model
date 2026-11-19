/*
*--------------------------------------------------------------------*
* Program code: atm_investment_fund_investor_membership
* Program name: Atomic Investment Fund Investor Membership
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , fund_id
        , nat_id
        , st_id
        , item_name
        , dorf
        , mb_id
        , fn_code
        , province
        , country
        , capital
        , hold_qtty
        , hold_percent
        , hold_date
        , frepresent_date
        , mb_type
        , represent_job
        , represent_name
        , srepresent_date
    FROM {{ ref('ods_fms_mb_fund') }}
),

nati AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_MB_FUND', "src.id") }}               AS investment_fund_investor_membership_id
    , CAST(src.id AS string)                                                   AS investment_fund_investor_membership_code
    , CAST('FMS_MB_FUND' AS string)                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "src.fund_id") }}          AS investment_fund_id
    , CAST(src.fund_id AS string)                                              AS investment_fund_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.code") }}         AS nationality_id
    , CAST(nati.code AS string)                                                AS nationality_code
    , {{ generate_surrogate_key_bigint('FMS_STOCKHOLDER_TYPE', "src.st_id") }} AS cl_fms_stockholder_tp_id
    , CAST(src.st_id AS string)                                                AS cl_fms_stockholder_tp_code
    , CAST(src.item_name AS string)                                            AS investment_fund_investor_membership_full_nm
    , CAST(src.dorf AS string)                                                 AS organization_territory_tp_code
    , CAST(src.mb_id AS string)                                                AS member_code
    , CAST(src.fn_code AS string)                                              AS fund_membership_code
    , CAST(src.province AS string)                                             AS province_nm
    , CAST(src.country AS string)                                              AS country_nm
    , CAST(src.capital AS decimal(23,2))                                       AS contributed_capital_amt
    , CAST(src.hold_qtty AS int)                                               AS held_unit_quantity
    , CAST(src.hold_percent AS decimal(5,2))                                   AS held_percentage
    , CAST(src.hold_date AS date)                                              AS held_confirmation_dt
    , CAST(src.frepresent_date AS date)                                        AS representation_start_dt
    , CAST(src.mb_type AS int)                                                 AS member_tp_code
    , CAST(src.represent_job AS string)                                        AS representative_position_title
    , CAST(src.represent_name AS string)                                       AS representative_full_nm
    , CAST(src.srepresent_date AS date)                                        AS representation_end_dt
FROM src
    LEFT JOIN nati ON src.nat_id = nati.id
