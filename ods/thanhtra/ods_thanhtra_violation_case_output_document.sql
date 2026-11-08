/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_case_output_document
* Program name: ODS THANHTRA.VIOLATION_CASE_OUTPUT_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , violation_case_id
    , document_type
    , document_number
    , document_name
    , document_date
    , penalty_decision_id
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_violation_case_output_document') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0