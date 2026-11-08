/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_documents
* Program name: ODS NHNCK.DOCUMENTS
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
    , document_code
    , document_name
    , reference
    , created_at
    , created_by
    , updated_at
    , is_active
    , is_original_data
    , sort_order
    , status
    , mcdt_code
    , updated_by
FROM {{ ref('stg_nhnck_documents') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')