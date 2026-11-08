/*
*--------------------------------------------------------------------*
* Program code: ods_fms_national
* Program name: ODS FMS.NATIONAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		Them dieu kien loc ODS chi lay ban ghi con hoat dong o nguon: record_status = 1 AND deleted = 0 (theo ma tran loc FMS).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , sname
    , item_name
    , description
    , record_status
    , deleted
    , data_migration
    , code
FROM {{ ref('stg_fms_national') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND record_status = 1
    AND deleted = 0