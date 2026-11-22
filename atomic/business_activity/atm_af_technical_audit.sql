/*
*--------------------------------------------------------------------*
* Program code: atm_af_technical_audit
* Program name: Atomic Af Technical Audit
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_TECHNICAL_AUDIT.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , af_inspection_id
        , inspection_entity_files
        , inspection_year
        , signing_auditor_name
        , legal_representative_name
        , inspection_result_cd
        , audit_action_cd
        , action_type_cd
        , document_no
        , document_date
        , violation_content
        , effective_from_date
        , effective_to_date
        , reason
        , ld_inspection_result_cd
        , ld_audit_action_cd
        , ld_reason
        , ld_document_no
        , ld_document_date
        , ld_violation_content
        , ld_effective_from_date
        , ld_effective_to_date
        , inspection_unit
        , inspection_type
        , inspection_other_unit
        , consider_next_year_processing
        , other_processing
        , ld_consider_next_year_processing
        , ld_other_processing
    FROM {{ ref('ods_audit_af_technical_audit') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_TECHNICAL_AUDIT', "src.id") }}          AS af_technical_audit_id
    , CAST(src.id AS string)                                                             AS af_technical_audit_code
    , CAST('AUDIT_AF_TECHNICAL_AUDIT' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}      AS af_id
    , CAST(afp.audit_firm_cd AS string)                                                  AS af_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_INSPECTION', "src.af_inspection_id") }} AS af_inspection_id
    , CAST(src.af_inspection_id AS string)                                               AS af_inspection_code
    , CAST(src.inspection_entity_files AS string)                                        AS inspection_entity_files
    , CAST(src.inspection_year AS string)                                                AS inspection_year
    , CAST(src.signing_auditor_name AS string)                                           AS signing_auditor_nm
    , CAST(src.legal_representative_name AS string)                                      AS legal_representative_nm
    , CAST(src.inspection_result_cd AS string)                                           AS inspection_result_code
    , CAST(src.audit_action_cd AS string)                                                AS audit_action_code
    , CAST(src.action_type_cd AS string)                                                 AS action_tp_code
    , CAST(src.document_no AS string)                                                    AS document_nbr
    , CAST(src.document_date AS date)                                                    AS document_dt
    , CAST(src.violation_content AS string)                                              AS violation_content
    , CAST(src.effective_from_date AS date)                                              AS effective_from_dt
    , CAST(src.effective_to_date AS date)                                                AS effective_to_dt
    , CAST(src.reason AS string)                                                         AS reason_description
    , CAST(src.ld_inspection_result_cd AS string)                                        AS leadership_inspection_result_code
    , CAST(src.ld_audit_action_cd AS string)                                             AS leadership_audit_action_code
    , CAST(src.ld_reason AS string)                                                      AS leadership_reason_description
    , CAST(src.ld_document_no AS string)                                                 AS leadership_document_nbr
    , CAST(src.ld_document_date AS date)                                                 AS leadership_document_dt
    , CAST(src.ld_violation_content AS string)                                           AS leadership_violation_content
    , CAST(src.ld_effective_from_date AS date)                                           AS leadership_effective_from_dt
    , CAST(src.ld_effective_to_date AS date)                                             AS leadership_effective_to_dt
    , CAST(src.inspection_unit AS string)                                                AS inspection_unit_code
    , CAST(src.inspection_type AS string)                                                AS inspection_tp_code
    , CAST(src.inspection_other_unit AS string)                                          AS inspection_other_unit_nm
    , CAST(src.consider_next_year_processing AS string)                                  AS consider_next_year_processing_code
    , CAST(src.other_processing AS string)                                               AS other_processing_description
    , CAST(src.ld_consider_next_year_processing AS string)                               AS leadership_consider_next_year_processing_code
    , CAST(src.ld_other_processing AS string)                                            AS leadership_other_processing_description
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                     AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
