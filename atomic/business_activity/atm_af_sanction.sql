/*
*--------------------------------------------------------------------*
* Program code: atm_af_sanction
* Program name: Atomic Af Sanction
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_SANCTIONS.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , sanction_authority_cd
        , decision_no
        , decision_date
        , attachment_file_url
        , sanction_content
    FROM {{ ref('ods_audit_af_sanctions') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_SANCTIONS', "src.id") }}           AS af_sanction_id
    , CAST(src.id AS string)                                                        AS af_sanction_code
    , CAST('AUDIT_AF_SANCTIONS' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }} AS af_id
    , CAST(afp.audit_firm_cd AS string)                                             AS af_code
    , CAST(src.sanction_authority_cd AS string)                                     AS sanction_authority_code
    , CAST(src.decision_no AS string)                                               AS decision_nbr
    , CAST(src.decision_date AS date)                                               AS decision_dt
    , CAST(src.sanction_content AS string)                                          AS sanction_content
    , CAST(src.attachment_file_url AS string)                                       AS attachment_file_url
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
