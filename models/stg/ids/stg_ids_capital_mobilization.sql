/*
*--------------------------------------------------------------------*
* Program code: stg_ids_capital_mobilization
* Program name: Staging IDS.CAPITAL_MOBILIZATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(company_profile_id AS int)         AS company_profile_id
    , CAST(report_year AS string)             AS report_year
    , CAST(paid_in_capital_eoy AS int)        AS paid_in_capital_eoy
    , CAST(capital_increase_count AS int)     AS capital_increase_count
    , CAST(capital_increase_method AS string) AS capital_increase_method
    , CAST(audit_firm_name_vi AS string)      AS audit_firm_name_vi
    , CAST(audit_firm_name_en AS string)      AS audit_firm_name_en
    , CAST(delete_flg AS int)                 AS delete_flg
    , CAST(created_by AS string)              AS created_by
    , CAST(created_date AS date)              AS created_date
    , CAST(updated_by AS string)              AS updated_by
    , CAST(updated_date AS date)              AS updated_date
FROM {{ source('source_ids', 'raw_capital_mobilization') }}