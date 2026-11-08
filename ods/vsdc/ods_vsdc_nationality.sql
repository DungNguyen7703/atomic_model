/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_nationality
* Program name: ODS VSDC.NATIONALITY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Lay 1-1 bang danh muc quoc tich VSDC.NATIONALITY tu source_vsdc. Nhan du lieu ~1 lan/tuan, KHONG loc theo etl_date (cung khung ods_vsdc_open_investors).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(autoid AS bigint)                 AS autoid
    , CAST(name AS string)                 AS name
FROM {{ source('source_vsdc', 'raw_nationality') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

