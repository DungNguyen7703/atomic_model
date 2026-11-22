/*
*--------------------------------------------------------------------*
* Program code: atm_pc_inspection
* Program name: Atomic Pc Inspection
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
        , inspection_type_cd
        , decision_no
        , decision_date
        , inspection_period
        , inspection_date
        , inspection_mode_cd
        , inspection_scope
        , lead_inspection_unit_vi
        , lead_inspection_unit_en
        , inspection_minutes_name
        , inspection_file_url
        , sanction_decision_no
    FROM {{ ref('ods_ids_company_inspection') }}
    WHERE created_date >= TIMESTAMP '{{ var("etl_date") }} 00:00:00'
        AND created_date <  TIMESTAMP '{{ var("etl_date") }} 00:00:00' + INTERVAL 1 DAY
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_INSPECTION', "id") }}                 AS pc_inspection_id
    , CAST(id AS string)                                                                AS pc_inspection_code
    , CAST('IDS_COMPANY_INSPECTION' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(inspection_type_cd AS string)                                                AS inspection_tp_code
    , CAST(decision_no AS string)                                                       AS decision_nbr
    , CAST(decision_date AS date)                                                       AS decision_dt
    , CAST(inspection_period AS string)                                                 AS inspection_period_nm
    , CAST(inspection_date AS date)                                                     AS inspection_dt
    , CAST(inspection_mode_cd AS string)                                                AS inspection_mode_code
    , CAST(inspection_scope AS string)                                                  AS inspection_scope_description
    , CAST(lead_inspection_unit_vi AS string)                                           AS lead_inspection_unit_nm
    , CAST(lead_inspection_unit_en AS string)                                           AS lead_inspection_unit_english_nm
    , CAST(inspection_minutes_name AS string)                                           AS inspection_minutes_nm
    , CAST(inspection_file_url AS string)                                               AS inspection_file_url
    , CAST(sanction_decision_no AS string)                                              AS sanction_decision_nbr
FROM src
