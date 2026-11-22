/*
*--------------------------------------------------------------------*
* Program code: atm_af_suspension
* Program name: Atomic Af Suspension
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_SUSPENSION.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , af_auditor_profile_id
        , target_type_cd
        , source_type_cd
        , suspension_doc_no
        , suspension_issue_date
        , suspension_start_date
        , suspension_end_date
        , suspension_content
        , suspension_type_cd
        , af_inspection_id
    FROM {{ ref('ods_audit_af_suspension') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_SUSPENSION', "src.id") }}                          AS af_suspension_id
    , CAST(src.id AS string)                                                                        AS af_suspension_code
    , CAST('AUDIT_AF_SUSPENSION' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}                 AS af_id
    , CAST(afp.audit_firm_cd AS string)                                                             AS af_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.af_auditor_profile_id") }} AS af_auditor_id
    , CAST(src.af_auditor_profile_id AS string)                                                     AS af_auditor_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_INSPECTION', "src.af_inspection_id") }}            AS af_inspection_id
    , CAST(src.af_inspection_id AS string)                                                          AS af_inspection_code
    , CAST(src.target_type_cd AS string)                                                            AS suspension_target_tp_code
    , CAST(src.source_type_cd AS string)                                                            AS suspension_src_tp_code
    , CAST(src.suspension_doc_no AS string)                                                         AS suspension_document_nbr
    , CAST(src.suspension_issue_date AS date)                                                       AS suspension_issue_dt
    , CAST(src.suspension_start_date AS date)                                                       AS suspension_start_dt
    , CAST(src.suspension_end_date AS date)                                                         AS suspension_end_dt
    , CAST(src.suspension_content AS string)                                                        AS suspension_content
    , CAST(src.suspension_type_cd AS string)                                                        AS suspension_tp_code
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                                AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
