/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_end_of_day_open_interest
* Program name: ODS VSDC.END_OF_DAY_OPEN_INTEREST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic lld_VSDC_END_OF_DAY_OPEN_INTEREST.yaml] Them cot report_date (giua open_interest_volume va
*									ds_snpst_dt) de atomic bo sung rpt_dt. Can ALTER ODS ADD COLUMN report_date date AFTER open_interest_volume
*									(model append - insert theo vi tri).
* 2026-10-27		tuan.nguyenvanb		Nguon chi co 1 ds_snpst_dt, moi ds_snpst_dt chua nhieu report_date -> doi sang partition theo report_date va macro snapshot
*									(ghi de partition cua ngay etl_date). Loc report_date = etl_date (thay ds_snpst_dt). Macro snapshot tu them cot ds_snpst_dt = etl_date
*									(= report_date) nen model KHONG chon ds_snpst_dt nua. Thu tu cot vat ly khong doi. Can doi partition bang vat ly
*									(ADD PARTITION FIELD report_date / DROP PARTITION FIELD ds_snpst_dt) va nap lai du lieu.
*/

SELECT
    CAST(contract_code AS string)          AS contract_code
    , CAST(open_interest_volume AS bigint) AS open_interest_volume
    , CAST(report_date AS date)            AS report_date
FROM {{ source('source_vsdc', 'raw_end_of_day_open_interest') }}
WHERE report_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
