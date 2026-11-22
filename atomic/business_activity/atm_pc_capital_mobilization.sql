/*
*--------------------------------------------------------------------*
* Program code: atm_pc_capital_mobilization
* Program name: Atomic Pc Capital Mobilization
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
        , paid_in_capital_eoy
        , capital_increase_count
        , capital_increase_method
        , audit_firm_name_vi
        , audit_firm_name_en
    FROM {{ ref('ods_ids_capital_mobilization') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_CAPITAL_MOBILIZATION', "id") }}               AS pc_capital_mobilization_id
    , CAST(id AS string)                                                                AS pc_capital_mobilization_code
    , CAST('IDS_CAPITAL_MOBILIZATION' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(report_year AS string)                                                       AS rpt_year
    , CAST(paid_in_capital_eoy AS decimal(23,2))                                        AS charter_capital_end_of_year_amt
    , CAST(capital_increase_count AS bigint)                                            AS capital_increase_count
    , CAST(capital_increase_method AS string)                                           AS capital_increase_method_nm
    , CAST(audit_firm_name_vi AS string)                                                AS af_nm
    , CAST(audit_firm_name_en AS string)                                                AS af_english_nm
FROM src
