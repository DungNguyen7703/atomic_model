/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_anti_money_laundering_document
* Program name: ODS THANHTRA.ANTI_MONEY_LAUNDERING_DOCUMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS THANHTRA.ANTI_MONEY_LAUNDERING_DOCUMENT - loc ODS chi lay ban ghi con hoat dong o nguon: deleted = 0 (theo ma tran loc THANHTRA).
* 2026-11-07		tuan.nguyenvanb		Dong bo cot theo stg_thanhtra_anti_money_laundering_document (ODS lay 1-1 tu staging): them cot dossier_id.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , document_type
    , document_number
    , issued_date
    , summary
    , document_year
    , quarter
    , receiving_unit
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , dossier_id
FROM {{ ref('stg_thanhtra_anti_money_laundering_document') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
