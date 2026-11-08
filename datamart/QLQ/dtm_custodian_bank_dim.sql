/*
*--------------------------------------------------------------------*
* Program code: dtm_custodian_bank_dim
* Program name: Dtm Custodian Bank Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_custodian_bank_dim_FMS_BANK_MONI.csv
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): operation_status_code đọc từ custodian_bank.cl_fms_status_code
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): bỏ custodian_certificate_nbr (LLD đã bỏ)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c (luật A23 PK Dim): custodian_bank_id lấy trực tiếp custodian_bank.custodian_bank_id (Atomic) thay cho
*                                       generate_surrogate_key_bigint — khớp FK custodian_bank_id mà các model khác đọc từ Atomic (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH custodian_bank AS (
    SELECT
        custodian_bank_id,
        custodian_bank_code,
        custodian_bank_full_nm,
        custodian_bank_english_nm,
        custodian_bank_short_nm,
        bank_swift_code,
        cl_fms_status_code,
        note,
        record_cl_text,
        amendment_document_nbr,
        decision_issue_dt,
        change_description,
        src_stm_code
    FROM {{ ref('atm_custodian_bank') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_BANK_MONI'
)

SELECT
    CAST(custodian_bank_id AS string)                                 AS custodian_bank_id,
    CAST(custodian_bank_code AS string)                               AS custodian_bank_code,
    CAST(custodian_bank_full_nm AS string)                            AS custodian_bank_full_nm,
    CAST(custodian_bank_english_nm AS string)                         AS custodian_bank_english_nm,
    CAST(custodian_bank_short_nm AS string)                           AS custodian_bank_short_nm,
    CAST(bank_swift_code AS string)                                   AS bank_swift_code,
    CAST(cl_fms_status_code AS string)                                AS operation_status_code,
    CAST(note AS string)                                              AS note,
    CAST(record_cl_text AS string)                                    AS record_cl_text,
    CAST(amendment_document_nbr AS string)                            AS amendment_document_nbr,
    CAST(decision_issue_dt AS date)                                   AS decision_issue_dt,
    CAST(change_description AS string)                                AS change_description,
    CAST(src_stm_code AS string)                                      AS src_stm_code
FROM custodian_bank
