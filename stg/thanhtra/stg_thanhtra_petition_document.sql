/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_petition_document
* Program name: Staging THANHTRA.PETITION_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(petition_id AS string)              AS petition_id
    , CAST(document_type AS string)            AS document_type
    , CAST(document_number AS string)          AS document_number
    , CAST(document_date AS date)              AS document_date
    , CAST(content AS string)                  AS content
    , CAST(classification_result AS string)    AS classification_result
    , CAST(proposed_action AS string)          AS proposed_action
    , CAST(transfer_target_unit AS string)     AS transfer_target_unit
    , CAST(resolution_deadline AS date)        AS resolution_deadline
    , CAST(signer_name AS string)              AS signer_name
    , CAST(acceptance_proposal_type AS string) AS acceptance_proposal_type
    , CAST(rejection_reason AS string)         AS rejection_reason
    , CAST(prepared_by AS string)              AS prepared_by
    , CAST(prepared_at AS date)                AS prepared_at
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(created_by AS string)               AS created_by
    , CAST(last_modified_by AS string)         AS last_modified_by
    , CAST(version AS bigint)                  AS version
    , CAST(deleted AS int)                     AS deleted
    , CAST(document_template_id AS string)     AS document_template_id
    , CAST(document_template_name AS string)   AS document_template_name
    , CAST(field_html_json AS string)          AS field_html_json
FROM {{ source('source_thanhtra', 'raw_petition_document') }}