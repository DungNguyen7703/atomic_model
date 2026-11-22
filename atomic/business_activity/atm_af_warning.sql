/*
*--------------------------------------------------------------------*
* Program code: atm_af_warning
* Program name: Atomic Af Warning
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_WARNING.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , af_auditor_profile_id
        , target_type_cd
        , source_type_cd
        , warning_doc_no
        , warning_issue_date
        , warning_start_date
        , warning_end_date
        , warning_content
        , warning_type_cd
        , af_inspection_id
    FROM {{ ref('ods_audit_af_warning') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_WARNING', "src.id") }}                             AS af_warning_id
    , CAST(src.id AS string)                                                                        AS af_warning_code
    , CAST('AUDIT_AF_WARNING' AS string)                                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}                 AS af_id
    , CAST(afp.audit_firm_cd AS string)                                                             AS af_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.af_auditor_profile_id") }} AS af_auditor_id
    , CAST(src.af_auditor_profile_id AS string)                                                     AS af_auditor_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_INSPECTION', "src.af_inspection_id") }}            AS af_inspection_id
    , CAST(src.af_inspection_id AS string)                                                          AS af_inspection_code
    , CAST(src.target_type_cd AS string)                                                            AS warning_target_tp_code
    , CAST(src.source_type_cd AS string)                                                            AS warning_src_tp_code
    , CAST(src.warning_doc_no AS string)                                                            AS warning_document_nbr
    , CAST(src.warning_issue_date AS date)                                                          AS warning_issue_dt
    , CAST(src.warning_start_date AS date)                                                          AS warning_start_dt
    , CAST(src.warning_end_date AS date)                                                            AS warning_end_dt
    , CAST(src.warning_content AS string)                                                           AS warning_content
    , CAST(src.warning_type_cd AS string)                                                           AS warning_tp_code
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                                AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
