/*
*--------------------------------------------------------------------*
* Program code: stg_ids_capital_increase_plan
* Program name: Staging IDS.CAPITAL_INCREASE_PLAN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                 AS id
    , CAST(company_data_id AS decimal(19,0))    AS company_data_id
    , CAST(company_profile_id AS decimal(19,0)) AS company_profile_id
    , CAST(resolution_type_cd AS string)        AS resolution_type_cd
    , CAST(attendance_rate AS decimal(10,4))    AS attendance_rate
    , CAST(has_cash_dividend_flg AS int)        AS has_cash_dividend_flg
    , CAST(cash_dividend_rate AS decimal(10,4)) AS cash_dividend_rate
    , CAST(has_capital_increase_flg AS int)     AS has_capital_increase_flg
    , CAST(approval_rate AS string)             AS approval_rate
    , CAST(has_issuance_plan_flg AS string)     AS has_issuance_plan_flg
    , CAST(doc_sign_date AS date)               AS doc_sign_date
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS timestamp)           AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS timestamp)           AS updated_date
FROM {{ source('source_ids', 'raw_capital_increase_plan') }}