/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_stakeholder
* Program name: Atomic Fmc Stakeholder
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH fmc_secu AS (
    SELECT
        id
        , code 
    FROM {{ ref('ods_fms_securities') }}
),

src AS (
    SELECT
        id
        , security_id
        , item_name
        , relation_ship
        , capital
        , description
        , owner_flag
        , id_no
        , period_type
        , period_value
        , year_value
    FROM {{ ref('ods_fms_stake') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STAKE', "src.id") }}                 AS fmc_stakeholder_id
    , CAST(src.id AS string)                                                   AS fmc_stakeholder_code
    , CAST('FMS_STAKE' AS string)                                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "fmc_secu.code") }}   AS fmc_id
    , CAST(fmc_secu.code AS string)                                            AS fmc_code
    , CAST(src.item_name AS string)                                            AS fmc_stakeholder_full_nm
    , CAST(src.relation_ship AS string)                                        AS rltnp_description
    , CAST(src.capital AS decimal(23,2))                                       AS contributed_capital_amt
    , CAST(src.owner_flag AS int)                                              AS controlling_shareholder_ind
    , CAST(src.id_no AS string)                                                AS stakeholder_registration_nbr
    , CAST(src.description AS string)                                          AS description
    , CAST(src.period_type AS string)                                          AS period_tp_code
    , CAST(src.period_value AS string)                                         AS period_val
    , CAST(src.year_value AS int)                                              AS rpt_year
FROM src
    LEFT JOIN fmc_secu ON src.security_id = fmc_secu.id