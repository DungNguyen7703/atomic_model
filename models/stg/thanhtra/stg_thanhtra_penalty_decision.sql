/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision
* Program name: Staging THANHTRA.PENALTY_DECISION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_PENALTY_DECISION.yaml] Them cot nguon enforcement_status, confiscated_asset_sale_amount, other_penalty_revenue_amount, report_classification (cuoi danh sach, sau approver_name)
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(decision_number AS string)          AS decision_number
    , CAST(issued_date AS date)                AS issued_date
    , CAST(signer_id AS string)                AS signer_id
    , CAST(signer_name AS string)              AS signer_name
    , CAST(violation_case_id AS string)        AS violation_case_id
    , CAST(decision_category AS string)        AS decision_category
    , CAST(assigned_officer_id AS string)      AS assigned_officer_id
    , CAST(assigned_officer_name AS string)    AS assigned_officer_name
    , CAST(anti_money_laundering AS int)       AS anti_money_laundering
    , CAST(total_fine_amount AS decimal(19,4)) AS total_fine_amount
    , CAST(payment_deadline AS date)           AS payment_deadline
    , CAST(status AS string)                   AS status
    , CAST(complaint_exists AS int)            AS complaint_exists
    , CAST(complaint_content AS string)        AS complaint_content
    , CAST(complaint_received_date AS date)    AS complaint_received_date
    , CAST(complaint_status AS string)         AS complaint_status
    , CAST(complaint_result AS string)         AS complaint_result
    , CAST(lawsuit_exists AS int)              AS lawsuit_exists
    , CAST(lawsuit_content AS string)          AS lawsuit_content
    , CAST(created_at AS timestamp)                        AS created_at
    , CAST(last_modified_at AS timestamp)                  AS last_modified_at
    , CAST(created_by AS string)               AS created_by
    , CAST(last_modified_by AS string)         AS last_modified_by
    , CAST(version AS bigint)                  AS version
    , CAST(deleted AS int)                     AS deleted
    , CAST(submitted_by_id AS string)          AS submitted_by_id
    , CAST(approver_id AS string)              AS approver_id
    , CAST(submitted_at AS timestamp)          AS submitted_at
    , CAST(signed_document_url AS string)      AS signed_document_url
    , CAST(summary AS string)                  AS summary
    , CAST(reviewer_id AS string)              AS reviewer_id
    , CAST(reviewer_name AS string)            AS reviewer_name
    , CAST(reviewed_at AS timestamp)           AS reviewed_at
    , CAST(source_document_url AS string)      AS source_document_url
    , CAST(reviewed_by_id AS string)           AS reviewed_by_id
    , CAST(approver_name AS string)            AS approver_name
    , CAST(enforcement_status AS string)       AS enforcement_status
    , CAST(confiscated_asset_sale_amount AS decimal(19,4)) AS confiscated_asset_sale_amount
    , CAST(other_penalty_revenue_amount AS decimal(19,4)) AS other_penalty_revenue_amount
    , CAST(report_classification AS string)    AS report_classification
FROM {{ source('source_thanhtra', 'raw_penalty_decision') }}