/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_ward
* Program name: ODS SCMS.CAT_WARD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , province_id
    , district_id
    , ward_code
    , ward_name
    , note
    , created_by
    , created_at
    , record_status
    , ecatalog_id
FROM {{ ref('stg_scms_cat_ward') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')