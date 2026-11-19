/*
*--------------------------------------------------------------------*
* Program code: atm_af_auditor_status_history
* Program name: Atomic Af Auditor Status History
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_AUDIT_AF_AUDITOR_STATUS_HISTORY.yaml (Fact Append -> incremental_rebase append). Kieu cot lay theo ODS PROD.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , af_auditor_profile_id
        , event_type
        , effective_date
        , reason
        , additional_desc
    FROM {{ ref('ods_audit_af_auditor_status_history') }}
)

SELECT
    {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_STATUS_HISTORY', "src.id") }}                AS af_auditor_status_history_id
    , CAST(src.id AS string)                                                                        AS af_auditor_status_history_code
    , CAST('AUDIT_AF_AUDITOR_STATUS_HISTORY' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('AUDIT_AF_AUDITOR_PROFILES', "src.af_auditor_profile_id") }} AS af_auditor_id
    , CAST(src.af_auditor_profile_id AS string)                                                     AS af_auditor_code
    , CAST(src.event_type AS string)                                                                AS event_tp_code
    , CAST(src.effective_date AS date)                                                              AS effective_dt
    , CAST(src.reason AS string)                                                                    AS reason_description
    , CAST(src.additional_desc AS string)                                                           AS additional_description
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                                AS data_dt
FROM src
