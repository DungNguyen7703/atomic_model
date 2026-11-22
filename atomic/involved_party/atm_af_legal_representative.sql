/*
*--------------------------------------------------------------------*
* Program code: atm_af_legal_representative
* Program name: Atomic Af Legal Representative
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_LEGAL_REPRESENTATIVE.yaml (Relative -> scd2). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , full_name
        , identity_no
        , position_title_cd
        , appointment_start_date
        , appointment_end_date
    FROM {{ ref('ods_audit_af_legal_representative') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_LEGAL_REPRESENTATIVE', "src.id") }} AS af_legal_representative_id
    , CAST(src.id AS string)                                                         AS af_legal_representative_code
    , CAST('AUDIT_AF_LEGAL_REPRESENTATIVE' AS string)                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }}  AS af_id
    , CAST(afp.audit_firm_cd AS string)                                              AS af_code
    , CAST(src.full_name AS string)                                                  AS af_legal_representative_nm
    , CAST(src.identity_no AS string)                                                AS identification_nbr
    , CAST(src.position_title_cd AS string)                                          AS position_title_code
    , CAST(src.appointment_start_date AS date)                                       AS appointment_start_dt
    , CAST(src.appointment_end_date AS date)                                         AS appointment_end_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
