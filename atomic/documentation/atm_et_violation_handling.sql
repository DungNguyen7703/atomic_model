/*
*--------------------------------------------------------------------*
* Program code: atm_et_violation_handling
* Program name: Atomic Et Violation Handling
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_KNT_TAX_VIOLATION_HANDLING.yaml (Fact Append -> incremental_rebase append). UAT chua co model KNT nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        handling_decision_number
        , subject_name
        , tax_code
        , inspection_period
        , violation_fine
        , admin_violation_fine
        , tax_recovery_amount
        , msg_packet_id
        , issuing_org
        , issuing_tax_authority_name
        , decision_type
        , decision_date
        , total_fine_amount
        , other_fine_amount
        , nam_bat_dau
        , nam_ket_thuc
    FROM {{ ref('ods_knt_tax_violation_handling') }}
)

SELECT
    {{ generate_surrogate_key_bigint('KNT_TAX_VIOLATION_HANDLING', "src.handling_decision_number") }} AS et_violation_handling_id
    , CAST(src.handling_decision_number AS string)                                                      AS et_violation_handling_code
    , CAST('KNT_TAX_VIOLATION_HANDLING' AS string)                                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('KNT_TAX_REGISTRATION_INFO', "src.tax_code") }}                  AS et_registration_id
    , CAST(src.tax_code AS string)                                                                      AS et_registration_code
    , CAST(src.subject_name AS string)                                                                  AS subject_nm
    , CAST(src.inspection_period AS string)                                                             AS inspection_period
    , CAST(src.violation_fine AS string)                                                                AS violation_fine_amt
    , CAST(src.admin_violation_fine AS string)                                                          AS administrative_violation_fine_amt
    , CAST(src.tax_recovery_amount AS string)                                                           AS tax_recovery_amt
    , CAST(src.issuing_org AS string)                                                                   AS issuing_organization_nm
    , CAST(src.issuing_tax_authority_name AS string)                                                    AS issuing_tax_authority_nm
    , CAST(src.decision_type AS string)                                                                 AS decision_tp_code
    , CAST(src.decision_date AS date)                                                                   AS decision_dt
    , CAST(src.total_fine_amount AS string)                                                             AS total_fine_amt
    , CAST(src.other_fine_amount AS string)                                                             AS other_fine_amt
    , CAST(src.msg_packet_id AS string)                                                                 AS message_packet_id
    , CAST(src.nam_bat_dau AS string)                                                                   AS start_year
    , CAST(src.nam_ket_thuc AS string)                                                                  AS end_year
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                                    AS data_dt
FROM src
