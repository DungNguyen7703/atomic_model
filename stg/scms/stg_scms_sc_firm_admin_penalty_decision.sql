/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_admin_penalty_decision
* Program name: Staging SCMS.SC_FIRM_ADMIN_PENALTY_DECISION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: issued_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                        AS id
    , CAST(sc_firm_info_id AS bigint)           AS sc_firm_info_id
    , CAST(registered_address AS string)        AS registered_address
    , CAST(decision_file_path AS string)        AS decision_file_path
    , CAST(note AS string)                      AS note
    , CAST(violation_acts_json AS string)       AS violation_acts_json
    , CAST(penalty_form AS string)              AS penalty_form
    , CAST(tax_code_business_license AS string) AS tax_code_business_license
    , CAST(issued_date AS date)            AS issued_date
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(sync_date AS timestamp)              AS sync_date
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(last_modified_by AS bigint)          AS last_modified_by
    , CAST(signatory AS string)                 AS signatory
    , CAST(created_by AS bigint)                AS created_by
    , CAST(data_source AS string)               AS data_source
    , CAST(decision_number AS string)           AS decision_number
    , CAST(paid_amount AS decimal(20,2))        AS paid_amount
    , CAST(fine_amount AS decimal(20,2))        AS fine_amount
    , CAST(fine_payment_deadline AS string)     AS fine_payment_deadline
    , CAST(total_fine_amount AS decimal(20,2))  AS total_fine_amount
    , CAST(implementation_status AS string)     AS implementation_status
FROM {{ source('source_scms', 'raw_sc_firm_admin_penalty_decision') }}