/*
*--------------------------------------------------------------------*
* Program code: ods_fms_stockholder_type
* Program name: ODS FMS.STOCKHOLDER_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD FMS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , record_status
    , item_name
    , description
    , personal_type
    , deleted
FROM {{ ref('stg_fms_stockholder_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1