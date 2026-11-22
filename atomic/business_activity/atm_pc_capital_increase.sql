/*
*--------------------------------------------------------------------*
* Program code: atm_pc_capital_increase
* Program name: Atomic Pc Capital Increase
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
        , company_profile_id
        , report_year
        , paid_in_capital_eofy
        , capital_increase_am
        , capital_increase_count
        , capital_increase_purpose
        , official_letter_no
        , official_letter_date
        , licensing_authority_vi
        , licensing_authority_en
    FROM {{ ref('ods_ids_company_add_capital') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_ADD_CAPITAL', "id") }}                AS pc_capital_increase_id
    , CAST(id AS string)                                                                AS pc_capital_increase_code
    , CAST('IDS_COMPANY_ADD_CAPITAL' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(report_year AS string)                                                       AS rpt_year
    , CAST(paid_in_capital_eofy AS decimal(23,2))                                       AS charter_capital_end_of_fiscal_year_amt
    , CAST(capital_increase_am AS decimal(23,2))                                        AS capital_increase_amt
    , CAST(capital_increase_count AS int)                                               AS capital_increase_count
    , CAST(capital_increase_purpose AS string)                                          AS capital_increase_purpose
    , CAST(official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                AS official_letter_dt
    , CAST(licensing_authority_vi AS string)                                            AS licensing_authority_nm
    , CAST(licensing_authority_en AS string)                                            AS licensing_authority_english_nm
FROM src
