/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_filter
* Program name: ODS SCMS.CAT_FILTER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD SCMS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , code
    , name
    , description
    , allow_multiple
    , sort_order
    , record_status
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_scms_cat_filter') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')