/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_decision_documents
* Program name: ODS NHNCK.DECISION_DOCUMENTS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Bo sung ODS (STG da co).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , decision_id
    , type
    , decision_number
    , position
    , file_path
    , signed_by
    , signed_date
    , status
    , created_at
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_decision_documents') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
