/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_anti_corruption_document
* Program name: ODS THANHTRA.ANTI_CORRUPTION_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS THANHTRA.ANTI_CORRUPTION_DOCUMENT - loc ODS chi lay ban ghi con hoat dong o nguon: deleted = 0 (theo ma tran loc THANHTRA).
* 2026-11-12		ngoc.pham		Sua description schema.yml dung phan he THANHTRA
*--------------------------------------------------------------------*
*/

SELECT
    id
    , document_type
    , document_number
    , issued_date
    , summary
    , document_year
    , receiving_unit
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , quarter
FROM {{ ref('stg_thanhtra_anti_corruption_document') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
