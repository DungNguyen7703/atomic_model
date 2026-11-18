-- [FIRST-TIME] ft_ods_vsdc_end_of_day_open_interest: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_vsdc_end_of_day_open_interest (config ft_target='end_of_day_open_interest', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_end_of_day_open_interest
* Program name: ODS VSDC.END_OF_DAY_OPEN_INTEREST (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		tuan.nguyenvanb		Tao moi ban first-time: nap TOAN BO report_date cua nguon 1 lan, partition theo report_date nhu daily.
*									ds_snpst_dt = report_date (daily snapshot: ds_snpst_dt = etl_date = report_date cua partition do).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(contract_code AS string)          AS contract_code
    , CAST(open_interest_volume AS bigint) AS open_interest_volume
    , CAST(report_date AS date)            AS report_date
    , CAST(report_date AS date)            AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_end_of_day_open_interest') }}
-- [BACKFILL-UAT-ORIG] WHERE report_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
