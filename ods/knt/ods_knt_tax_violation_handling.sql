/*
*--------------------------------------------------------------------*
* Program code: ods_knt_tax_violation_handling
* Program name: ODS KNT.TAX_VIOLATION_HANDLING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-12		ngoc.pham		Bo cot data_dt khoi SELECT cho khop DDL (Truncate then Insert)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , handling_decision_number
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
FROM {{ ref('stg_knt_tax_violation_handling') }}