/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_violation_handling
* Program name: Staging KNT.TAX_VIOLATION_HANDLING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(handling_decision_number AS string)   AS handling_decision_number
    , CAST(subject_name AS string)               AS subject_name
    , CAST(tax_code AS string)                   AS tax_code
    , CAST(inspection_period AS string)          AS inspection_period
    , CAST(violation_fine AS string)             AS violation_fine
    , CAST(admin_violation_fine AS string)       AS admin_violation_fine
    , CAST(tax_recovery_amount AS string)        AS tax_recovery_amount
    , CAST(msg_packet_id AS int)                 AS msg_packet_id
    , CAST(issuing_org AS string)                AS issuing_org
    , CAST(issuing_tax_authority_name AS string) AS issuing_tax_authority_name
    , CAST(decision_type AS string)              AS decision_type
    , CAST(decision_date AS date)                AS decision_date
    , CAST(total_fine_amount AS string)          AS total_fine_amount
    , CAST(other_fine_amount AS string)          AS other_fine_amount
    , CAST(nam_bat_dau AS int)                   AS nam_bat_dau
    , CAST(nam_ket_thuc AS int)                  AS nam_ket_thuc
FROM {{ source('source_knt', 'raw_tax_violation_handling') }}