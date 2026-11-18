/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_vphc_process_official_letter
* Program name: Staging THANHTRA.VPHC_PROCESS_OFFICIAL_LETTER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(official_letter_subtype AS string) AS official_letter_subtype
    , CAST(document_template_id AS string)    AS document_template_id
    , CAST(document_template_name AS string)  AS document_template_name
    , CAST(violation_case_id AS string)       AS violation_case_id
    , CAST(violation_case_code AS string)     AS violation_case_code
    , CAST(violation_record_id AS string)     AS violation_record_id
    , CAST(violation_record_number AS string) AS violation_record_number
    , CAST(penalty_decision_id AS string)     AS penalty_decision_id
    , CAST(penalty_decision_number AS string) AS penalty_decision_number
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(field_html_json AS string)         AS field_html_json
    , CAST(field_source_json AS string)       AS field_source_json
    , CAST(manual_merge_data_json AS string)  AS manual_merge_data_json
    , CAST(output_document_id AS string)      AS output_document_id
FROM {{ source('source_thanhtra', 'raw_vphc_process_official_letter') }}