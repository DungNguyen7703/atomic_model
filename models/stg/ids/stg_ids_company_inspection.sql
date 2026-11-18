/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_inspection
* Program name: Staging IDS.COMPANY_INSPECTION
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
    , CAST(inspection_type_cd AS string)      AS inspection_type_cd
    , CAST(decision_no AS string)             AS decision_no
    , CAST(decision_date AS date)             AS decision_date
    , CAST(inspection_period AS string)       AS inspection_period
    , CAST(inspection_date AS date)           AS inspection_date
    , CAST(inspection_mode_cd AS string)      AS inspection_mode_cd
    , CAST(inspection_scope AS string)        AS inspection_scope
    , CAST(lead_inspection_unit_vi AS string) AS lead_inspection_unit_vi
    , CAST(lead_inspection_unit_en AS string) AS lead_inspection_unit_en
    , CAST(inspection_minutes_name AS string) AS inspection_minutes_name
    , CAST(inspection_file_url AS string)     AS inspection_file_url
    , CAST(sanction_decision_no AS string)    AS sanction_decision_no
    , CAST(created_by AS string)              AS created_by
    , CAST(created_date AS date)              AS created_date
    , CAST(updated_by AS string)              AS updated_by
    , CAST(updated_date AS date)              AS updated_date
    , CAST(delete_flg AS int)                 AS delete_flg
FROM {{ source('source_ids', 'raw_company_inspection') }}