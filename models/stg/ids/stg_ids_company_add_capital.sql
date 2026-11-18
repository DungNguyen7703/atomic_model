/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_add_capital
* Program name: Staging IDS.COMPANY_ADD_CAPITAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(company_profile_id AS int)          AS company_profile_id
    , CAST(report_year AS string)              AS report_year
    , CAST(paid_in_capital_eofy AS int)        AS paid_in_capital_eofy
    , CAST(capital_increase_am AS int)         AS capital_increase_am
    , CAST(capital_increase_count AS int)      AS capital_increase_count
    , CAST(capital_increase_purpose AS string) AS capital_increase_purpose
    , CAST(official_letter_no AS string)       AS official_letter_no
    , CAST(official_letter_date AS date)       AS official_letter_date
    , CAST(licensing_authority_vi AS string)   AS licensing_authority_vi
    , CAST(licensing_authority_en AS string)   AS licensing_authority_en
    , CAST(delete_flg AS int)                  AS delete_flg
    , CAST(created_by AS string)               AS created_by
    , CAST(created_date AS date)               AS created_date
    , CAST(updated_by AS string)               AS updated_by
    , CAST(updated_date AS date)               AS updated_date
    , CAST(is_sync AS int)                     AS is_sync
FROM {{ source('source_ids', 'raw_company_add_capital') }}