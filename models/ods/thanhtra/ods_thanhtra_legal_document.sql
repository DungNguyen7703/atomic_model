/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_legal_document
* Program name: ODS THANHTRA.LEGAL_DOCUMENT
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
    , code
    , name
    , issued_date
    , status
    , note
    , created_at
    , created_by
    , last_modified_at
    , last_modified_by
    , version
    , deleted
    , ecatalog_id
FROM {{ ref('stg_thanhtra_legal_document') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0