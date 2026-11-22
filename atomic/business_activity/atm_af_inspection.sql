/*
*--------------------------------------------------------------------*
* Program code: atm_af_inspection
* Program name: Atomic Af Inspection
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_INSPECTION.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , inspection_authority_cd
        , inspection_team
        , inspection_decision_no
        , inspection_start_date
        , inspection_end_date
        , audit_system_result_cd
        , overall_result_cd
        , overall_action_cd
        , overall_action_type_cd
        , overall_document_no
        , overall_document_date
        , overall_violation_content
        , overall_effective_from_date
        , overall_effective_to_date
        , audit_technical_result_cd
    FROM {{ ref('ods_audit_af_inspection') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_INSPECTION', "src.id") }}            AS af_inspection_id
    , CAST(src.id AS string)                                                        AS af_inspection_code
    , CAST('AUDIT_AF_INSPECTION' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }} AS af_id
    , CAST(afp.audit_firm_cd AS string)                                             AS af_code
    , CAST(src.inspection_authority_cd AS string)                                   AS inspection_authority_code
    , CAST(src.inspection_team AS string)                                           AS inspection_team_member_list
    , CAST(src.inspection_decision_no AS string)                                    AS inspection_decision_nbr
    , CAST(src.inspection_start_date AS date)                                       AS inspection_start_dt
    , CAST(src.inspection_end_date AS date)                                         AS inspection_end_dt
    , CAST(src.audit_system_result_cd AS string)                                    AS inspection_result_code
    , CAST(src.audit_technical_result_cd AS string)                                 AS audit_technical_result_code
    , CAST(src.overall_result_cd AS string)                                         AS overall_result_code
    , CAST(src.overall_action_cd AS string)                                         AS overall_action_code
    , CAST(src.overall_action_type_cd AS string)                                    AS overall_action_tp_code
    , CAST(src.overall_document_no AS string)                                       AS overall_document_nbr
    , CAST(src.overall_document_date AS date)                                       AS overall_document_dt
    , CAST(src.overall_violation_content AS string)                                 AS overall_violation_content
    , CAST(src.overall_effective_from_date AS date)                                 AS overall_effective_from_dt
    , CAST(src.overall_effective_to_date AS date)                                   AS overall_effective_to_dt
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
