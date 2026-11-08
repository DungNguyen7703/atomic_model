/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_violation_case_received_document
* Program name: ODS THANHTRA.VIOLATION_CASE_RECEIVED_DOCUMENT
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
    , document_number
    , document_date
    , issuing_unit_name
    , violation_subject_name
    , violation_record_id
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , issuing_unit_id
FROM {{ ref('stg_thanhtra_violation_case_received_document') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0