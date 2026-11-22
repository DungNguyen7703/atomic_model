/*
*--------------------------------------------------------------------*
* Program code: atm_af_status_history
* Program name: Atomic Af Status History
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_STATUS_HISTORY.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_profile_id
        , status_type
        , suspension_status_type
        , decision_no
        , decision_date
        , effective_from_date
        , effective_to_date
        , terminated_decision_date
        , reason
        , additional_desc
    FROM {{ ref('ods_audit_af_status_history') }}
),

afp AS (
    SELECT
        id
        , audit_firm_cd
    FROM {{ ref('ods_audit_af_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_STATUS_HISTORY', "src.id") }}      AS af_status_history_id
    , CAST(src.id AS string)                                                        AS af_status_history_code
    , CAST('AUDIT_AF_STATUS_HISTORY' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_PROFILES', "afp.audit_firm_cd") }} AS af_id
    , CAST(afp.audit_firm_cd AS string)                                             AS af_code
    , CAST(src.status_type AS string)                                               AS status_tp_code
    , CAST(src.suspension_status_type AS string)                                    AS suspension_status_tp_code
    , CAST(src.decision_no AS string)                                               AS decision_nbr
    , CAST(src.decision_date AS date)                                               AS decision_dt
    , CAST(src.effective_from_date AS date)                                         AS effective_from_dt
    , CAST(src.effective_to_date AS date)                                           AS effective_to_dt
    , CAST(src.terminated_decision_date AS date)                                    AS terminated_decision_dt
    , CAST(src.reason AS string)                                                    AS reason_description
    , CAST(src.additional_desc AS string)                                           AS additional_description
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                AS data_dt
FROM src
    LEFT JOIN afp ON src.af_profile_id = afp.id
